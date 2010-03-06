package org.coderepos.net.xmpp
{
    public class XMPPPresence
    {
        private var _from:JID;
        private var _isAvailable:Boolean;
        private var _show:String;
        private var _status:String;
        private var _priority:int;

        public function XMPPPresence(from:JID, isAvailable:Boolean,
            show:String="", status:String="", priority:int=0)
        {
            _from        = from;
            _isAvailable = isAvailable;
            _show        = show;
            _status      = status;
            _priority    = priority;
        }

        public function get from():JID
        {
            return _from;
        }

        public function get isAvailable():Boolean
        {
            return _isAvailable;
        }

        public function get show():String
        {
            return _show;
        }

        public function get status():String
        {
            return _status;
        }

        public function get priority():int
        {
            return _priority;
        }
    }
}

