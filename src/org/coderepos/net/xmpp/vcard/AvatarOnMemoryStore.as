package org.coderepos.net.xmpp.vcard
{
    import flash.utils.ByteArray;

    public class AvatarOnMemoryStore implements IAvatarStore
    {
        private var _store:Object;

        public function AvatarOnMemoryStore()
        {
            _store = {};
        }

        public function has(hash:String):Boolean
        {
            return (hash in _store);
        }

        // XXX: should save content-type
        public function store(type:String, hash:String, bytes:ByteArray):void
        {
            _store[hash] = bytes;
        }

        // XXX: should return content-type
        public function get(hash:String):ByteArray
        {
           return (hash in _store) ? _store[hash] : null; 
        }
    }
}

