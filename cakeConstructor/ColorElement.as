package cakeConstructor{
	import flash.display.MovieClip;
	import flash.utils.getQualifiedClassName;
	import flash.geom.Transform;
	import flash.geom.ColorTransform;

	public class ColorElement extends MovieClip{
		
		
		// Клип с элементами
		public var plate:MovieClip;
		public var color_mc:MovieClip;
		private var colorValue:Number;
		
		public function ColorElement(){
			color_mc.buttonMode = true;
			plate.buttonMode = true;
			clearPlate();
		}
		override public function toString():String{
			return getQualifiedClassName(this);
		}
		
		public function clearPlate(){
			plate.visible = false;
		}
		
		public function showPlate(){
			plate.visible = true;
		}
		
		public function getPlate(){
			return plate;
		}
		
		public function getImage(){
			return color_mc;
		}
		
		public function setColor(color:uint){
			var t:Transform = new Transform(color_mc);
			var ct:ColorTransform = new ColorTransform();
			ct.color = color;
			colorValue = color;
			t.colorTransform = ct;
		}
		
		public function getColor():Number{
			return colorValue;
		}
		
		public function removeColor(){
			var t:Transform = new Transform(color_mc);
			t.colorTransform = null;
			colorValue = -1;
		}
	}
}