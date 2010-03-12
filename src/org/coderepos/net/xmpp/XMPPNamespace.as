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

package org.coderepos.net.xmpp
{
    public class XMPPNamespace
    {
        public static const STREAM:String                   = "http://etherx.jabber.org/streams"
        public static const CLIENT:String                   = "jabber:client";

        public static const STANZA:String                   = "urn:ietf:params:xml:ns:xmpp-stanzas";
        public static const TLS:String                      = "urn:ietf:params:xml:ns:xmpp-tls";
        public static const SASL:String                     = "urn:ietf:params:xml:ns:xmpp-sasl";
        public static const BIND:String                     = "urn:ietf:params:xml:ns:xmpp-bind";
        public static const SESSION:String                  = "urn:ietf:params:xml:ns:xmpp-session";

        public static const BLOCKING:String                 = "urn:xmpp:blocking";
        public static const VCARD:String                    = "vcard-temp";
        public static const VCARD_UPDATE:String             = "vcard-temp:x:update";

        public static const IQ_AUTH:String                  = "jabber:iq:auth";
        public static const IQ_ROSTER:String                = "jabber:iq:roster";
        public static const IQ_REGISTER:String              = "jabber:iq:register";
        public static const IQ_PRIVACY:String               = "jabber:iq:privacy";
        public static const IQ_VERSION:String               = "jabber:iq:version";
        public static const IQ_LAST:String                  = "jabber:iq:last";

        public static const FEATURE_AUTH:String             = "http://jabber.org/features/iq-auth";
        public static const FEATURE_COMPRESS:String         = "http://jabber.org/features/compress";

        public static const CHAT_STATE:String               = "http://jabber.org/protocol/charstates";

        public static const CAPS:String                     = "http://jabber.org/protocol/caps";
        public static const RSM:String                      = "http://jabber.org/protocol/rsm";
        public static const COMMANDS:String                 = "http://jabber.org/protocol/commands";
        public static const XHTML_IM:String                 = "http://jabber.org/protocol/xhtml-im";
        public static const XHTML:String                    = "http://www.w3.org/1999/xhtml";
        public static const DATA:String                     = "jabber:x:data";
        public static const DELAY:String                    = "jabber:x:delay";
        public static const CAPTCHA:String                  = "urn:xmpp:captcha";

        public static const DISCO_ITEMS:String              = "http://jabber.org/protocol/disco#items";
        public static const DISCO_INFO:String               = "http://jabber.org/protocol/disco#info";

        public static const MUC:String                      = "http://jabber.org/protocol/muc";
        public static const MUC_ADMIN:String                = "http://jabber.org/protocol/muc#admin";
        public static const MUC_USER:String                 = "http://jabber.org/protocol/muc#user";
        public static const MUC_OWNER:String                = "http://jabber.org/protocol/muc#owner";
        public static const MUC_REGISTER:String             = "http://jabber.org/protocol/muc#register";
        public static const MUC_ROOMCONFIG:String           = "http://jabber.org/protocol/muc#roomconfig";

        public static const PUBSUB:String                   = "http://jabber.org/protocol/pubsub";
        public static const PUBSUB_OWNER:String             = "http://jabber.org/protocol/pubsub#owner";
        public static const PUBSUB_EVENT:String             = "http://jabber.org/protocol/pubsub#event";
        public static const PUBSUB_SUBSCRIBE_OPTIONS:String = "http://jabber.org/protocol/pubsub#subscribe_options";
    }
}

