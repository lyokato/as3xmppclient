package org.coderepos.net.xmpp.caps
{
    public interface IEntityCapabilitiesStore
    {
        function get(node:String):EntityCapabilities;
        function has(node:String):Boolean;
        function store(node:String, cap:EntityCapabilities):void;
    }
}

