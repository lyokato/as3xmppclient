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
    import org.coderepos.xml.sax.XMLElementEventHandler;
    import org.coderepos.xml.XMLElement;
    import org.coderepos.xml.XMLAttributes;

    import org.coderepos.net.xmpp.JID;
    import org.coderepos.net.xmpp.IQType;
    import org.coderepos.net.xmpp.XMPPNamespace;
    import org.coderepos.net.xmpp.exceptions.XMPPProtocolError;

    public class ResourceBindingHandler implements IXMPPStreamHandler
    {
        private var _stream:XMPPStream;
        private var _originalResource:String;
        private var _currentResource:String;
        private var _failedCount:uint;
        private var _MAX_FAILED_COUNT:uint;
        private var _currentIQID:String;

        public function ResourceBindingHandler(stream:XMPPStream, resource:String="", maxRetryCount:uint=5)
        {
            _stream           = stream;
            _originalResource = resource;
            _currentResource  = resource;
            _failedCount      = 0;
            _MAX_FAILED_COUNT = maxRetryCount;
        }

        public function run():void
        {
            _stream.setXMLEventHandler(getHandler());
            sendBindRequest();
        }

        private function sendBindRequest():void
        {
            var bindTag:String = '<bind xmlns="' + XMPPNamespace.BIND + '"';
            if (_originalResource.length > 0) {
                bindTag += '>';
                bindTag += '<resource>' + _currentResource + '</resource>';
                bindTag += '</bind>';
            } else {
                bindTag += '/>';
            }
            _currentIQID = _stream.genNextID();
            _stream.send(
                  '<iq type="' + IQType.SET + '" id="' + _currentIQID + '">'
                + bindTag
                + '</iq>'
            );
        }

        private function retry():void
        {
            _failedCount++;
            if (_failedCount > _MAX_FAILED_COUNT) {
                throw new XMPPProtocolError(
                    "tried " + String(_failedCount)
                    + " time(s), but couldn't bind resource");
            }
            _currentResource = _originalResource + String(_failedCount);
            sendBindRequest();
        }

        public function getHandler():XMLElementEventHandler
        {
            var handler:XMLElementEventHandler = new XMLElementEventHandler();
            handler.registerElementEvent(
                XMPPNamespace.CLIENT, "iq", 1, iqHandler);
            return handler;
        }

        private function iqHandler(elem:XMLElement):void
        {
            //trace("[ResourceBinding:iq]");

            var iqID:String = elem.getAttr("id");
            if (iqID != null && iqID == _currentIQID) {

                var iqType:String = elem.getAttr("type");

                if (iqType == null)
                    throw new XMPPProtocolError("not found iq@type");

                if (iqType == IQType.RESULT) {

                    var bind:XMLElement =
                        elem.getFirstElementNS(XMPPNamespace.BIND, "bind");
                    if (bind == null)
                        throw new XMPPProtocolError("<bind/> not found");
                    var res:XMLElement = bind.getFirstElement("jid");
                    if (res == null)
                        throw new XMPPProtocolError("<jid/> not found");
                    var boundJID:JID;
                    try {
                        boundJID = new JID(res.text);
                    } catch (e:*) {
                        throw new XMPPProtocolError("Invalid JID:" + res.text);
                    }
                    trace("[ResourceBinding:success]");
                    trace(res.text);
                    _stream.bindJID(boundJID);

                } else if (iqType == IQType.ERROR) {

                    var error:XMLElement = elem.getFirstElement("error");
                    if (   error != null
                        && error.getAttr("type") == "cancel"
                        && error.getFirstElementNS(XMPPNamespace.STANZA, "conflict") ) {

                        retry();

                    } else {
                        throw new XMPPProtocolError(
                            "Failed to bind resource: " + _currentResource);
                    }

                } else {
                    throw new XMPPProtocolError(
                        "invalid iq-type for resource binding: " + iqType);
                }
            } else {
                // Unknown IQ query
            }
        }
    }
}

