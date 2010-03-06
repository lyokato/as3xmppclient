package org.coderepos.net.xmpp.events
{
    import flash.events.Event;

    public class XMPPErrorEvent extends Event
    {
        public static const PROTOCOL_ERROR:String = "protocolError";

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
