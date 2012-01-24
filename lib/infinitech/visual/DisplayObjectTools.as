package infinitech.visual{
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;

	public class DisplayObjectTools{
		
		// Создает растровый дубликат объекта и возвращает его в виде спрайта, содержащего Bitmap
		public static function duplicateAsBitmap(displayObj:DisplayObject):Sprite{
			if(displayObj.width > 2880 || displayObj.height > 2880){
				throw new Error("The size of display object exceeds 2880 px and cannot be rendered as bitmap");
				return;
			}
			else{
				var btmpData:BitmapData = new BitmapData(displayObj.width, displayObj.height, true, 0xffffff);
				var btmp:Bitmap = new Bitmap();
				var m:Matrix = new Matrix();
				var bounds:Rectangle = displayObj.getBounds(displayObj);
				var sprite:Sprite = new Sprite();
				m.translate(-bounds.x, -bounds.y);
				// Отрисовываем объект, смещая его содержимое в 0.0 (метод draw() отрисовывает только графику из положительного квадранта, поэтому, если точка регистрации копируемого объекта не в левом верхнему углу, его часть будет срезана)
				btmpData.draw(displayObj, m);
				btmp.bitmapData = btmpData;
				btmp.smoothing = true;
				btmp.transform = displayObj.transform;
				// Смещаем растровый дубликат в положение, занимаемое оригиналом
				btmp.x += bounds.x;
				btmp.y += bounds.y;
				sprite.addChild(btmp);
			}
			return sprite;
		}
		
		// Изменяет размеры переданного объекта с сохранением исходных пропорций так, чтобы он
		// умещался в область с заданными размерами
		public static function changeSizeToFit(obj:DisplayObject, w:Number, h:Number){
			// Размеры картинки
			var imageW = obj.width;
			var imageH = obj.height;
			// Картинка больше области
			if(imageW > w || imageH > h){
				var stageRatio = w / h;
				var imageRatio = imageW / imageH;
				// Область вертикальная, картинка - горизонтальная
				if (stageRatio <= 1 && imageRatio >= 1) {
					obj.width = w;
					obj.height = w / imageRatio;
				}
				// Область горизонтальная, картинка - вертикальная
				else if (stageRatio > 1 && imageRatio < 1) {
					obj.height = h;
					obj.width = h * imageRatio;
				}
				// Одинаковая ориентация области и картинки.
				// вертикальная: картинка более вытянутая
				// горизонтальная: область более вытянутая
				else if (imageRatio <= stageRatio) {
					obj.height = h;
					obj.width = h * imageRatio;
				}
				// Одинаковая ориентация области и картинки.
				// вертикальная: область более вытянутая
				// горизонтальная: картинка более вытянутая
				else if (imageRatio > stageRatio) {
					obj.width = w;
					obj.height = w / imageRatio;
				}
			}
		}
	}
}