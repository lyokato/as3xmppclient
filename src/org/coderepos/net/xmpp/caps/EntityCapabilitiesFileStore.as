package org.coderepos.net.xmpp.caps
{
    public class EntityCapabilitiesFileStore implements IEntityCapabilitiesStore
    {
        private var _store:Object;

        public function EntityCapabilitiesFileStore()
        {
            _store = {};
            // load from file
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
            if (!(node in _store)) {
                _store[node] = cap;
                // save to file
            }
        }
    }
}

