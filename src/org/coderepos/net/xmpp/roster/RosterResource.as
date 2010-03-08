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

package org.coderepos.net.xmpp.roster
{
    import org.coderepos.net.xmpp.ChatState;
    import org.coderepos.net.xmpp.EntityCapabilities;

    public class RosterResource
    {
        private var _resource:String;

        // XEP-0153 Entity Capabilities
        private var _capability:EntityCapabilities;

        // XEP-0012 Last Activity
        private var _last:uint;

        private var _chatState:ChatState;

        public function RosterResource(resource:String)
        {
            _resource  = resource;
            _chatState = new ChatState();
        }

        public function get resource():String
        {
            return _resource;
        }
    }
}

