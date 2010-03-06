package org.coderepos.net.xmpp
{
    import org.coderepos.xml.XMLElement;

    public class ChatState
    {
        public static const STARTING:String  = "starting";
        public static const ACTIVE:String    = "active";
        public static const COMPOSING:String = "composing";
        public static const PAUSED:String    = "paused";
        public static const INACTIVE:String  = "inactive";
        public static const GONE:String      = "gone";

        public static function getState(elem:XMLElement):String
        {
            if (elem.getFirstElementNS(XMPPNamespace.CHAT_STATE, STARTING) != null)
                return STARTING;
            if (elem.getFirstElementNS(XMPPNamespace.CHAT_STATE, ACTIVE) != null)
                return ACTIVE;
            if (elem.getFirstElementNS(XMPPNamespace.CHAT_STATE, COMPOSING) != null)
                return COMPOSING;
            if (elem.getFirstElementNS(XMPPNamespace.CHAT_STATE, PAUSED) != null)
                return PAUSED;
            if (elem.getFirstElementNS(XMPPNamespace.CHAT_STATE, INACTIVE) != null)
                return INACTIVE;
            if (elem.getFirstElementNS(XMPPNamespace.CHAT_STATE, GONE) != null)
                return GONE;
            return null;
        }

        private var _currentState:String;

        public function ChatState()
        {
            _currentState = STARTING;
        }

        public function active():void
        {
            if (!( _currentState == STARTING
                || _currentState == INACTIVE
                || _currentState == COMPOSING))
                throw new Error("'active' should be after STARTING/INACTIVE/COMPOSING");
            _currentState = ACTIVE;
        }

        public function gone():void
        {
            if (!( _currentState == ACTIVE
                || _currentState == INACTIVE
                || _currentState == PAUSED
                || _currentState == COMPOSING))
                throw new Error("'gone' should be after ACTIVE/PAUSED/INACTIVE/COMPOSING");
            _currentState = GONE;
        }

        public function composing():void
        {
            if (!( _currentState == ACTIVE
                || _currentState == PAUSED))
                throw new Error("'composing' should be after ACTIVE/PAUSED");
            _currentState = COMPOSING;

        }

        public function inactive():void
        {
            if (!( _currentState == ACTIVE
                || _currentState == PAUSED))
                throw new Error("'inactive' should be after ACTIVE/PAUSED");
            _currentState = INACTIVE;
        }

        public function paused():void
        {
            if (!( _currentState == INACTIVE
                || _currentState == COMPOSING))
                throw new Error("'paused' should be after INACTIVE/COMPOSING");
            _currentState = PAUSED;
        }

    }
}

