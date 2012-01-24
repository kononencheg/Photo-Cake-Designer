package cakeConstructor{
	
	import flash.display.*;
	import infinitech.ui.scrollFrame.ScrollFrameController;
	public class ChoserContainer extends MovieClip{
		
		public var urls:Array;
		public var descriptions:Array;
		// Типы украшения верха, расположенные в элементе выбора украшения
		public var types:Array;
		public var autorotates:Array;
		//Спрайт с прокручиваемыми элементами украшения верха
		public var choser:ScrollFrameController;
		// Элементы, относящиеся к данному селектору, которые расположены на торте
		public var elementsInUse:Array;
		// Кнопка очистки, связанная с данным селектором
		public var clearButton:SimpleButton;
		
		public function ChoserContainer(){
			urls = [];
			types = [];
			descriptions = [];
			autorotates = [];
			elementsInUse = [];
		}
	}
}