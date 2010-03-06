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

package org.coderepos.date {

  /**
   * Class handles W3CDTF formatted date
   */
  public class W3CDTF {

    /**
     * Parse W3CDTF format string
     *
     * @param stirng
     * @return date
     * @langversion ActionScript 3.0
     * @playerversion 9.0
     *
     * XXX:
     *   This code is borrowed from as3corelib's DateUtil class.
     *   I copied same functionality because I want to remove dependencies on mx-libraries.
     */
    public static function parse(str:String):Date {
      var finalDate:Date;
			try
			{
				var dateStr:String = str.substring(0, str.indexOf("T"));
				var timeStr:String = str.substring(str.indexOf("T")+1, str.length);
				var dateArr:Array = dateStr.split("-");
				var year:Number = Number(dateArr.shift());
				var month:Number = Number(dateArr.shift());
				var date:Number = Number(dateArr.shift());
				
				var multiplier:Number;
				var offsetHours:Number;
				var offsetMinutes:Number;
				var offsetStr:String;
				
				if (timeStr.indexOf("Z") != -1)
				{
					multiplier = 1;
					offsetHours = 0;
					offsetMinutes = 0;
					timeStr = timeStr.replace("Z", "");
				}
				else if (timeStr.indexOf("+") != -1)
				{
					multiplier = 1;
					offsetStr = timeStr.substring(timeStr.indexOf("+")+1, timeStr.length);
					offsetHours = Number(offsetStr.substring(0, offsetStr.indexOf(":")));
					offsetMinutes = Number(offsetStr.substring(offsetStr.indexOf(":")+1, offsetStr.length));
					timeStr = timeStr.substring(0, timeStr.indexOf("+"));
				}
				else // offset is -
				{
					multiplier = -1;
					offsetStr = timeStr.substring(timeStr.indexOf("-")+1, timeStr.length);
					offsetHours = Number(offsetStr.substring(0, offsetStr.indexOf(":")));
					offsetMinutes = Number(offsetStr.substring(offsetStr.indexOf(":")+1, offsetStr.length));
					timeStr = timeStr.substring(0, timeStr.indexOf("-"));
				}
				var timeArr:Array = timeStr.split(":");
				var hour:Number = Number(timeArr.shift());
				var minutes:Number = Number(timeArr.shift());
				var secondsArr:Array = (timeArr.length > 0) ? String(timeArr.shift()).split(".") : null;
				var seconds:Number = (secondsArr != null && secondsArr.length > 0) ? Number(secondsArr.shift()) : 0;
				var milliseconds:Number = (secondsArr != null && secondsArr.length > 0) ? Number(secondsArr.shift()) : 0;
				var utc:Number = Date.UTC(year, month-1, date, hour, minutes, seconds, milliseconds);
				var offset:Number = (((offsetHours * 3600000) + (offsetMinutes * 60000)) * multiplier);
				finalDate = new Date(utc - offset);
	
				if (finalDate.toString() == "Invalid Date")
				{
					throw new Error("This date does not conform to W3CDTF.");
				}
			}
			catch (e:Error)
			{
				var eStr:String = "Unable to parse the string [" +str+ "] into a date. ";
				eStr += "The internal error was: " + e.toString();
				throw new Error(eStr);
			}
      return finalDate;
    }

    /**
     * Get current date as w3cdtf formatted string
     *
     * @return string
     * @langversion ActionScript 3.0
     * @playerversion 9.0
     */
    public static function now():String {
      var d:Date = new Date();
      return format(d);
    }

    /**
     * Get W3CDTF formatted string from passed date object.
     *
     * @param date
     * @return formatted string
     * @langversion ActionScript 3.0
     * @playerversion 9.0
     */
    public static function format(d:Date, calcMilliSeconds:Boolean=true):String {
      var year   :Number = d.getUTCFullYear();
      var month  :Number = d.getUTCMonth() + 1;
      var date   :Number = d.getUTCDate();
      var hour   :Number = d.getUTCHours();
      var minute :Number = d.getUTCMinutes();
      var second :Number = d.getUTCSeconds();
      var milli  :Number = d.getUTCMilliseconds();
      var value  :String =  year
                         + "-"
                         + pushZero(month)
                         + "-"
                         + pushZero(date)
                         + "T"
                         + pushZero(hour)
                         + ":"
                         + pushZero(minute)
                         + ":"
                         + pushZero(second);
      if (calcMilliSeconds && milli > 0) {
        var milliStr:String = pushZero(milli, 3);
        while (milliStr.charAt(milliStr.length - 1) == "0") {
          milliStr = milliStr.substr(0, milliStr.length - 1);
        }
        value = value + "." + milliStr;
      }
      return value + "Z";
    }

    private static function pushZero(num:Number, digit:uint=2):String {
      var value:String = num.toString();
      while (value.length < digit) {
        value = "0" + value;
      }
      return value;
    }

  }

}

