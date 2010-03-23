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
    import org.coderepos.net.xmpp.caps.EntityCapabilities;

    public class XMPPConfig
    {
        public var host:String;
        public var port:uint;
        public var username:String;
        public var password:String;
        public var resource:String;

        public var reconnectionAcceptableInterval:uint;
        public var reconnectionMaxCountWithinInterval:uint;

        public var resourceBindingMaxRetryCount:uint;

        public var xmlMaxElementDepth:uint;
        public var xmlMaxFragmentSize:uint;

        public var applicationName:String;
        public var applicationCategory:String;
        public var applicationType:String;
        public var applicationNode:String;
        public var applicationVersion:String;
        public var applicationLanguage:String;

        private var _cap:EntityCapabilities;
        private var _verifier:String;

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
            applicationLanguage = "en-US";

            reconnectionAcceptableInterval     = 60 * 5;
            reconnectionMaxCountWithinInterval = 5;

            resourceBindingMaxRetryCount = 5;

            xmlMaxElementDepth = 20;
            xmlMaxFragmentSize = 1024 * 1024 * 10;
        }

        private function getCap():EntityCapabilities
        {
            if (_cap == null) {
                _cap = new EntityCapabilities();
                _cap.addIdentity(applicationName, applicationCategory,
                    applicationType, applicationLanguage);
                _cap.addFeature(XMPPNamespace.CAPS);
                _cap.addFeature(XMPPNamespace.DISCO_INFO);
                _cap.addFeature(XMPPNamespace.VCARD_UPDATE);
                _cap.addFeature(XMPPNamespace.IQ_VERSION);
                //_cap.addFeature(XMPPNamespace.IQ_LAST);
            }
            return _cap;
        }

        private function getVerifier():String
        {
            if (_verifier == null)
                _verifier = getCap().genVerifier("sha1");
            return _verifier;
        }

        public function buildPresenceCapsTag():String
        {
            var verifier:String = getVerifier();
            var tag:String = '<c xmlns="' + XMPPNamespace.CAPS
                + '" hash="sha-1" node="' + applicationNode
                + '" ver="' + verifier + '" />';
            return tag;
        }

        public function buildDiscoInfoFeatureTags():String
        {
            return getCap().buildDiscoInfoFeatureTags();
        }

    }
}

