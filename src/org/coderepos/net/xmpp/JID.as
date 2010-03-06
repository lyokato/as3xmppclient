package org.coderepos.net.xmpp
{
    public class JID
    {
        private var _node:String;
        private var _domain:String;
        private var _resource:String;

        public function JID(jid:String)
        {
            var parts:Array = jid.split("@");
            if (parts.length != 2)
                throw new Error("Invalid JID format");

            _node = parts[0];

            parts = parts[1].split("/");

            _domain = parts[0];
            if (parts.length > 1)
                _resource = parts[1];
        }

        public function get node():String
        {
            return _node;
        }

        public function get domain():String
        {
            return _domain;
        }

        public function get resource():String
        {
            return _resource;
        }

        public function get isBareJID():Boolean
        {
            return (_resource == null);
        }

        public function toBareJID():JID
        {
            return new JID(toBareJIDString());
        }

        public function valueOf():String
        {
            return toString();
        }

        public function toBareJIDString():String
        {
            return _node + '@' + _domain;
        }

        public function toString():String
        {
            var str:String = _node + "@" + _domain;
            if (_resource != null && _resource.length > 0)
                str += "/";
                str += _resource;
            return str;
        }

    }
}

