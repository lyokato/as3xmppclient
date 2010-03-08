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
    public class XMPPPresence
    {
        private var _from:JID;
        private var _isAvailable:Boolean;
        private var _show:String;
        private var _status:String;
        private var _priority:int;

        public function XMPPPresence(from:JID, isAvailable:Boolean,
            show:String="", status:String="", priority:int=0)
        {
            _from        = from;
            _isAvailable = isAvailable;
            _show        = show;
            _status      = status;
            _priority    = priority;
        }

        public function get from():JID
        {
            return _from;
        }

        public function get isAvailable():Boolean
        {
            return _isAvailable;
        }

        public function get show():String
        {
            return _show;
        }

        public function get status():String
        {
            return _status;
        }

        public function get priority():int
        {
            return _priority;
        }
    }
}

