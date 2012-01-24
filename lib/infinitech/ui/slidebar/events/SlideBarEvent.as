package infinitech.ui.slidebar.events {
	
	import flash.events.Event;
	
	/**
	
	Класс событий, связанных с прокруткой
	
	*/
	
	public class SlideBarEvent extends Event{
		
		// Вызывается периодически во время прокрутки
		public static const SLIDER_EVENT:String = "sliding";
		// Вызывается при прекращении прокрутки (отпускание кнопки мыши после прокрутки)
		public static const SLIDING_DONE:String = "slidingdone";
		// Вызывается при установке положения слайдера
		public static const SLIDER_SET_POSITION:String = "positionisset";
		// Вызывается при щелчке на полосе прокрутки
		public static const SLIDETRACK_CLICK:String = "scrolltrackclick";
		// Вызывается при наведении на полосу прокрутки
		public static const SLIDETRACK_OVER:String = "trackover";
		// Вызывается при уходе с полосы прокрутки
		public static const SLIDETRACK_OUT:String = "trackout";		
		// Вызывается при перемещении по полосе прокрутки без нажатия мыши
		public static const OVER_SLIDING:String = "oversliding";				
		
		private var _type:String;
		
		public var slideValue:Number;
		public var slideOverPosition:Number;
		
		public function SlideBarEvent(type:String) {
			_type = type;
			super(_type);
		}
		
		public override function clone():Event{
			return new SlideBarEvent (_type);
		}
	}
}
