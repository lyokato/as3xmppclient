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

package org.coderepos.net.xmpp
{
    import com.hurlant.crypto.tls.TLSConfig;
    import com.hurlant.crypto.tls.TLSEngine;
    import com.hurlant.crypto.tls.TLSSecurityParameters;
    import com.hurlant.crypto.tls.TLSSocket;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.Socket;
    import flash.utils.ByteArray;

    import org.coderepos.net.xmpp.events.XMPPErrorEvent;
    import org.coderepos.net.xmpp.exceptions.XMPPAuthError;
    import org.coderepos.net.xmpp.exceptions.XMPPProtocolError;
    import org.coderepos.xml.exceptions.XMLElementDepthOverError;
    import org.coderepos.xml.exceptions.XMLFragmentSizeOverError;
    import org.coderepos.xml.exceptions.XMLSyntaxError;
    import org.coderepos.xml.sax.XMLElementEventHandler;
    import org.coderepos.xml.sax.XMLSAXParser;
    import org.coderepos.xml.sax.XMLSAXParserConfig;

    public class XMPPConnection extends EventDispatcher
    {
        private var _socket:Socket;
        private var _parser:XMLSAXParser;
        private var _config:XMPPConfig;

        public function XMPPConnection(config:XMPPConfig)
        {
            _socket = null;
            var saxConfig:XMLSAXParserConfig = new XMLSAXParserConfig();
            saxConfig.MAX_FRAGMENT_SIZE = config.xmlMaxFragmentSize;
            saxConfig.MAX_ELEMENT_DEPTH = config.xmlMaxElementDepth;
            _parser = new XMLSAXParser(saxConfig);
            _config = config;
        }

        public function setXMLEventHandler(handler:XMLElementEventHandler):void
        {
            _parser.handler = handler;
        }

        public function get connected():Boolean
        {
            return (_socket != null && _socket.connected);
        }

        public function dispose():void
        {
            if (_socket != null) {
                removeSocketEventListeners(_socket);
                _socket = null;
            }
            //trace("============= parser reset ============");
            _parser.reset();
        }

        public function clearBuffer():void
        {
            //trace("============= parser reset ============");
            _parser.reset();
        }

        public function disconnect():void
        {
            if (connected)
                _socket.close();
            dispose();
        }

        public function connect():void
        {
            if (connected)
                throw new Error("already connected.");

            if (_socket == null || _socket is TLSSocket) {
                if (_socket != null)
                    removeSocketEventListeners(_socket);
                _socket = new Socket();
                addSocketEventListeners(_socket);
            }
            _socket.connect(_config.host, _config.port);
        }

        public function startTLS():void
        {
            if (_socket != null) {

                _parser.reset();

                var tlsSocket:TLSSocket = new TLSSocket();
                removeSocketEventListeners(_socket);
                addSocketEventListeners(tlsSocket);
                var tlsConfig:TLSConfig = new TLSConfig(
                    TLSEngine.CLIENT,
                    null, // cipherSuite
                    null, // compression
                    null, // certificate bytes
                    null, // private key
                    null, // CAStore
                    TLSSecurityParameters.PROTOCOL_VERSION
                );
                tlsConfig.ignoreCommonNameMismatch = true;
                tlsSocket.startTLS(_socket, _config.host, tlsConfig);
                _socket = tlsSocket;
            }
        }

        public function send(message:String):void
        {
            if (!connected)
                throw new Error("Socket not connected.");

            //trace(message);
            var bytes:ByteArray = new ByteArray();
            bytes.writeUTFBytes(message);
            bytes.position = 0;
            _socket.writeBytes(bytes);
            _socket.flush();
        }

        private function addSocketEventListeners(s:Socket):void
        {
            s.addEventListener(Event.CONNECT, dispatchEvent);
            s.addEventListener(Event.CLOSE, closeHandler);
            s.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            s.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            s.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
        }

        private function removeSocketEventListeners(s:Socket):void
        {
            s.removeEventListener(Event.CONNECT, dispatchEvent);
            s.removeEventListener(Event.CLOSE, closeHandler);
            s.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            s.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            s.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
        }

        private function closeHandler(e:Event):void
        {
            dispose();
            dispatchEvent(e);
        }

        private function ioErrorHandler(e:IOErrorEvent):void
        {
            trace("[socket:io]", String(_socket.connected), e.text);
            dispose();
            dispatchEvent(e);
        }

        private function securityErrorHandler(e:SecurityErrorEvent):void
        {
            trace("[socket:sec]", String(_socket.connected), e.text);
            dispose();
            dispatchEvent(e);
        }

        private function socketDataHandler(e:ProgressEvent):void
        {
            try {
                while (_socket != null && _socket.bytesAvailable > 0) {
                    var bytes:ByteArray = new ByteArray();
                    var len:uint = (1024 > _socket.bytesAvailable)
                        ? _socket.bytesAvailable : 1024;
                    _socket.readBytes(bytes, 0, len);
                    bytes.position = 0;
                    //trace(bytes.readUTFBytes(bytes.length));
                    bytes.position = 0;
                    _parser.pushBytes(bytes);
                }

            } catch (e:*) {


                if (e is XMLSyntaxError) {

                    dispatchEvent(new XMPPErrorEvent(
                        XMPPErrorEvent.PROTOCOL_ERROR, "XML Syntax is invalid: " + e.message));

                } else if (e is XMLFragmentSizeOverError) {

                    dispatchEvent(new XMPPErrorEvent(
                        XMPPErrorEvent.PROTOCOL_ERROR, "XML fragment size is over."));

                } else if (e is XMLElementDepthOverError) {

                    dispatchEvent(new XMPPErrorEvent(
                        XMPPErrorEvent.PROTOCOL_ERROR, "XML depth is over."));

                } else if (e is XMPPProtocolError) {

                    dispatchEvent(new XMPPErrorEvent(
                        XMPPErrorEvent.PROTOCOL_ERROR, e.message));

                } else if (e is XMPPAuthError) {

                    dispatchEvent(new XMPPErrorEvent(
                        XMPPErrorEvent.AUTH_ERROR, e.message));

                } else {

                    disconnect();
                    throw e;

                }

                disconnect();

            }
        }
    }
}

