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

