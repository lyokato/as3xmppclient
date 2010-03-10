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

package org.coderepos.net.xmpp.util
{
    public class ReconnectionManager
    {
        private var _interval:uint;
        private var _maxCount:uint;
        private var _records:Vector.<Number>;
        private var _isActive:Boolean;

        public function ReconnectionManager(intervalSeconds:uint=3600, maxCount:uint=5)
        {
            _isActive = true;
            _interval = intervalSeconds * 1000;
            _maxCount = maxCount;
            _records = new Vector.<Number>(_maxCount);
        }

        public function get isActive():Boolean
        {
            return _isActive;
        }

        public function inactivate():void
        {
            _isActive = false;
        }

        public function saveRecordAndVerify():Boolean
        {
            if (!_isActive)
                return false;
            var now:Number = new Date().getTime();
            return saveTimeAndVerify(now);
        }

        public function saveTimeAndVerify(t:Number):Boolean
        {
            var leastAcceptable:int = t - _interval;
            while (_records.length != 0 && _records[0] < leastAcceptable)
                _records.shift();
            _records.push(t);
            return (_records.length > _maxCount) ? false : true;
        }

        public function clear():void
        {
            _records  = new Vector.<Number>(_maxCount);
            _isActive = true;
        }
    }
}

