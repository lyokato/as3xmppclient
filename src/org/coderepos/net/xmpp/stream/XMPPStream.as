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
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.utils.ByteArray;

    import org.coderepos.net.xmpp.IQType;
    import org.coderepos.net.xmpp.JID;
    import org.coderepos.net.xmpp.MessageType;
    import org.coderepos.net.xmpp.PresenceType;
    import org.coderepos.net.xmpp.SubscriptionType;
    import org.coderepos.net.xmpp.XMPPConfig;
    import org.coderepos.net.xmpp.XMPPConnection;
    import org.coderepos.net.xmpp.XMPPMessage;
    import org.coderepos.net.xmpp.XMPPNamespace;
    import org.coderepos.net.xmpp.XMPPPresence;
    import org.coderepos.net.xmpp.caps.EntityCapabilities;
    import org.coderepos.net.xmpp.caps.EntityCapabilitiesOnMemoryStore;
    import org.coderepos.net.xmpp.caps.IEntityCapabilitiesStore;
    import org.coderepos.net.xmpp.events.XMPPErrorEvent;
    import org.coderepos.net.xmpp.events.XMPPMessageEvent;
    import org.coderepos.net.xmpp.events.XMPPPresenceEvent;
    import org.coderepos.net.xmpp.events.XMPPRosterEvent;
    import org.coderepos.net.xmpp.events.XMPPStreamEvent;
    import org.coderepos.net.xmpp.events.XMPPSubscriptionEvent;
    import org.coderepos.net.xmpp.exceptions.XMPPProtocolError;
    import org.coderepos.net.xmpp.roster.ContactResource;
    import org.coderepos.net.xmpp.roster.RosterItem;
    import org.coderepos.net.xmpp.util.IDGenerator;
    import org.coderepos.net.xmpp.util.ReconnectionManager;
    import org.coderepos.net.xmpp.vcard.AvatarOnMemoryStore;
    import org.coderepos.net.xmpp.vcard.IAvatarStore;
    import org.coderepos.sasl.SASLMechanismDefaultFactory;
    import org.coderepos.sasl.SASLMechanismFactory;
    import org.coderepos.sasl.mechanisms.ISASLMechanism;
    import org.coderepos.xml.sax.XMLElementEventHandler;

    public class XMPPStream extends EventDispatcher
    {
        private var _config:XMPPConfig;
        private var _connection:XMPPConnection;
        private var _handler:IXMPPStreamHandler;
        private var _attributes:Object;
        private var _features:XMPPServerFeatures;
        private var _saslFactory:SASLMechanismFactory;
        private var _jid:JID;
        private var _boundJID:JID;
        private var _idGenerator:IDGenerator;
        private var _reconnectionManager:ReconnectionManager;
        private var _roster:Object;
        private var _services:Object;
        private var _isReady:Boolean;
        private var _capStore:IEntityCapabilitiesStore;
        private var _avatarStore:IAvatarStore;

        public function XMPPStream(config:XMPPConfig,
            capStore:IEntityCapabilitiesStore=null,
            avatarStore:IAvatarStore=null)
        {
            _config      = config;
            _attributes  = {};
            _roster      = {};
            _services    = {};
            _isReady     = false;
            _features    = new XMPPServerFeatures();
            // XXX: JID validation ?
            _jid         = new JID(_config.username);
            _idGenerator = new IDGenerator("req:", 5);
            _saslFactory = new SASLMechanismDefaultFactory(
                _jid.node, _config.password, null, "xmpp", _config.host);
            _reconnectionManager = new ReconnectionManager(
                _config.reconnectionAcceptableInterval,
                _config.reconnectionMaxCountWithinInterval
            );
            _capStore = (capStore == null)
                ? new EntityCapabilitiesOnMemoryStore() : capStore;
            _avatarStore = (avatarStore == null)
                ? new AvatarOnMemoryStore() : avatarStore;
        }

        internal function get applicationName():String
        {
            return _config.applicationName;
        }

        internal function get applicationVersion():String
        {
            return _config.applicationVersion;
        }

        internal function get applicationNode():String
        {
            return _config.applicationNode;
        }

        internal function get applicationType():String
        {
            return _config.applicationType;
        }

        internal function get applicationCategory():String
        {
            return _config.applicationCategory;
        }

        internal function genNextID():String
        {
            return _idGenerator.generate();
        }

        internal function get domain():String
        {
            return _jid.domain;
        }

        internal function set features(features:XMPPServerFeatures):void
        {
            _features = features;
        }

        public function getAttribute(key:String):String
        {
            return (key in _attributes) ? _attributes[key] : null;
        }

        public function setAttribute(key:String, value:String):void
        {
            _attributes[key] = value;
        }

        public function get connected():Boolean
        {
            return (_connection != null && _connection.connected);
        }

        public function start():void
        {
            if (connected)
                throw new Error("already connected.");

            _connection = new XMPPConnection(_config);
            _connection.addEventListener(Event.CONNECT, connectHandler);
            _connection.addEventListener(Event.CLOSE, closeHandler);
            _connection.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _connection.addEventListener(XMPPErrorEvent.PROTOCOL_ERROR, protocolErrorHandler);
            _connection.addEventListener(XMPPErrorEvent.AUTH_ERROR, authErrorHandler);
            _connection.connect();

            dispatchEvent(new XMPPStreamEvent(XMPPStreamEvent.START));
        }

        public function send(s:String):void
        {
            if (connected)
                _connection.send(s);
        }

        internal function setXMLEventHandler(handler:XMLElementEventHandler):void
        {
            if (connected)
                _connection.setXMLEventHandler(handler);
        }

        internal function dispose():void
        {
            _handler = null;
            _isReady = false;
        }

        internal function clearBuffer():void
        {
            //trace("[CLEAR BUFFER]");
            if (_connection != null)
                _connection.clearBuffer();
        }

        public function disconnect():void
        {
            if (connected) {
                if (_isReady) {
                    send('<presence type="' + PresenceType.UNAVAILABLE + '"/>');
                    send('</stream:stream>');
                }
                _connection.disconnect();
                dispose();
                dispatchEvent(new Event(Event.CLOSE));
            } else {
                dispose();
            }
        }

        internal function changeState(handler:IXMPPStreamHandler):void
        {
            _handler = handler;
            _handler.run();
        }

        internal function initiated():void
        {
            if (_features.supportTLS) {
                dispatchEvent(new XMPPStreamEvent(XMPPStreamEvent.TLS_NEGOTIATING));
                changeState(new TLSHandler(this));
            } else {
                var mech:ISASLMechanism = findProperSASLMechanism();
                if (mech != null) {
                    dispatchEvent(new XMPPStreamEvent(XMPPStreamEvent.AUTHENTICATING));
                    changeState(new SASLHandler(this, mech));
                } else {
                    // XXX: Accept anonymous ?
                    throw new XMPPProtocolError(
                        "Server doesn't support SASL mechanisms which this library supports.");
                }
            }
        }

        internal function switchToTLS():void
        {
            if (connected)
                _connection.startTLS();
        }

        internal function tlsNegotiated():void
        {
            var mech:ISASLMechanism = findProperSASLMechanism();
            if (mech != null) {
                dispatchEvent(new XMPPStreamEvent(XMPPStreamEvent.AUTHENTICATING));
                changeState(new SASLHandler(this, mech));
            } else {
                // XXX: Accept anonymous ?
                throw new XMPPProtocolError(
                    "Server doesn't support SASL mechanisms which this library supports.");
            }
        }

        internal function authenticated():void
        {
            if (_features.supportResourceBinding) {
                dispatchEvent(new XMPPStreamEvent(XMPPStreamEvent.BINDING_RESOURCE));
                changeState(new ResourceBindingHandler(this, _config.resource,
                    _config.resourceBindingMaxRetryCount));
            } else {
                // without Binding
                throw new XMPPProtocolError(
                    "Server doesn't support resource-binding");
            }
        }

        public function get boundJID():JID
        {
            return _boundJID;
        }

        internal function bindJID(jid:JID):void
        {
            _boundJID = jid;
            if (_features.supportSession) {
                dispatchEvent(new XMPPStreamEvent(XMPPStreamEvent.ESTABLISHING_SESSION));
                changeState(new SessionEstablishmentHandler(this));
            } else {
                dispatchEvent(new XMPPStreamEvent(XMPPStreamEvent.LOADING_ROSTER));
                changeState(new InitialRosterHandler(this));
            }
        }

        internal function establishedSession():void
        {
            dispatchEvent(new XMPPStreamEvent(XMPPStreamEvent.LOADING_ROSTER));
            changeState(new InitialRosterHandler(this));
        }

        internal function addService(serviceJID:String):void
        {
            _services[serviceJID] = null;
        }

        internal function hasService(serviceJID:String):Boolean {
            return (serviceJID in _services);
        }

        public function get roster():Object
        {
            // should make iterator to encupsulate?
            return _roster;
        }

        public function getRosterItem(jid:JID):RosterItem
        {
            var bareJID:String = jid.toBareJIDString();
            return (bareJID in _roster) ? _roster[bareJID] : null;
        }

        public function getContactResource(jid:JID):ContactResource
        {
            var resource:String = jid.resource;
            if (resource == null || resource.length == 0)
                return null;
                //throw new ArgumentError("This is not full JID: " + jid.toString());
            var item:RosterItem = getRosterItem(jid);
            if (item == null)
                return null;
            return item.getResource(resource);
        }

        internal function initiatedRoster():void
        {
            dispatchEvent(new XMPPStreamEvent(XMPPStreamEvent.READY));
            changeState(new CompletedHandler(this));
            _isReady = true;
        }

        private function findProperSASLMechanism():ISASLMechanism
        {
            if (!_features.supportSASL)
                return null;
            var mech:ISASLMechanism = null;
            for each(var mechName:String in _features.saslMechs) {
                //trace(mechName);
                mech = _saslFactory.getMechanism(mechName);
                if (mech != null)
                    break;
            }
            return mech;
        }

        internal function getPresenceCapsTag():String
        {
            return _config.buildPresenceCapsTag();
        }

        internal function getDiscoInfoFeatureTags():String
        {
            return _config.buildDiscoInfoFeatureTags();
        }

        internal function setRosterItem(rosterItem:RosterItem):void
        {
            var contact:JID = rosterItem.jid;
            var bareJID:String = contact.toBareJIDString();
            if (bareJID in _roster) {
                _roster[bareJID].updateItem(rosterItem);
            } else {
                _roster[bareJID] = rosterItem;
            }
            dispatchEvent(new XMPPRosterEvent(XMPPRosterEvent.CHANGED, contact));
        }

        internal function changedChatState(contact:JID, state:String):void
        {
            //var bareJID:String = contact.toBareJIDString();
            var resource:String  = contact.resource;
            if (resource == null) {
                // invalid format
                return;
            }

            var res:ContactResource = getContactResource(contact);
            if (res != null && res.chatState != state) {
                res.chatState = state;
                dispatchEvent(new XMPPPresenceEvent(
                    XMPPPresenceEvent.CHANGED, contact));
            }
        }

        internal function receivedMessage(message:XMPPMessage):void
        {
            dispatchEvent(new XMPPMessageEvent(XMPPMessageEvent.RECEIVED, message));
        }

        public function sendMessage(contact:JID, body:String):void
        {
            var bareJID:String  = contact.toBareJIDString();
            var resource:String = contact.resource;

            var rosterItem:RosterItem = getRosterItem(contact);
            if (rosterItem == null) {

                // FIXME: if not in roster, send normal message
                sendNormalMessage(bareJID, body);

            } else {

                var resources:Array;
                var cr:ContactResource;

                if (resource == null) {
                    resources = rosterItem.getAllActiveResources();
                    if (resources.length > 0) {
                        for each(cr in resources) {
                            sendChatMessage(bareJID + "/" + cr.resource, body);
                        }
                    } else {
                        sendNormalMessage(bareJID, body);
                    }

                } else {

                    cr = rosterItem.getResource(resource);
                    if (cr != null && cr.isActive) {
                        sendChatMessage(bareJID + "/" + resource, body);
                    } else {
                        resources = rosterItem.getAllActiveResources();
                        if (resources.length > 0) {
                            for each(cr in resources) {
                                sendChatMessage(bareJID + "/" + cr.resource, body);
                            }
                        } else {
                            sendNormalMessage(bareJID, body);
                        }
                    }

                }
            }

        }

        private function sendChatMessage(to:String, body:String):void
        {
            send(
                  '<message type="' + MessageType.CHAT
                    + '" to="' + to + '">'
                + '<body>' + body + '</body>'
                + '</message>'
            );
        }

        private function sendNormalMessage(to:String, body:String):void
        {
            send(
                  '<message type="' + MessageType.NORMAL
                    + '" to="' + to + '">'
                + '<body>' + body + '</body>'
                + '</message>'
            );
        }

        public function changePresence(show:String, status:String, priority:int=0):void
        {
            if (!_isReady)
                throw new Error("not ready");

            if (priority <= -128 && priority > 128)
                throw new ArgumentError("priority must be in between -127 and 128");

            var presenceTag:String = '<presence';

            var children:Array = [];
            if (show != null)
                children.push('<show>' + show + '</show>');
            if (status != null)
                children.push('<status>' + status + '</status>');
            if (priority != 0)
                children.push('<priority>' + String(priority) + '</priority>');

            children.push(_config.buildPresenceCapsTag());

            // TODO: vcard avatar
            //if (_avatarHash) {
            //var vCardTag:String = '<x xmlns="' + XMPPNamespace.VCARD_UPDATE + '">';
            //vCardTag += '<photo>' + _avatarHash + '</photo>'
            //vCardTag += '</x>';
            //}

            if (children.length > 0) {
                presenceTag += '>';
                presenceTag += children.join('');
                presenceTag += '</presence>';
            } else {
                presenceTag += '/>';
            }
            send(presenceTag);
        }

        internal function receivedUnavailablePresence(contact:JID):void
        {
            // remove resource from roster
            var item:RosterItem = getRosterItem(contact);
            if (item != null) {
                item.removeResource(contact.resource);
                dispatchEvent(new XMPPPresenceEvent(
                    XMPPPresenceEvent.LEAVED, contact));
            }
        }

        internal function receivedPresence(presence:XMPPPresence):void
        {
            var contact:JID = presence.from;
            var item:RosterItem = getRosterItem(presence.from);

            if (item != null) {
                item.setResource(contact.resource, presence);
                dispatchEvent(new XMPPPresenceEvent(
                    XMPPPresenceEvent.CHANGED, contact));
            }
        }

        internal function receivedSubscriptionRequest(sender:JID):void
        {
            var item:RosterItem = getRosterItem(sender);
            // if sender is in roster with subscription-status 'to',
            // automatically accept
            if (item != null && item.subscription == SubscriptionType.TO) {
                acceptSubscriptionRequest(sender);
            } else {
                dispatchEvent(new XMPPSubscriptionEvent(
                    XMPPSubscriptionEvent.RECEIVED, sender));
            }
        }

        public function acceptSubscriptionRequest(contact:JID):void
        {
            if (_isReady)
                send(
                    '<presence to="' + contact.toBareJIDString()
                    + '" type="' + PresenceType.SUBSCRIBED + '"/>'
                );
        }

        public function denySubscriptionRequest(contact:JID):void
        {
            if (_isReady)
                send(
                    '<presence to="' + contact.toBareJIDString()
                    + '" type="' + PresenceType.UNSUBSCRIBED + '"/>'
                );
        }

        internal function receivedSubscriptionResponse(sender:JID, type:String):void
        {
            // TODO: dispatch only?
            // no need to edit some roster data, because roster-push comes.
        }

        public function subscribe(contact:JID):void
        {
            if (_isReady)
                send('<presence to="' + contact.toBareJIDString()
                    + '" type="' + PresenceType.SUBSCRIBE + '" />');
        }

        public function unsubscribe(contact:JID):void
        {
            if (_isReady && contact.toBareJIDString() in _roster)
                send('<presence to="' + contact.toBareJIDString()
                    + '" type="' + PresenceType.UNSUBSCRIBE + '" />');
        }

        public function getLastSeconds(contact:JID):void
        {
            if (_isReady) // and check if this contacts support jappber:iq:last
                send(
                      '<iq to="'     + contact.toString()
                        + '" id="'   + genNextID()
                        + '" type="' + IQType.GET + '">'
                    + '<query xmlns="' + XMPPNamespace.IQ_LAST + '" />'
                    + '</iq>'
                );
        }

        internal function gotLastSeconds(contact:JID, seconds:uint):void
        {
            // TODO: search person from roster and update 'seconds'
        }

        public function getVersion(contact:JID):void
        {
            if (_isReady) // and check if this contacts support jappber:iq:version
                send(
                    '<iq to="'       + contact.toString()
                        + '" id="'   + genNextID()
                        + '" type="' + IQType.GET + '">'
                    + '<query xmlns="' + XMPPNamespace.IQ_VERSION + '" />'
                    + '</iq>'
                );
        }

        internal function gotVersion(contact:JID, name:String,
            version:String, os:String):void
        {
            // TODO: search person from roster and update 'version'
            // should use Entity Capabilities?
        }

        // FIXME: later
        //public function getContactAvatar(contact:JID):DisplayObject
        public function getContactAvatar(contact:JID):ByteArray
        {
            var item:RosterItem = getRosterItem(contact);
            var avatarHash:String = item.avatarHash;
            if (avatarHash == null)
                return null;
            if (!_avatarStore.has(avatarHash))
                return null;
            return _avatarStore.get(avatarHash);
        }

        internal function hasAvatar(hash:String):Boolean
        {
            return _avatarStore.has(hash);
        }

        internal function saveAvatar(type:String, avatarHash:String,
            bytes:ByteArray):void
        {
            _avatarStore.store(type, avatarHash, bytes);
        }

        internal function setContactAvatar(contact:JID, photoHash:String):void
        {
            var resource:String  = contact.resource;
            if (resource == null) {
                // invalid format
                return;
            }

            var item:RosterItem = getRosterItem(contact);
            if (item != null && item.avatarHash != photoHash) {
                item.avatarHash = photoHash;
                dispatchEvent(new XMPPRosterEvent(
                    XMPPRosterEvent.CHANGED, contact));
            }
        }

        /* XEP-0153 vCard Based Avatar
        public function updateAvator(jpegBytes:ByteArray):void
        {
            if (_isReady) {
                var hasher:IHash = Crypto.getHash("sha1");
                _avatarHash:String = Hex.fromArray(hasher.hash(jpegBytes));
                send(
                      '<iq type="' + IQType.SET + '" id="' + genNextID() + '">'
                    + '<vCard xmlns="' + XMPPNamespace.VCARD + '">'
                    + '<PHOTO>'
                    + '<TYPE>image/jpeg</TYPE>'
                    + '<BINVAL>'
                    + Base64.encodeBytes(jpegBytes)
                    + '</BINVAL>'
                    + '</PHOTO>'
                    + '</vCard>'
                    + '</iq>'
                );
            }
        }
        */

        // XEP-0115 Entity Capabilities
        public function contactSupportFeature(contact:JID, featureNS:String):Boolean
        {
            var resource:String  = contact.resource;
            if (resource == null)
                return false;

            var res:ContactResource = getContactResource(contact);
            if (res == null)
                return false;

            var caps:Array = res.getCaps();
            for each(var capId:String in caps) {
                var cap:EntityCapabilities = _capStore.get(capId);
                if (cap != null && cap.supportFeature(featureNS))
                    return true;
            }
            return false;
        }

        internal function storeCap(node:String, cap:EntityCapabilities):void
        {
            _capStore.store(node, cap);
        }

        internal function hasCap(node:String):Boolean
        {
            return _capStore.has(node);
        }

        internal function setContactCap(contact:JID, capId:String):void
        {
            var resource:String  = contact.resource;
            if (resource == null) {
                // invalid format
                return;
            }
            var res:ContactResource = getContactResource(contact);
            if (res != null && !res.hasCap(capId)) {
                res.setCap(capId);
                dispatchEvent(new XMPPPresenceEvent(
                    XMPPPresenceEvent.CHANGED, contact));
            }
        }

        // MUC
        public function joinRoom(roomID:JID, nick:String):void
        {
            // _room[roomID.toBareJIDString()]
            send('<presence to="' + roomID.toBareJIDString() + "/" + nick + '">');
        }

        public function changeRoomNick(roomID:JID, nick:String):void
        {
            // _room[roomID.toBareJIDString()]
            send('<presence to="' + roomID.toBareJIDString() + "/" + nick + '">');
        }

        public function exitRoom(roomID:JID, nick:String, message:String=null):void
        {
            var presenceTag:String =
                '<presence type="' + PresenceType.UNAVAILABLE
                + '" to="' + roomID.toBareJIDString() + "/" + nick + '"';
            if (message != null) {
                presenceTag += ">";
                presenceTag += "<status>" + message + "</status>";
                presenceTag += "</presence>";
            } else {
                presenceTag += " />"
            }
            send(presenceTag);
        }

        /*
        public function sendMessageWithinRoom(roomID:JID, message:String):void
        {
            send(
                  '<message to="' + roomID.toBareJIDString()
                    + '" type="' + MessageType.GROUPCHAT + '">'
                + '<body>' + message + '</body>'
                + '</message>'
                );
        }

        */

        private function connectHandler(e:Event):void
        {
            dispatchEvent(e);
            changeState(new InitialHandler(this));
        }

        private function closeHandler(e:Event):void
        {
            //trace("[stream:close]");
            dispose();
            dispatchEvent(e);
            var canRetry:Boolean = _reconnectionManager.saveRecordAndVerify();
            if (canRetry) {
                //trace("[stream:restart]");
                start();
            } else {
                //trace("[stream:clear]");
                _reconnectionManager.clear();
            }
        }

        private function ioErrorHandler(e:IOErrorEvent):void
        {
            trace("[stream:ioError]");
            _reconnectionManager.inactivate();
            dispose();
            dispatchEvent(e);
        }

        private function securityErrorHandler(e:SecurityErrorEvent):void
        {
            trace("[stream:securityError]");
            _reconnectionManager.inactivate();
            dispose();
            dispatchEvent(e);
        }

        private function protocolErrorHandler(e:XMPPErrorEvent):void
        {
            trace("[stream:protocolError]");
            _reconnectionManager.inactivate();
            dispose();
            dispatchEvent(e);
        }

        private function authErrorHandler(e:XMPPErrorEvent):void
        {
            trace("[stream:authError]");
            _reconnectionManager.inactivate();
            dispose();
            dispatchEvent(e);
        }
    }
}

