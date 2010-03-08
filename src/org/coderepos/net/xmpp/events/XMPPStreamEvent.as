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

package org.coderepos.net.xmpp.events
{
    import flash.events.Event;

    public class XMPPStreamEvent extends Event
    {
        public static const START:String                = "stream_start";
        public static const CLOSE:String                = "stream_close";
        public static const TLS_NEGOTIATING:String      = "stream_negotiationg";
        public static const AUTHENTICATING:String       = "stream_authenticating";
        public static const BINDING_RESOURCE:String     = "stream_binding";
        public static const ESTABLISHING_SESSION:String = "stream_establishing";
        public static const LOADING_ROSTER:String       = "stream_loadingRoster";
        public static const READY:String                = "stream_ready";

        public function XMPPStreamEvent(type:String,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }

        override public function clone():Event
        {
            return new XMPPStreamEvent(type, bubbles, cancelable);
        }
    }
}
