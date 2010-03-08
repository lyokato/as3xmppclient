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
    import org.coderepos.net.xmpp.XMPPPresence;

    public class XMPPPresenceEvent extends Event
    {
        public static const RECEIVED:String = "presenceReceived";

        private var _presence:XMPPPresence;

        public function XMPPPresenceEvent(type:String, presence:XMPPPresence,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            _presence = presence;
            super(type, bubbles, cancelable);
        }

        public function get presence():XMPPPresence
        {
            return _presence;
        }

        override public function clone():Event
        {
            return new XMPPPresenceEvent(type, _presence, bubbles, cancelable);
        }
    }
}
