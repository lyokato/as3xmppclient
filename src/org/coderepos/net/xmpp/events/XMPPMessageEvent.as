package org.coderepos.net.xmpp.events
{
    import flash.events.Event;
    import org.coderepos.net.xmpp.XMPPMessage;

    public class XMPPMessageEvent extends Event
    {
        public static const RECEIVED:String = "messageReceived";

        private var _message:XMPPMessage;

        public function XMPPMessageEvent(type:String, message:XMPPMessage,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            _message = message;
            super(type, bubbles, cancelable);
        }

        public function get message():XMPPMessage
        {
            return _message;
        }

        override public function clone():Event
        {
            return new XMPPMessageEvent(type, _message, bubbles, cancelable);
        }
    }
}
