package infinitech.ui.scrollFrame{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import infinitech.visual.DynamicRegistration;
	import flash.geom.Point;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.ScrollRectPlugin;
	import com.greensock.easing.*;
	
	/**
	 * Класс для размещения заданного количества объектов из указанного набора объектов одинакового размера в ряд или столбец с возможностью прокрутки
	 * в пределах области вывода. Прокрутка может выполняться до достижения первого или последнего элемента или по кругу.
	 * 
	 * @author Дмитрий
	 */
	/**
	 * 
	 * @author Дмитрий
	 */
	/**
	 * 
	 * @author Дмитрий
	 */
	public class ScrollFrameController extends Sprite{
		
		// Должна ли прокрутка выполняться по кругу (бесконечно)
		public var infiniteScroll:Boolean;
		// Время прокрутки до соседнего элемента в секундах
		public var scrollTime:Number = .5;
		// Массив объектов (Display Object), которые были переданы конструктору
		private var _objects:Array;
		// Область вывода
		private var _maskRec:Rectangle;
		// Количество элементов, которые нужно выводить
		private var _numToDisplay:uint;
		// Расстояние между элементами
		private var _offset:Number;
		// Горизонтальная или вертикальная ориентация
		private var _directionHor:Boolean;
		// Ширина объекта
		private var _w:Number;
		// Высота объекта
		private var _h:Number;
		// Шаг прокрутки на один элемент
		private var _scrollStep:Number;
		// Размер всех элементов вместе с промежутками (ширина или высота)
		private var _fullSize:Number;
		// Индекс крайнего (левого или верхнего) элемента начиная с нуля.
		private var _current:uint;
		// Нужна ли прокрутка (если количество элементов, которое нужно показать, равно или превышает общее количество объектов, прокрутка не нужна)
		private var _needsScrolling:Boolean;
		
		TweenPlugin.activate([ScrollRectPlugin]);
		TweenLite.defaultEase = Quint.easeOut;
		
		/**
		 * 
		 * @param displayObjects - массив объектов одинакового размера, которые нужно прокуручивать
		 * @param numToDisplay - количество элементов, выводимое на экран
		 * @param offset - расстояние между элементами
		 * @param hor - ориентация (горизонтальная - true или вертикальная - false)
		 * @param infiniteScrl - бесконечная прокрутка
		 */
		public function ScrollFrameController(displayObjects:Array, numToDisplay:uint, offset:Number, hor:Boolean = true, infiniteScrl:Boolean = true){
			_objects = displayObjects;
			_numToDisplay = numToDisplay;
			_offset = offset;
			_directionHor = hor;
			infiniteScroll = infiniteScrl;
			_w = _objects[0].width;
			_h = _objects[0].height;
			_needsScrolling = _numToDisplay < _objects.length;
			addChildren();
			arrangeChildren();
			setMask();
		}
		
		// Добавляем переданные объекты в текущий контейнер (ScrollFrameController)
		private function addChildren(){
			for(var i:uint = 0; i < _objects.length; i++){
				addChild(_objects[i]);
			}
		}
		// Расставляем объекты в ряд или столбец, соблюдая промежутки в том же порядке, в котором они расположены в массиве _objects
		private function arrangeChildren(){
			for(var i:uint = 0; i < _objects.length; i++){
				var bounds:Rectangle = _objects[i].getBounds(_objects[i]);
				if(_directionHor){
					_scrollStep = _w + _offset;
					DynamicRegistration.move(_objects[i], new Point(bounds.left, bounds.top), i * _scrollStep, 0);
				}
				else{
					_scrollStep = _h + _offset;
					DynamicRegistration.move(_objects[i], new Point(bounds.left, bounds.top), 0, i * _scrollStep);
				}
			}
			_fullSize = _scrollStep * _objects.length - _offset;
		}
		// Устанавливаем область вывода
		private function setMask(){
			var maskSize:Number;
			if(_directionHor){
				maskSize = _w * _numToDisplay + _offset * (_numToDisplay - 1);
				_maskRec = new Rectangle(0, 0, maskSize, _h);
			}
			else{
				maskSize = _h * _numToDisplay + _offset * (_numToDisplay - 1);
				_maskRec = new Rectangle(0, 0, _w, maskSize);
			}		
			scrollRect = _maskRec;
		}
		
		/**
		 * Прокрутка к следующему элементу (правому или нижнему)
		 */
		public function scrollNext(){
			if(_needsScrolling){
				// Если крайний элемент - последний
				if(_current == _objects.length - _numToDisplay){
					if(infiniteScroll){
						for(var i:uint = 0; i < _current; i++){
							// Переставляем элементы из начала в конец массива
							_objects.push(_objects.shift());
						}
						arrangeChildren();
						// Обнуляем индекс (значение позиции) крайнего элемента
						_current = 0;
						var s:Rectangle = scrollRect;
						// Обнуляем позицию прокрутки
						if(_directionHor){
							s.x = 0;
						}
						else{
							s.y = 0;
						}
						scrollRect = s;
					}
					else return;
				}
				// Прокрутка
				_current ++;
				if(_directionHor){
					TweenLite.to(this, scrollTime, {scrollRect:{x:_current * _scrollStep}});
				}
				else{
					TweenLite.to(this, scrollTime, {scrollRect:{y:_current * _scrollStep}});
				}
			}
		}
		
		/**
		 * 
		 */
		public function scrollPrev(){
			if(_needsScrolling){
				if(_current == 0){
					if(infiniteScroll){
						for(var i:uint = 0; i < _objects.length - _numToDisplay; i++){
							_objects.unshift(_objects.pop());
						}
						arrangeChildren();
						_current = _objects.length - _numToDisplay;
						var s:Rectangle = scrollRect;
						if(_directionHor){
							s.x = _current * _scrollStep;
						}
						else{
							s.y = _current * _scrollStep;
						}
						scrollRect = s;
					}
					else return;
				}
				_current --;
				if(_directionHor){
					TweenLite.to(this, scrollTime, {scrollRect:{x:_current * _scrollStep}});
				}
				else{
					TweenLite.to(this, scrollTime, {scrollRect:{y:_current * _scrollStep}});
				}
			}
		}
		public function getVisibleBounds(){
			var rec = _maskRec.clone();
			return rec;
		}
	}
} 