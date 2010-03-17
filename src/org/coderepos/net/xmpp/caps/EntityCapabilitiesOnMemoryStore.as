package org.coderepos.net.xmpp.caps
{
    public class EntityCapabilitiesOnMemoryStore implements IEntityCapabilitiesStore
    {
        private var _store:Object;

        public function EntityCapabilitiesOnMemoryStore()
        {
            _store = {};
        }

        public function get(node:String):EntityCapabilities
        {
            return (node in _store) ? _store[node] : null;
        }

        public function has(node:String):Boolean
        {
            return (node in _store);
        }

        public function store(node:String, cap:EntityCapabilities):void
        {
            _store[node] = cap;
        }
    }
}

