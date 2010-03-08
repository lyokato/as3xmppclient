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
    public class IDGenerator
    {
        private var _prefix:String;
        private var _digit:uint;
        private var _current:uint;

        public function IDGenerator(prefix:String, digit:uint)
        {
            _prefix  = prefix;
            _digit   = digit;
            _current = 0;
        }

        public function generate():String
        {
            _current++;
            var n:String = String(_current);
            if (n.length > _digit) {
                n = n.substring(n.length - 4);
                _current = uint(n);
            } else if (n.length < _digit) {
                while (n.length < 4)
                    n = "0" + n;
            }
            return _prefix + n;
        }
    }
}

