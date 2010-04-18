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
    import com.adobe.utils.StringUtil;
    import com.hurlant.util.Base64;

    import org.coderepos.net.xmpp.XMPPNamespace;
    import org.coderepos.net.xmpp.exceptions.XMPPProtocolError;
    import org.coderepos.sasl.exceptions.SASLBadChallengeError;
    import org.coderepos.sasl.mechanisms.ISASLMechanism;
    import org.coderepos.xml.XMLAttributes;
    import org.coderepos.xml.XMLElement;
    import org.coderepos.xml.sax.XMLElementEventHandler;

    public class SASLHandler implements IXMPPStreamHandler
    {
        private var _stream:XMPPStream;
        private var _mech:ISASLMechanism;

        public function SASLHandler(stream:XMPPStream, mech:ISASLMechanism)
        {
            _stream = stream;
            _mech   = mech;
        }

        public function run():void
        {
            _stream.setXMLEventHandler(getHandler());
            var authTag:String =
                '<auth '
                    + 'xmlns="'+XMPPNamespace.SASL+'" '
                    + 'mechanism="'+ _mech.name +'"';
            var start:String = _mech.start();
            trace("[SASL:start]");
            if (start != null && start.length > 0) {
                authTag += '>';
                authTag += Base64.encode(start);
                authTag += '</auth>';
            } else {
                authTag += ' />';
            }
            _stream.send(authTag);
        }

        public function getHandler():XMLElementEventHandler
        {
            var handler:XMLElementEventHandler = new XMLElementEventHandler();
            handler.registerRootElementAttributeEvent(
                XMPPNamespace.STREAM, "stream", streamHandler);
            handler.registerElementEvent(
                XMPPNamespace.STREAM, "features", 1, featuresHandler);
            handler.registerElementEvent(
                XMPPNamespace.SASL, "challenge", 1, challengeHandler);
            handler.registerElementEvent(
                XMPPNamespace.SASL, "failure", 1, failureHandler);
            handler.registerElementEvent(
                XMPPNamespace.SASL, "success", 1, successHandler);
            handler.registerElementEvent(
                XMPPNamespace.SASL, "abort", 1, abortHandler);
            return handler;
        }

        private function streamHandler(attrs:XMLAttributes):void
        {
            // after SASL authentication completed
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
            // after SASL authentication completed
            //trace("[FEATURES]");
            _stream.features = XMPPServerFeatures.fromElement(elem);
            _stream.authenticated();
        }

        private function challengeHandler(elem:XMLElement):void
        {
            var challenge:String = StringUtil.trim(Base64.decode(elem.text));
            var response:String;
            try {
                response = _mech.step(challenge);
            } catch (e:*) {
                if (e is SASLBadChallengeError) {
                    throw new XMPPProtocolError("SASL bad challenge:" + challenge);
                } else {
                    throw e;
                }
            }
            _stream.send(
                  '<response xmlns="' + XMPPNamespace.SASL + '">'
                + Base64.encode(response)
                + '</response>'
            );
        }

        private function failureHandler(elem:XMLElement):void
        {
            trace("[SASL:failure]");
            throw new XMPPProtocolError("SASL failure");
        }

        private function successHandler(elem:XMLElement):void
        {
            trace("[SASL:success]");
            _stream.clearBuffer();
            _stream.send(
            '<stream:stream '
            +   'xmlns="' + XMPPNamespace.CLIENT + '" '
            +   'xmlns:stream="' + XMPPNamespace.STREAM + '" '
            +   'to="' + _stream.domain + '" '
            +   'version="1.0">'
            );
        }

        private function abortHandler(elem:XMLElement):void
        {
            trace("[SASL:abort]");
            throw new XMPPProtocolError("SASL aborted");
        }
    }
}

