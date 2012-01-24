package cakeConstructor.events{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class CakeEvent extends Event{
		public static const TEXT_CHANGE_EVENT:String = "textchanged";	
		public static const TEXT_REMOVE_EVENT:String = "textremoved";	
		private var _type:String;
		
		
		public var textContainer:Sprite;
		
		public function CakeEvent(type:String){
			_type = type;
			super(_type);
		}
		
		public override function clone():Event{
			return new CakeEvent (_type);
		}
	}
}