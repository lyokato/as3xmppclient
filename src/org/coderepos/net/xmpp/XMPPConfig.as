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

            reconnectionAcceptableInterval     = 60 * 5;
            reconnectionMaxCountWithinInterval = 5;

            resourceBindingMaxRetryCount = 5;

            xmlMaxElementDepth = 20;
            xmlMaxFragmentSize = 1024 * 1024 * 10;
        }
    }
}

