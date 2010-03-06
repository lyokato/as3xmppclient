package org.coderepos.net.xmpp.events
{
    import flash.events.Event;
    import org.coderepos.net.xmpp.JID;

    public class XMPPSubscriptionEvent extends Event
    {
        public static const RECEIVED:String = "subscriptionReceived";

        private var _from:JID;

        public function XMPPSubscriptionEvent(type:String, from:JID,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            _from = from;
            super(type, bubbles, cancelable);
        }

        public function get from():JID
        {
            return _from;
        }

        override public function clone():Event
        {
            return new XMPPSubscriptionEvent(type, _from, bubbles, cancelable);
        }
    }
}
