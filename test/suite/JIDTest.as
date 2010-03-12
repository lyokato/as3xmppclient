package suite
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.net.xmpp.JID;

    public class JIDTest extends TestCase
    {
        public function JIDTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new JIDTest("testJID"));
            return ts;
        }

        public function testJID():void
        {
            check("normal", "lyo.kato@gmail.com/home", "lyo.kato", "gmail.com", "home", "lyo.kato@gmail.com", "lyo.kato@gmail.com/home");
            check("bare", "lyo.kato@gmail.com", "lyo.kato", "gmail.com", null, "lyo.kato@gmail.com", "lyo.kato@gmail.com");
            check("server", "conference.wonderland.lit", null, "conference.wonderland.lit", null, "conference.wonderland.lit", "conference.wonderland.lit");
            check("roomID", "roomName@conference.wonderland.lit/Mad Hatter", "roomName", "conference.wonderland.lit", "Mad Hatter", "roomName@conference.wonderland.lit", "roomName@conference.wonderland.lit/Mad Hatter");
        }

        public function check(comment:String, src:String, node:String, domain:String, resource:String, bare:String, full:String):void
        {
            var jid:JID = new JID(src);
            if (node != null)
                assertEquals(comment + "[node]", jid.node, node);
            else
                assertNull(comment + "[node]", jid.node);
            if (domain != null)
                assertEquals(comment + "[domain]", jid.domain, domain);
            else
                assertNull(comment + "[domain]", jid.domain);
            if (resource != null)
                assertEquals(comment + "[resource]", jid.resource, resource);
            else
                assertNull(comment + "[resource]", jid.resource);
            assertEquals(comment + "[bare]", jid.toBareJIDString(), bare);
            assertEquals(comment + "[full]", jid.toString(), full);
        }
    }
}
