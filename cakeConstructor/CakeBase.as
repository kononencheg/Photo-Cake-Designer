package cakeConstructor{
	import flash.display.MovieClip;
	import flash.geom.Transform;
	import flash.geom.ColorTransform;
	import infinitech.utils.ColorConversion;
	import infinitech.visual.DisplayObjectTools;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import cakeConstructor.dataFormats.CakeData;
	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.errors.*;

	public class CakeBase extends MovieClip{
		static private var shape:String;
		
		// Клип с цветом верха
		public var color_mc:MovieClip;
		public var mask_mc:MovieClip;
		
		
		public function CakeBase(shape:String = CakeData.ROUNDED){
			setShape(shape);
		}
		
		public function setShape(shape:String){
			var validShape:Boolean = false;
			for(var i:uint = 0; i < CakeData.SHAPES.length; i++){
				// Если переданная форма есть в списке форм
				if(CakeData.SHAPES[i] == shape){
					validShape = true;
					break;
				}
			}
			if(validShape){
				gotoAndStop(shape);
				shape = shape;
			}
			else{
				throw new Error("Переданное значение формы не является допустимым: " + shape);
			}			
			var initX = 10;
			this.x = -150;
			this.alpha = 0;
			var t:TimelineLite = new TimelineLite();
			// Восставновление непрозрачности
			t.append(new TweenLite(this, .35, {x:initX + 50, alpha:1, ease:Quad.easeIn}));
			// Уменьшение масштаба
			t.append(new TweenLite(this, 1, {x:initX, ease:Elastic.easeOut}));
			t.play();
			mask_mc.alpha = 0;
			clearColor();
		}
		
		public function setColor(color:uint){
			var t:Transform = color_mc.transform;
			var ct:ColorTransform = new ColorTransform();
			ct.color = color;
			t.colorTransform = ct;
			color_mc.transform = t;
			color_mc.alpha = 1;
		}
		
		public function clearColor(){
			color_mc.alpha = 0;
		}
		
		public function applyMask(obj:DisplayObject){
			mask_mc.alpha = 1;
			releaseMask(obj);
			var m:Sprite = DisplayObjectTools.duplicateAsBitmap(mask_mc);
			m.cacheAsBitmap = true;
			obj.cacheAsBitmap = true;
			//obj.parent.addChild(m);
			addChild(m);
			obj.mask = m;
			mask_mc.alpha = 0;
		}
		
		public function releaseMask(obj:DisplayObject){
			if(obj.mask != null){
				var m:Sprite = obj.mask as Sprite;
				obj.mask = null;
				removeChild(m);
			}
		}
	}
}