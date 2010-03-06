package org.coderepos.net.xmpp.handler
{
    import org.coderepos.xml.sax.XMLElementEventHandler;
    import org.coderepos.xml.XMLElement;
    import org.coderepos.xml.XMLAttributes;

    import org.coderepos.net.xmpp.XMPPStream;
    import org.coderepos.net.xmpp.IQType;
    import org.coderepos.net.xmpp.XMPPServerFeatures;
    import org.coderepos.net.xmpp.XMPPNamespace;
    import org.coderepos.net.xmpp.roster.RosterItem;
    import org.coderepos.net.xmpp.exceptions.XMPPProtocolError;

    public class InitialRosterHandler implements IXMPPStreamHandler
    {
        private var _stream:XMPPStream;
        private var _currentIQID:String;

        public function InitialRosterHandler(stream:XMPPStream)
        {
            _stream = stream;
        }

        public function run():void
        {
            _stream.setXMLEventHandler(getHandler());
            _currentIQID = _stream.genNextID();
            _stream.send(
              '<iq type="' + IQType.GET + '" id="' + _currentIQID + '">'
            + '<query xmlns="' + XMPPNamespace.IQ_ROSTER + '"/>'
            + '</iq>'
            );
        }

        private function getHandler():XMLElementEventHandler
        {
            var handler:XMLElementEventHandler = new XMLElementEventHandler();
            handler.registerElementEvent(
                XMPPNamespace.CLIENT, "iq", 1, iqHandler);
            return handler;
        }

        private function iqHandler(elem:XMLElement):void
        {
            trace("[ROSTER:iq]");

            var type:String = elem.getAttr("type");
            if (type == null)
                throw new XMPPProtocolError("iq@type not found");
            var iqID:String = elem.getAttr("id");
            if (   type == IQType.RESULT
                && iqID != null
                && iqID == _currentIQID) {

                var query:XMLElement =
                    elem.getFirstElementNS(XMPPNamespace.IQ_ROSTER, "query");

                if (query == null)
                    throw new XMPPProtocolError("Roster query not found.");

                var items:Array = query.getElements("item");
                for each(var item:XMLElement in items) {
                    _stream.setRosterItem(RosterItem.fromElement(item));
                }

                trace("[ROSTER:success]");
                _stream.initiatedRoster();

            } else {
                throw new XMPPProtocolError("Failed to establish session.");
            }
        }
    }
}

