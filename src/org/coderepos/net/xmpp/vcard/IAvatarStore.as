package org.coderepos.net.xmpp.vcard
{
    import flash.utils.ByteArray;

    public interface IAvatarStore
    {
        function has(hash:String):Boolean;
        function store(type:String, hash:String, bytes:ByteArray):void;
        function get(hash:String):ByteArray;
    }
}

