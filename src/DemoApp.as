package
{
    import flash.events.EventDispatcher;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.display.NativeWindow;
    import flash.desktop.NativeApplication;

    import nl.demonsters.debugger.MonsterDebugger;

    import org.coderepos.net.xmpp.XMPPConfig;
    import org.coderepos.net.xmpp.XMPPStream;
    import org.coderepos.net.xmpp.events.XMPPErrorEvent;

    public class DemoApp
    {
        private static var _app:DemoApp;

        public static function get app():DemoApp
        {
            if (_app == null)
                _app = new DemoApp();
            return _app;
        }

        private var _debugger:MonsterDebugger;
        private var _rootWindow:DemoXMPP;
        private var _setting:DemoSetting;
        private var _settingWindow:DemoSettingWindow;

        private var _conn:XMPPStream;

        public function DemoApp()
        {
           _debugger = new MonsterDebugger(this);
           _setting = DemoSetting.load();
        }

        public function get rootWindow():DemoXMPP
        {
            return _rootWindow;
        }

        public function set rootWindow(win:DemoXMPP):void
        {
            _rootWindow = win;
            _rootWindow.addEventListener(Event.CLOSING, shutDown);
        }

        private function shutDown(e:Event):void
        {
            saveSetting();
            closeAllWindows();
        }

        public function saveSetting():void
        {
            _setting.save();
        }

        private function closeAllWindows():void
        {
            var openedWindows:Array =
                NativeApplication.nativeApplication.openedWindows;
            for(var i:int = openedWindows.length - 1; i >= 0; --i) {
                var win:NativeWindow = openedWindows[i] as NativeWindow;
                win.close();
            }
        }

        public function openSettingWindow():void
        {
            if (_settingWindow == null || _settingWindow.closed) {
                _settingWindow = new DemoSettingWindow();
                _settingWindow.open();
                _settingWindow.setting = _setting;
            }
            _settingWindow.activate();
        }

        public function log(s:String):void
        {
            _rootWindow.log(s);
        }

        public function logLine(s:String):void
        {
            _rootWindow.logLine(s);
        }

        public function connect():void
        {
            var setting:XMPPConfig = _setting.genXMPPConfig();
            // TODO: validation
            _conn = new XMPPStream(setting);
            _conn.addEventListener(Event.CONNECT, connectHandler);
            _conn.addEventListener(Event.CLOSE, closeHandler);
            _conn.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _conn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _conn.addEventListener(XMPPErrorEvent.PROTOCOL_ERROR, protocolErrorHandler);
            _conn.start();
        }

        private function protocolErrorHandler(e:XMPPErrorEvent):void
        {
            logLine("[PROTOCOL_ERROR]");
            logLine(e.message);
        }

        private function connectHandler(e:Event):void
        {
            logLine("[CONNECTED]");
        }
        private function closeHandler(e:Event):void
        {
            logLine("[CONNECTION CLOSED]");
        }
        private function ioErrorHandler(e:IOErrorEvent):void
        {
            logLine("[IO_ERROR]");
            logLine(e.toString());
        }
        private function securityErrorHandler(e:SecurityErrorEvent):void
        {
            logLine("[SECURITY_ERROR]");
            logLine(e.toString());
        }
    }
}

