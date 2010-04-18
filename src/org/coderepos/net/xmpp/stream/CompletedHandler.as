/*
Copyright (c) Lyo Kato (lyo.kato _at_ gmail.com)

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package org.coderepos.net.xmpp.stream
{
    import com.hurlant.crypto.Crypto;
    import com.hurlant.crypto.hash.IHash;
    import com.hurlant.util.Base64;
    import com.hurlant.util.Hex;

    import flash.system.Capabilities;
    import flash.utils.ByteArray;

    import org.coderepos.date.W3CDTF;
    import org.coderepos.net.xmpp.ChatState;
    import org.coderepos.net.xmpp.IQType;
    import org.coderepos.net.xmpp.JID;
    import org.coderepos.net.xmpp.MessageType;
    import org.coderepos.net.xmpp.PresenceType;
    import org.coderepos.net.xmpp.XMPPMessage;
    import org.coderepos.net.xmpp.XMPPNamespace;
    import org.coderepos.net.xmpp.XMPPPresence;
    import org.coderepos.net.xmpp.caps.EntityCapabilities;
    import org.coderepos.net.xmpp.exceptions.XMPPProtocolError;
    import org.coderepos.net.xmpp.roster.RosterItem;
    import org.coderepos.xml.XMLElement;
    import org.coderepos.xml.sax.XMLElementEventHandler;

    public class CompletedHandler implements IXMPPStreamHandler
    {
        private var _stream:XMPPStream;

        public function CompletedHandler(stream:XMPPStream)
        {
            _stream = stream;
        }

        public function run():void
        {
            _stream.setXMLEventHandler(getHandler());
            // send initial presence
            _stream.send('<presence>' + _stream.getPresenceCapsTag() + '</presence>');

            _stream.send(
                  '<iq type="' + IQType.GET
                    + '" to="' + _stream.boundJID.domain
                    + '" id="' + _stream.genNextID() + '">'
                + '<query xmlns="' + XMPPNamespace.DISCO_ITEMS + '"/>'
                + '</iq>'
            );
        }

        private function getHandler():XMLElementEventHandler
        {
            var handler:XMLElementEventHandler = new XMLElementEventHandler();
            handler.registerElementEvent(
                XMPPNamespace.CLIENT, "message", 1, messageHandler);
            handler.registerElementEvent(
                XMPPNamespace.CLIENT, "iq", 1, iqHandler);
            handler.registerElementEvent(
                XMPPNamespace.CLIENT, "presence", 1, presenceHandler);
            return handler;
        }

        private function messageHandler(elem:XMLElement):void
        {
            // type is optional
            var type:String = elem.getAttr("type");
            var senderSrc:String = elem.getAttr("from");
            if (senderSrc == null)
                throw new XMPPProtocolError("message@from not found");

            var sender:JID;
            try {
                sender = new JID(senderSrc);
            } catch (e:*) {
                throw new XMPPProtocolError("message@from jid is invalid: " + senderSrc);
            }

            /* need to check 'to'?
               TODO: check MUC spec.
               var to:String = elem.getAttr('to')
            */

            var state:String = ChatState.getState(elem);

            if (   type  != null
                && type  == MessageType.CHAT
                && state != null )
                _stream.changedChatState(sender, state);

            if (type == null) {
                // search type by context,
                // and not found
                type = MessageType.NORMAL;
            }

            // import org.coderepos.xml.XMLUtil;
            // // should do this here?
            // subject = XMLUtil.unescapeXMLChar(subject);
            // body    = XMLUtil.unescapeXMLChar(body);

            var bodyElem:XMLElement =
                elem.getFirstElement("body");
            var body:String = (bodyElem != null)
                ? bodyElem.text : null;

            if (body == null)
                return;

            var subjectElem:XMLElement =
                elem.getFirstElement("subject");
            var subject:String = (subjectElem != null)
                ? subjectElem.text : null;

            var threadElem:XMLElement =
                elem.getFirstElement("thread");
            var thread:String = (threadElem != null)
                ? threadElem.text : null;

            var date:Date = new Date();

            // TODO: [XEP-0071 XHTML-IM]
            // var html:XMLElement = elem.getFirstElementNS(XMPPNamespace.XHTML_IM, "html");

            // [XEP-0091] Legacy Delayed Delivery
            // [XEP-0203] Delayed Delivery
            var x:XMLElement = elem.getFirstElementNS(XMPPNamespace.DELAY, "delay");
            if (x == null)
                x = elem.getFirstElementNS(XMPPNamespace.LEGACY_DELAY, "x");
            if (x != null) {
                var xFrom:String  = x.getAttr("from");
                if (xFrom != null) {
                    var xSender:JID;
                    try {
                        xSender = new JID(xFrom);
                        sender = xSender;
                    } catch (e:Error) { }
                }
                var xStamp:String = x.getAttr("stamp");
                if (xStamp != null) {
                    var xDate:Date;
                    try {
                        xDate = W3CDTF.parse(xStamp);
                        date = xDate;
                    } catch (e:Error) { }
                }
            }

            var message:XMPPMessage = new XMPPMessage(
                sender, type, date, body, subject, thread);

            _stream.receivedMessage(message);
        }

        private function presenceHandler(elem:XMLElement):void
        {
            var type:String = elem.getAttr("type");
            if (type == null)
                type = "";

            switch (type) {
                case PresenceType.AVAILABLE:
                case PresenceType.UNAVAILABLE:
                    handlePresence(type, elem);
                    break;
                case PresenceType.SUBSCRIBE:
                case PresenceType.UNSUBSCRIBE:
                    handleSubscriptionRequest(type, elem);
                    break;
                case PresenceType.SUBSCRIBED:
                case PresenceType.UNSUBSCRIBED:
                    handleSubscriptionResponse(type, elem);
                    break;
                //case PresenceType.PROBE:
                case PresenceType.ERROR:
                    break;
            }
        }

        private function handleSubscriptionRequest(type:String, elem:XMLElement):void
        {
            var senderSrc:String = elem.getAttr("from");
            if (senderSrc == null)
                throw new XMPPProtocolError("presence@from not found");
            var sender:JID;
            try {
                sender = new JID(senderSrc);
            } catch (e:*) {
                throw new XMPPProtocolError(
                    "presence@from is invalid JID: " + senderSrc);
            }

            if (type == PresenceType.SUBSCRIBE) {

                _stream.receivedSubscriptionRequest(sender);

            } else {

                // UNSUBSCRIBE request
                // TODO: process it automatically?

                _stream.send(
                    '<presence to="' + sender.toBareJIDString()
                        + '" type="' + PresenceType.UNSUBSCRIBED + '" />'
                );
            }
        }

        private function handleSubscriptionResponse(type:String, elem:XMLElement):void
        {
            var senderSrc:String = elem.getAttr("from");
            if (senderSrc == null)
                throw new XMPPProtocolError("presence@from not found");
            var sender:JID;
            try {
                sender = new JID(senderSrc);
            } catch (e:*) {
                throw new XMPPProtocolError(
                    "presence@from is invalid JID: " + senderSrc);
            }

            /* needed?
            if (type == PresenceType.UNSUBSCRIBED) {
                _stream.send(
                    '<presence to="' + sender.toBareJIDString()
                        + '" type="' + PresenceType.UNSUBSCRIBE + '"/>' 
                );
            } else {

            }
            */
            _stream.receivedSubscriptionResponse(sender, type);
        }

        private function handlePresence(type:String, elem:XMLElement):void
        {
            var senderSrc:String = elem.getAttr("from");
            if (senderSrc == null)
                throw new XMPPProtocolError("presence@from not found");

            var sender:JID;
            try {
                sender = new JID(senderSrc);
            } catch (e:*) {
                throw new XMPPProtocolError(
                    "presence@from is invalid JID: " + senderSrc);
            }

            if (type == PresenceType.UNAVAILABLE) {
                _stream.receivedUnavailablePresence(sender);
                return;
            }

            var showElem:XMLElement = elem.getFirstElement("show");
            var show:String = (showElem != null)
                ? showElem.text : "";

            var statusElem:XMLElement = elem.getFirstElement("status");
            var status:String = (statusElem != null)
                ? statusElem.text : "";

            var priElem:XMLElement = elem.getFirstElement("priority");
            var priority:int = (priElem != null)
                ? int(priElem.text) : 0;

            _stream.receivedPresence(new XMPPPresence(
                sender, show, status, priority));

            // [XEP-0115 Entity Capabilities]
            var c:XMLElement = elem.getFirstElementNS(XMPPNamespace.CAPS, "c");
            if (c != null)
                checkCap(sender, c);

            // [XEP-0153: vCard-Based Avatars]
            var x:XMLElement = elem.getFirstElementNS(XMPPNamespace.VCARD_UPDATE, "x");
            if (x != null)
                checkVcard(sender, x);
        }

        private function checkVcard(sender:JID, x:XMLElement):void
        {
            var photo:XMLElement = x.getFirstElement("photo");
            if (photo != null) {
                var photoHash:String = photo.text;
                if (photoHash != null && photoHash.length > 0) {
                    if (_stream.hasAvatar(photoHash)) {
                        trace("found avatar for: " + photoHash);
                        _stream.setContactAvatar(sender, photoHash);
                    } else {
                        //trace("not found avatar for: " + photoHash);
                        _stream.send(
                              '<iq to="' + sender.toBareJIDString()
                                + '" id="' + _stream.genNextID()
                                + '" type="' + IQType.GET + '">'
                            + '<vCard xmlns="' + XMPPNamespace.VCARD + '"/>'
                            + '</iq>'
                        );
                    }
                }
            }
        }

        private function checkCap(sender:JID, c:XMLElement):void
        {
            var node:String = c.getAttr("node");
            var ver:String  = c.getAttr("ver");

            // invalid form of element
            if (node == null || ver == null)
                return;

            var hash:String = c.getAttr("hash");

            var senderSrc:String = sender.toString();

            var capId:String = node + '#' + ver;
            if (_stream.hasCap(capId)) {
                trace("found capabilities: " + capId);
                _stream.setContactCap(sender, capId);
            } else {
                //trace("not found capabilities: " + capId);
                _stream.send(
                      '<iq id="' + _stream.genNextID()
                        + '" to="' + senderSrc + '" type="' + IQType.GET + '">'
                    + '<query xmlns="' + XMPPNamespace.DISCO_INFO
                        + '" node="' + capId + '"/>'
                    + '</iq>'
                );
            }

            var exts:String = c.getAttr("ext");
            if (exts != null) {
                var extParts:Array = exts.split(/\s+/);
                for each(var ext:String in extParts) {
                    var extCapId:String = node + '#' + ext;
                    if (_stream.hasCap(extCapId)) {
                        trace("found capabilities: " + extCapId);
                        _stream.setContactCap(sender, extCapId);
                    } else {
                        //trace("not found capabilities: " + extCapId);
                        _stream.send(
                              '<iq id="' + _stream.genNextID()
                                + '" to="' + senderSrc + '" type="' + IQType.GET + '">'
                            + '<query xmlns="' + XMPPNamespace.DISCO_INFO
                                + '" node="' + extCapId + '"/>'
                            + '</iq>'
                        );
                    }
                }
            }
        }

        private function iqHandler(elem:XMLElement):void
        {
            if (elem.getFirstElementNS(XMPPNamespace.IQ_ROSTER, "query") != null) {
                handleRosterIQ(elem);
            } else if (elem.getFirstElementNS(XMPPNamespace.IQ_PRIVACY, "query") != null) {
                handlePrivacyIQ(elem);
            } else if (elem.getFirstElementNS(XMPPNamespace.BLOCKING, "block") != null) {
                handleBlockingIQ(elem);
            } else if (elem.getFirstElementNS(XMPPNamespace.VCARD, "vCard") != null) {
                handleVcardIQ(elem);
            } else if (elem.getFirstElementNS(XMPPNamespace.DISCO_INFO, "query") != null) {
                handleDiscoInfoIQ(elem);
            } else if (elem.getFirstElementNS(XMPPNamespace.DISCO_ITEMS, "query") != null) {
                handleDiscoItemsIQ(elem);
            } else if (elem.getFirstElementNS(XMPPNamespace.IQ_VERSION, "query") != null) {
                handleVersionIQ(elem);
            } else if (elem.getFirstElementNS(XMPPNamespace.IQ_LAST, "query") != null) {
                handleLastIQ(elem);
            } else {
                handleUnknownIQ(elem);
            }
        }

        private function handleLastIQ(elem:XMLElement):void
        {
            //trace("[iq:last]");
            var type:String = elem.getAttr("type");
            if (type == null)
                throw new XMPPProtocolError("iq@type not found");

            var sender:String = elem.getAttr("from");
            if (sender == null)
                throw new XMPPProtocolError("iq@from not found");

            if (type == IQType.GET) {
                var iqid:String = elem.getAttr("id");
                if (iqid == null)
                    throw new XMPPProtocolError("iq@id not found");
                /*
                _stream.send(
                      '<iq id="' + iqid + '" to="' + sender + '" type="' + IQType.RESULT + '">'
                    + '<query xmlns="' + XMPPNamespace.IQ_LAST + '" seconds="' + idleSeconds + '">'
                    + '</query>'
                    + '</iq>'
                );
                */
                _stream.send(
                      '<iq id="' + iqid + '" to="' + sender + '" type="' + IQType.RESULT + '">'
                    + '<error type="cancel">'
                    + '<service-unavailable xmlns="' + XMPPNamespace.STANZA + '"/>'
                    + '</error>'
                    + '</iq>'
                );
            } else if (type == IQType.RESULT) {
                var senderJID:JID;
                try {
                    senderJID = new JID(sender);
                } catch (e:Error) {
                    throw new XMPPProtocolError("iq@from is invalid JID: " + sender);
                }
                var query:XMLElement = elem.getFirstElementNS(XMPPNamespace.IQ_LAST, "query");
                var seconds:String = query.getAttr("seconds");
                if (seconds != null)
                    _stream.gotLastSeconds(senderJID, uint(seconds));
            }
        }

        private function handleVersionIQ(elem:XMLElement):void
        {
            //trace("[iq:version]");
            var type:String = elem.getAttr("type");
            if (type == null)
                throw new XMPPProtocolError("iq@type not found");

            var senderSrc:String = elem.getAttr("from");
            if (senderSrc == null)
                throw new XMPPProtocolError("iq@from not found");

            if (type == IQType.GET) {
                var iqid:String = elem.getAttr("id");
                if (iqid == null)
                    throw new XMPPProtocolError("iq@id not found");

                _stream.send(
                      '<iq id="' + iqid + '" to="' + senderSrc + '" type="' + IQType.RESULT + '">'
                    + '<query xmlns="' + XMPPNamespace.IQ_VERSION + '">'
                    + '<name>' + _stream.applicationName + '</name>'
                    + '<version>' + _stream.applicationVersion + '</version>'
                    + '<os>' + Capabilities.os + '</os>'
                    + '</query>'
                    + '</iq>'
                );
            } else if (type == IQType.RESULT) {
                var sender:JID;
                try {
                    sender = new JID(senderSrc);
                } catch (e:Error) {
                    throw new XMPPProtocolError(
                        "iq@from is invalid JID: " + senderSrc);
                }
                var query:XMLElement =
                    elem.getFirstElementNS(XMPPNamespace.IQ_VERSION, "query");
                var nameElem:XMLElement = query.getFirstElement("name");
                var name:String = (nameElem != null) ? nameElem.text : "";
                var verElem:XMLElement = query.getFirstElement("version");
                var version:String = (verElem != null) ? verElem.text : "";
                var osElem:XMLElement = query.getFirstElement("os");
                var os:String = (osElem != null) ? osElem.text : "";
                _stream.gotVersion(sender, name, version, os);
            }
        }

        private function handleDiscoItemsIQ(elem:XMLElement):void
        {
            //trace("[iq:disco:items]");
            var type:String = elem.getAttr("type");
            if (type == null)
                throw new XMPPProtocolError("iq@type not found");

            var sender:String = elem.getAttr("from");
            if (sender == null)
                throw new XMPPProtocolError("iq@from not found");

            if (type == IQType.RESULT) {
                if (sender == _stream.boundJID.domain) {
                    var query:XMLElement =
                        elem.getFirstElementNS(XMPPNamespace.DISCO_ITEMS, "query");
                    var items:Array = query.getElements("item");
                    for each(var itemElem:XMLElement in items) {
                        var serviceJID:String = itemElem.getAttr("jid");
                        if (serviceJID != null) {
                            _stream.addService(serviceJID);
                            _stream.send(
                                  '<iq id="' + _stream.genNextID()
                                    + '" to="' + serviceJID
                                    + '" type="' + IQType.GET + '">'
                                + '<query xmlns="' + XMPPNamespace.DISCO_INFO + '"/>'
                                + '</iq>'
                            );
                        }
                    }
                } else {

                }
            }
        }
        private function handleDiscoInfoIQ(elem:XMLElement):void
        {
            //trace("[iq:disco:info]");
            var type:String = elem.getAttr("type");
            if (type == null)
                throw new XMPPProtocolError("iq@type not found");

            var sender:String = elem.getAttr("from");
            if (sender == null)
                throw new XMPPProtocolError("iq@from not found");

            var query:XMLElement =
                elem.getFirstElementNS(XMPPNamespace.DISCO_INFO, "query");
            var node:String = query.getAttr("node");

            if (type == IQType.GET) {
                var iqid:String = elem.getAttr("id");
                if (iqid == null)
                    throw new XMPPProtocolError("iq@id not found");

                var queryTag:String = '<query xmlns="' + XMPPNamespace.DISCO_INFO + '"'
                if (node != null)
                    queryTag += ' node="' + node + '"'
                queryTag += '>';

                _stream.send(
                      '<iq id="' + iqid + '" to="' + sender + '" type="' + IQType.RESULT + '">'
                    + queryTag
                    + _stream.getDiscoInfoFeatureTags()
                    + '</query>'
                    + '</iq>'
                );
            } else if (type == IQType.RESULT) {
                if (_stream.hasService(sender)) {
                    // service info
                    //trace('[service info]');
                } else {
                    //trace('[contact info]');
                    // contact info
                    if (node != null) {
                        // response for Entity Capabilities
                        // save the capabilities with hash
                        var cap:EntityCapabilities = EntityCapabilities.fromElement(query);
                        if (cap != null) {
                            //trace("got capabilities");
                            _stream.storeCap(node, cap);
                        } else {
                            //trace("invalid capabilities");
                        }
                    }
                }
            }
        }

        private function handleVcardIQ(elem:XMLElement):void
        {
            //trace("[iq:vcard]");
            var vcard:XMLElement =
                elem.getFirstElementNS(XMPPNamespace.VCARD, "vCard");

            var type:String = elem.getAttr("type");
            if (type == null)
                throw new XMPPProtocolError("iq@type not found");

            var senderSrc:String = elem.getAttr("from");
            if (senderSrc == null)
                throw new XMPPProtocolError("message@from not found");

            var sender:JID;
            try {
                sender = new JID(senderSrc);
            } catch (e:*) {
                throw new XMPPProtocolError("message@from jid is invalid: " + senderSrc);
            }

            if (type == IQType.RESULT) {
                // set avatar
                var photoElem:XMLElement = vcard.getFirstElement("PHOTO");
                if (photoElem == null)
                    return;
                var typeElem:XMLElement = photoElem.getFirstElement("TYPE");
                var binElem:XMLElement = photoElem.getFirstElement("BINVAL");
                if (typeElem == null || binElem == null)
                    return;
                var photoBytes:ByteArray = Base64.decodeToByteArray(binElem.text);
                var hasher:IHash = Crypto.getHash("sha1");
                var avatarHash:String = Hex.fromArray(hasher.hash(photoBytes));
                _stream.saveAvatar(typeElem.text, avatarHash, photoBytes);
                _stream.setContactAvatar(sender, avatarHash);
            }

        }

        private function handleBlockingIQ(elem:XMLElement):void
        {
            //trace("[iq:block]");
            var block:XMLElement =
                elem.getFirstElementNS(XMPPNamespace.BLOCKING, "block");

            block.getElements("item");
        }

        private function handlePrivacyIQ(elem:XMLElement):void
        {
            //trace("[iq:privacy]");
            var query:XMLElement =
                elem.getFirstElementNS(XMPPNamespace.IQ_PRIVACY, "query");

            query.getFirstElement("active");
            query.getFirstElement("default");
            query.getElements("list");
        }

        private function handleRosterIQ(elem:XMLElement):void
        {
            //trace("[iq:roster]");
            var type:String = elem.getAttr("type");
            if (type == null)
                throw new XMPPProtocolError("iq@type not found");

            if (type == IQType.SET) {
                // roster push
                var query:XMLElement =
                    elem.getFirstElementNS(XMPPNamespace.IQ_ROSTER, "query");
                var items:Array = query.getElements("item");
                for each(var item:XMLElement in items) {
                    _stream.setRosterItem(RosterItem.fromElement(item));
                }
                var iqid:String = elem.getAttr("id");
                if (iqid != null) {
                    _stream.send('<iq type="result" id="' + iqid + '"/>');
                }

            } else if (type == IQType.RESULT) {
                // do something?
            }
        }

        private function handleUnknownIQ(elem:XMLElement):void
        {
            // TODO: do something?
        }
    }
}

