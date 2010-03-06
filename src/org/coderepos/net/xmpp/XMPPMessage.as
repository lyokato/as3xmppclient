package org.coderepos.net.xmpp
{
    public class XMPPMessage
    {
        private var _from:JID;
        private var _type:String;
        private var _date:Date;
        private var _body:String;
        private var _subject:String;
        private var _thread:String;

        public function XMPPMessage(from:JID, type:String, date:Date,
            body:String, subject:String=null, thread:String=null)
        {
            _from    = from;
            _type    = type;
            _date    = date;
            _body    = body;
            _subject = subject;
            _thread  = thread;
        }

        public function get from():JID
        {
            return _from;
        }

        public function get type():String
        {
            return _type;
        }

        public function get date():Date
        {
            return _date;
        }

        public function get body():String
        {
            return _body;
        }

        public function get subject():String
        {
            return _subject;
        }

        public function get thread():String
        {
            return _thread;
        }
    }
}

