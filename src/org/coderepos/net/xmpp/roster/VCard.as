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

package org.coderepos.net.roster
{
    import org.coderepos.xml.XMLElement;

    // [XEP-0054]
    public class VCard
    {
        public static function fromElement(elem:XMLElement):VCard
        {
            var vcard:VCard = new VCard();
            var N:XMLElement = elem.getFirstElement("N");
            if (N != null) {
                var GIVEN:String = N.getFirstElement("GIVEN");
                if (GIVEN != null)
                    vcard.name = GIVEN.text;
            }

            var URL:XMLElement= elem.getFirstElement("URL");
            if (URL != null)
                vcard.url = URL.text;
            var PHOTO:XMLElement = elem.getFirstElement("PHOTO");
            if (PHOTO != null) {
                var EXTVAL:XMLElement = elem.getFirstElement("EXTVAL");
                if (EXTVAL != null)
                    vcard.photo = EXTVAL.text;
            }
            var EMAIL:XMLElement = elem.getFirstElement("EMAIL");
            if (EMAIL != null) {
                var USERID:XMLElement = elem.getFirstElement("USERID");
                if (USERID != null)
                    vcard.email = USERID.text;
            }
        }

        public var name:String;
        public var url:String;
        public var photo:String;
        public var email:String;

        public function VCard()
        {

        }
    }
}

