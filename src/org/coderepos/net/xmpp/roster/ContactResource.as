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

package org.coderepos.net.xmpp.roster
{
    import org.coderepos.net.xmpp.XMPPPresence;
    import org.coderepos.net.xmpp.StatusType;

    public class ContactResource
    {
        private var _resource:String;
        private var _status:String;   // presence@status
        private var _show:String;     // presence@show
        private var _priority:uint;   // presence@priority

        // XEP-0115 Entity Capabilities
        private var _caps:Object;

        // XEP-0012 Last Activity
        private var _last:uint;

        // XEP-0085 Chat State Notification
        private var _chatState:String;

        public function ContactResource(resource:String, presence:XMPPPresence)
        {
            _resource  = resource;
            _chatState = null;
            _status    = presence.status;
            _show      = presence.show;
            _caps      = {};
        }

        public function updatePresence(presence:XMPPPresence):void
        {
            _status = presence.status;
            _show   = presence.show;
        }

        public function get isActive():Boolean
        {
            return (_status != null && _status == StatusType.CHAT);
        }

        public function get chatState():String
        {
            return _chatState;
        }

        public function set chatState(state:String):void
        {
            _chatState = state;
        }

        public function get status():String
        {
            return _status;
        }

        public function get show():String
        {
            return _show;
        }

        public function get resource():String
        {
            return _resource;
        }

        public function hasCap(capId:String):Boolean
        {
            return (capId in _caps);
        }

        public function setCap(capId:String):void
        {
            _caps[capId] = 1;
        }

        public function getCaps():Array
        {
            var caps:Array = [];
            for(var capId:String in _caps)
                caps.push(capId);
            return caps;
        }

    }
}

