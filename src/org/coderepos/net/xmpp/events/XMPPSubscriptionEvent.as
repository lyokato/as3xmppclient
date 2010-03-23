/*
Copyright (c) Lyo Kato (lyo.kato _at_ gmail.com)

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING contact, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package org.coderepos.net.xmpp.events
{
    import flash.events.Event;
    import org.coderepos.net.xmpp.JID;

    public class XMPPSubscriptionEvent extends Event
    {
        public static const RECEIVED:String = "subscriptionReceived";

        private var _contact:JID;

        public function XMPPSubscriptionEvent(type:String, contact:JID,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            _contact = contact;
            super(type, bubbles, cancelable);
        }

        public function get contact():JID
        {
            return _contact;
        }

        override public function clone():Event
        {
            return new XMPPSubscriptionEvent(type, _contact, bubbles, cancelable);
        }
    }
}
