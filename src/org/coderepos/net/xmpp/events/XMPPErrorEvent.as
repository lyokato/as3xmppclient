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

package org.coderepos.net.xmpp.events
{
    import flash.events.Event;

    public class XMPPErrorEvent extends Event
    {
        public static const PROTOCOL_ERROR:String = "protocolError";
        public static const AUTH_ERROR:String = "authError";

        private var _message:String;

        public function XMPPErrorEvent(type:String, message:String=null,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            _message = message;
            super(type, bubbles, cancelable);
        }

        public function get message():String
        {
            return _message;
        }

        override public function clone():Event
        {
            return new XMPPErrorEvent(type, _message, bubbles, cancelable);
        }
    }
}
