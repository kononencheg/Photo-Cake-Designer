package 
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author jpauclair
	 */
	public class Main extends Sprite 
	{
		private var _testString:ByteArray =null;
		private var _testStringDecode:String = null;
		private var _outputField:TextField;

		private var _stringToEncode:String = "The term Base64 refers to a specific MIME content transfer encoding: http://en.wikipedia.org/wiki/Base64";
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			_outputField = new TextField();
			_outputField.width = stage.stageWidth;
			_outputField.height = stage.stageHeight;			
			addChild(_outputField);			
			stage.scaleMode = StageScaleMode.NO_SCALE;

			
			_testString = GetString();
			
			_testStringDecode = _testString.toString();
			
			var s:String = Base64.encode(_testString); 
			out("b64: "+ s);
			var s2:ByteArray = Base64.decode(s);
			out("clear: " + s2.toString());
			if (_stringToEncode == s2.toString())
			{
				out("clear->encode->decode == clear");
			}
		}
		private function out(str:String):void
		{
			trace(str);
			_outputField.appendText(str + "\n");
		}		
		private function GetString() : ByteArray
		{
			var result:ByteArray = new ByteArray();
			result.writeUTFBytes(_stringToEncode);
			result.position = 0
			return result;
		}
	
	
	}
}