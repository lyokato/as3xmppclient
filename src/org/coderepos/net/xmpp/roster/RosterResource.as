package org.coderepos.net.xmpp.roster
{
    import org.coderepos.net.xmpp.ChatState;
    import org.coderepos.net.xmpp.EntityCapabilities;

    public class RosterResource
    {
        private var _resource:String;

        // XEP-0153 Entity Capabilities
        private var _capability:EntityCapabilities;

        // XEP-0012 Last Activity
        private var _last:uint;

        private var _chatState:ChatState;

        public function RosterResource(resource:String)
        {
            _resource  = resource;
            _chatState = new ChatState();
        }

        public function get resource():String
        {
            return _resource;
        }
    }
}

