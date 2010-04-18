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

package org.coderepos.net.xmpp.vcard
{
    import flash.display.DisplayObject;
    import flash.utils.ByteArray;

    public class AvatarFileStore implements IAvatarStore
    {
        private var _store:Object;

        public function AvatarFileStore()
        {
            _store = {};
            // load setting file from disk
            // load all images
        }

        public function has(hash:String):Boolean
        {
            return (hash in _store);
        }

        public function store(type:String, hash:String, bytes:ByteArray):void
        {
            _store[hash] = bytes;
            // save image file
            // update setting file
        }

        public function get(hash:String):ByteArray
        {
           return (hash in _store) ? _store[hash] : null;
        }
    }
}

