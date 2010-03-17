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

package org.coderepos.net.xmpp.caps
{
    import flash.utils.ByteArray;

    import com.hurlant.util.Base64;
    import com.hurlant.crypto.Crypto;
    import com.hurlant.crypto.hash.IHash;

    import org.coderepos.xml.XMLElement;
    import org.coderepos.net.xmpp.XMPPNamespace;
    import org.coderepos.net.xmpp.exceptions.XMPPProtocolError;

    // [XEP-0115]
    public class EntityCapabilities
    {
        public static function fromElement(query:XMLElement):EntityCapabilities
        {
            var cap:EntityCapabilities = new EntityCapabilities();
            var identities:Array = query.getElements("identity");
            for each(var identity:XMLElement in identities) {
                var name:String = identity.getAttr("name");
                var category:String = identity.getAttr("category");
                var type:String = identity.getAttr("type");
                var lang:String =
                    identity.getAttrNS("http://www.w3c.org/XML/1998/namespace", "lang");
                if (name != null && category != null && type != null) {
                    cap.addIdentity(name, category, type, lang);
                } else {
                    // XXX: should throw exception?
                    // throw new XMPPProtocolError("invalid identity");
                }
            }
            var features:Array = query.getElements("features");
            for each(var feature:XMLElement in features)
                cap.addFeature(feature.text);

            /*
            var forms:Array = query.getElementsNS(XMPPNamespace.DATA, "x");
            for each(var form:XMLElement in forms) {

            }
            */

            return cap;
        }

        private var _features:Object;
        private var _identities:Array;

        public function EntityCapabilities()
        {
            _features   = {};
            _identities = [];
        }

        public function addFeature(feature:String):void
        {
            _features[feature] = 1;
        }

        public function addIdentity(name:String, category:String,
            type:String, lang:String=null):void
        {
            if (lang == null)
                lang = "";
            _identities.push(
                { name:name, category:category, type:type, lang:lang });
        }

        public function genInfoQueryXMLString(node:String):String
        {
            var verifier:String = genVerifier("sha1");
            node += "#";
            node += verifier;
            var q:String = '<query xmlns="' + XMPPNamespace.DISCO_INFO
                + '" node="' + node + '">'
            for each(var identity:Object in _identities) {
                q += '<identity category="' + identity.category
                    + '" name="' + identity.name
                    + '" type="' + identity.type + '" ';
                if (identity.lang.length > 0)
                    q += 'xml:lang="' + identity.lang + '" '
                q += '/>';
            }
            for each(var feature:String in _features) {
                q += '<feature var="' + feature + '" />';
            }
            q += '</query>';
            return q;
        }

        public function genVerifier(hashType:String):String
        {
            var S:String = "";
            _identities.sortOn(["category", "type", "lang"]);
            for each(var identity:Object in _identities) {
                S += identity.category;
                S += "/";
                S += identity.type;
                S += "/";
                S += identity.lang;
                S += "/";
                S += identity.name;
                S += "<";
            }
            var featuresNS:Array = [];
            for (var prop:String in _features) {
                featuresNS.push(prop);
            }
            featuresNS.sort();
            for each(var feature:String in featuresNS) {
                S += feature;
                S += "<";
            }
            var bytes:ByteArray = new ByteArray();
            bytes.writeUTFBytes(S);
            bytes.position = 0;
            var hasher:IHash = Crypto.getHash(hashType);
            if (hasher == null)
                new ArgumentError("Unknown hashType: " + hashType);
            return Base64.encodeByteArray(hasher.hash(bytes));
        }

        public function supportFeature(feature:String):Boolean
        {
            return (feature in _features);
        }
    }
}

