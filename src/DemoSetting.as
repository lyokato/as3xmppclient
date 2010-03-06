package
{
    import flash.net.SharedObject;
    import flash.utils.ByteArray;
    import flash.desktop.NativeApplication;
    import flash.data.EncryptedLocalStore;

    import org.coderepos.net.xmpp.XMPPConfig;

    [Bindable]
    public class DemoSetting
    {
        public static function load():DemoSetting
        {

            var setting:DemoSetting = new DemoSetting();

            // load from SharedObject
            var so:SharedObject = SharedObject.getLocal(
                NativeApplication.nativeApplication.applicationID );

            // TODO: validation
            if ("host" in so.data)
                setting.host = so.data["host"];
            if ("port" in so.data)
                setting.port = so.data["port"];
            if ("username" in so.data)
                setting.username = so.data["username"];
            if ("resource" in so.data)
                setting.resource = so.data["resource"];
            if ("reconnectionAcceptableInterval" in so.data)
                setting.reconnectionAcceptableInterval = so.data["reconnectionAcceptableInterval"];
            if ("reconnectionMaxCountWithinInterval" in so.data)
                setting.reconnectionMaxCountWithinInterval = so.data["reconnectionMaxCountWithinInterval"];



            /* password should be encrypted!
            if (EncryptedLocalStore.getItem("password"))
                setting.password = b2s(EncryptedLocalStore.getItem("password"));
            */
            if ("password" in so.data)
                setting.password = so.data["password"];

            return setting;
        }

        public var host:String;
        public var port:uint;
        public var username:String;
        public var password:String;
        public var resource:String;
        public var reconnectionAcceptableInterval:uint;
        public var reconnectionMaxCountWithinInterval:uint;

        public function DemoSetting()
        {
            host     = "";
            port     = 5222;
            username = "";
            resource = "";
            reconnectionAcceptableInterval = 5;
            reconnectionMaxCountWithinInterval = 60 * 5;
        }

        public function genXMPPConfig():XMPPConfig
        {
            var s:XMPPConfig = new XMPPConfig();
            s.host     = host;
            s.port     = port;
            s.username = username;
            s.resource = resource;
            s.password = password;
            s.reconnectionAcceptableInterval     = reconnectionAcceptableInterval;
            s.reconnectionMaxCountWithinInterval = reconnectionMaxCountWithinInterval;
            return s;
        }

        public function save():void
        {
            // save to SharedObject
            var so:SharedObject = SharedObject.getLocal(
                NativeApplication.nativeApplication.applicationID );

            so.data["host"]     = host;
            so.data["port"]     = port;
            so.data["username"] = username;
            so.data["resource"] = resource;
            so.data["reconnectionAcceptableInterval"]     = reconnectionAcceptableInterval;
            so.data["reconnectionMaxCountWithinInterval"] = reconnectionMaxCountWithinInterval;

            /* password should be encrypted!
            EncryptedLocalStore.setItem("password", s2b(smtp_password));
            */
            so.data["password"] = password;
        }

        private static function b2s(b:ByteArray):String
        {
            b.position = 0;
            return b.readUTFBytes(b.length);
        }

        private static function s2b(s:String):ByteArray
        {
            var b:ByteArray = new ByteArray();
            b.writeUTFBytes(s);
            b.position = 0;
            return b;
        }
    }
}

