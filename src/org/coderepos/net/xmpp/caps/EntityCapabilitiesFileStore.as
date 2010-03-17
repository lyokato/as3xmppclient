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
    public class EntityCapabilitiesFileStore implements IEntityCapabilitiesStore
    {
        private var _store:Object;

        public function EntityCapabilitiesFileStore()
        {
            _store = {};
            // load from file
        }

        public function get(node:String):EntityCapabilities
        {
            return (node in _store) ? _store[node] : null;
        }

        public function has(node:String):Boolean
        {
            return (node in _store);
        }

        public function store(node:String, cap:EntityCapabilities):void
        {
            if (!(node in _store)) {
                _store[node] = cap;
                // save to file
            }
        }
    }
}

