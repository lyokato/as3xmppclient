package org.coderepos.net.xmpp
{
    public class XMPPConfig
    {
        public var host:String;
        public var port:uint;
        public var username:String;
        public var password:String;
        public var resource:String;
        public var reconnectionAcceptableInterval:uint;
        public var reconnectionMaxCountWithinInterval:uint;

        public var applicationName:String;
        public var applicationCategory:String;
        public var applicationType:String;
        public var applicationNode:String;
        public var applicationVersion:String;

        public function XMPPConfig()
        {
            host     = "";
            port     = 5222;
            username = "";
            resource = "";
            password = "";

            applicationName     = "as3xmppclient";
            applicationVersion  = "0.0.1";
            applicationNode     = "http://github.com/lyokato/as3xmppclient";
            applicationType     = "pc";
            applicationCategory = "client";

            reconnectionAcceptableInterval     = 5;
            reconnectionMaxCountWithinInterval = 60 * 5;

            // resourceBindingMaxRetryCount = 5;
            // xmlMaxElementDepth
            // xmlMaxFragmentSize
        }
    }
}

