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
