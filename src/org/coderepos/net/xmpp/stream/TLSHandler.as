/*
Copyright (c) Lyo Kato (lyo.kato _at_ gmail.com)

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package org.coderepos.net.xmpp.stream
{
    import org.coderepos.net.xmpp.XMPPNamespace;
    import org.coderepos.net.xmpp.exceptions.XMPPProtocolError;

    import org.coderepos.xml.XMLAttributes;
    import org.coderepos.xml.XMLElement;
    import org.coderepos.xml.sax.XMLElementEventHandler;

    public class TLSHandler implements IXMPPStreamHandler
    {
        private var _stream:XMPPStream;

        public function TLSHandler(stream:XMPPStream)
        {
            _stream = stream;
        }

        public function run():void
        {
            _stream.setXMLEventHandler(getHandler());
            _stream.send(
                '<starttls xmlns="' + XMPPNamespace.TLS + '"/>'
            );
        }

        public function getHandler():XMLElementEventHandler
        {
            var handler:XMLElementEventHandler = new XMLElementEventHandler();
            handler.registerRootElementAttributeEvent(
                XMPPNamespace.STREAM, "stream", streamHandler);
            handler.registerElementEvent(
                XMPPNamespace.STREAM, "features", 1, featuresHandler);
            handler.registerElementEvent(
                XMPPNamespace.TLS, "proceed", 1, proceedHandler);
            handler.registerElementEvent(
                XMPPNamespace.TLS, "failure", 1, failureHandler);
            handler.registerUnknownElementEvent(unknownHandler);
            return handler;
        }

        private function streamHandler(attrs:XMLAttributes):void
        {
            // after TLS negotiation, new stream comes
            //trace("[STREAM]");
            var id:String = attrs.getValue("id");
            if (id == null)
                throw new XMPPProtocolError("stream@id not found");
            var version:String = attrs.getValue("version");
            if (version == null)
                throw new XMPPProtocolError("stream@version not found");
            if (version != "1.0")
                throw new XMPPProtocolError("Unsupported XMPP protocol version: " + version);
            _stream.setAttribute("id", id);
            _stream.setAttribute("version", version);
        }

        private function featuresHandler(elem:XMLElement):void
        {
            // after TLS negotiation, new stream comes
            //trace("[FEATURES]");
            _stream.features = XMPPServerFeatures.fromElement(elem);
            _stream.tlsNegotiated();
        }

        private function proceedHandler(elem:XMLElement):void
        {
            trace("[TLS:proceed]");
            _stream.switchToTLS();
            _stream.send(
            //'<?xml version="1.0" encoding="utf-8"?>'
            '<stream:stream '
            +   'xmlns="' + XMPPNamespace.CLIENT + '" '
            +   'xmlns:stream="' + XMPPNamespace.STREAM + '" '
            +   'to="' + _stream.domain + '" '
            +   'version="1.0">'
            );
        }

        private function failureHandler(elem:XMLElement):void
        {
            // not come here,
            // because as3crypto TLSEngine disconnect socket on failure.
            trace("[TLS:failure]");
        }

        private function unknownHandler(ns:String, localName:String, depth:uint):void
        {
            trace("[UNKNOWN]");
            trace(ns);
            trace(localName);
        }
    }
}

