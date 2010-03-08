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
    import org.coderepos.net.xmpp.JID;
    import org.coderepos.net.xmpp.exceptions.XMPPProtocolError;
    import org.coderepos.xml.XMLElement;

    public class RosterItem
    {
        public static function fromElement(elem:XMLElement):RosterItem
        {
            var jidString:String = elem.getAttr("jid");
            if (jidString == null)
                throw new XMPPProtocolError("JID for roster elem not found.");
            var jid:JID;
            try {
                jid = new JID(jidString);
            } catch (e:*) {
                throw new XMPPProtocolError("Invalid JID format: " + jidString);
            }
            var item:RosterItem = new RosterItem(jid);
            var name:String = elem.getAttr("name");
            if (name != null)
                item.name = name;
            var subscription:String = elem.getAttr("subscription");
            if (subscription != null)
                item.subscription = subscription;
            var ask:String = elem.getAttr("ask");
            if (ask != null)
                item.ask = ask;

            var groups:Array = elem.getElements("group");
            for each(var group:XMLElement in groups) {
                item.addGroup(group.text);
            }
            return item;
        }

        private var _jid:JID;

        public var name:String;
        public var subscription:String;
        public var ask:String;

        private var _groups:Object;
        private var _resources:Object;

        /*

        // XEP-0153 vCard-Based Avatars
        private var _photoHash:String;
        private var _photoPath:String;

        */



        public function RosterItem(jid:JID):void
        {
            _jid       = jid;
            _groups    = {};
            _resources = {};
        }

        public function get jid():JID
        {
            return _jid;
        }

        public function addGroup(groupName:String):void
        {
            _groups[groupName] = 1;
        }

        public function belongsToGroup(groupName:String):Boolean
        {
            return (groupName in _groups);
        }

        public function hasResource(resource:String):Boolean
        {
            return (resource in _resources);
        }

        public function addResource(resource:RosterResource):void
        {
            _resources[resource.resource] = resource;
        }

        public function getResource(resource:String):RosterResource
        {
            return (resource in _resources) ? _resources[resource] : null;
        }

        public function removeResource(resource:String):void
        {
            delete _resources[resource];
        }

        public function get groups():Array
        {
            var groups:Array = [];
            for (var groupName:String in _groups)
                groups.push(groupName);
            return groups;
        }

        public function update(item:RosterItem):void
        {
            name         = item.name;
            subscription = item.subscription;
            ask          = item.ask;
            _groups      = [];
            for each(var groupName:String in item.groups) {
                addGroup(groupName);
            }
        }
    }
}

