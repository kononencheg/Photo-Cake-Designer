package infinitech.visual{

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	/**
	* Класс для перетаскивания объекта. Позволяет вызывать внешние функции при наведении/уходе, захвате, перемещении и сбросе объекта.
	* При вызове внешних функций им в качестве параметра передается ссылка на перетаскиваемый объект
	// Пример использования:
		DragAndDrop.activate(mc, true, true, true, onOver, onOut, onGrab);
		DragAndDrop.activate(mc2, false, true, true, onOver, onOut, onGrab, null, onDrop);
		function onOver(o:DisplayObject){
			trace("over");
			trace(o.name);
		}
		function onOut(o:DisplayObject){
			trace("out");
			trace(o.name);
		}
		function onGrab(o:DisplayObject){
			trace("grab");
			trace(o.name);
		}
		function onDrag(o:DisplayObject){
			trace("drag");
			trace(o.name);
		}
		function onDrop(o:DisplayObject){
			trace("drop");
			trace(o.name);
			DragAndDrop.terminate(o);
		}
}*/
	public class DragAndDrop {
		// Набор объектов для, которых активирована опция перетаскивания
		// Свойствами этого объекта являются объекты DraggableObj, представляющие конкретные перетаскиваемые объекты
		private static var objectsToDrag:Object = new Object();
		// Текущий перетаскиваемый объект
		private static var currentDragObject:DraggableObj;
		// Счетчик объектов, для которых активировано перетаскивание
		private static var i:uint = 0;
		// Делает объект перетаскиваемым
		public static function activate(dObject:DisplayObject, // Объект, который требуется перетаскивать
										lockCenter:Boolean = true, // Должен ли курсор находиться в точке регистрации перемещаемого объекта
										update:Boolean = true, // Нужно ли использовать updateAfterEvent()
										bringToFront:Boolean = true, // Нужно ли вывести объект на передний план
										globalDragArea:Rectangle = null, // Область перетаскивания (в глобальных координатах)
										onOverFunc:Function = null, // Функция, вызываемая при наведении на объект
										onOutFunc:Function = null, // Функция, вызываемая при уходе с объекта
										onGrabFunc:Function = null, // Функция, вызываемая при клике на объекте
										onDragFunc:Function = null, // Функция, вызываемая при перетаскивании объекта (периодически)
										onDropFunc:Function = null, // Функция, вызываемая при сбросе объекта
										immediateDrag:Boolean = false// Перетаскивание включается сразу без первого клика на объекте
										):void{
			i++;
			// Добавляем объект в набор перетаскиваемых объектов
			objectsToDrag[String(i)] = new DraggableObj(String(i), dObject);
			// Создаем свойства для хранения параметров перетаскивания
			objectsToDrag[String(i)].lc = lockCenter;
			objectsToDrag[String(i)].upd = update;
			objectsToDrag[String(i)].toFront = bringToFront;
			objectsToDrag[String(i)].area = globalDragArea;
			// Создаем свойства для хранения ссылок на внешние функции
			objectsToDrag[String(i)].onOver = onOverFunc;
			objectsToDrag[String(i)].onOut = onOutFunc;
			objectsToDrag[String(i)].onGrab = onGrabFunc;
			objectsToDrag[String(i)].onDrag = onDragFunc;
			objectsToDrag[String(i)].onDrop = onDropFunc;
			objectsToDrag[String(i)].immediateDrag = immediateDrag;
			dObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			dObject.addEventListener(MouseEvent.ROLL_OVER, onMouseOverHandler);
			dObject.addEventListener(MouseEvent.ROLL_OUT, onMouseOutHandler);
			// Если перетаскивание должно начаться сразу при вызове activate()
			if(immediateDrag){
				currentDragObject = getDraggableObject(dObject);
				// Сохраняем дельту расстояний от объекта до курсора
				currentDragObject.initX = dObject.x;
				currentDragObject.initY = dObject.y;
				currentDragObject.dX = dObject.x - dObject.parent.mouseX;
				currentDragObject.dY = dObject.y - dObject.parent.mouseY;
				dObject.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
				dObject.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
				// Выводим перетаскиваемый объект на передний план
				if(currentDragObject.toFront){
					dObject.parent.setChildIndex(dObject, dObject.parent.numChildren - 1);
				}
				if(currentDragObject.onGrab != null){
					currentDragObject.onGrab(currentDragObject.object);
				}
			}
		}
		
		// Отключает возможность перетаскивания объекта
		public static function terminate(dObject:DisplayObject){
			var tmpObj:DraggableObj = getDraggableObject(dObject);
				if(tmpObj != null){
					tmpObj.object.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
					tmpObj.object.removeEventListener(MouseEvent.ROLL_OVER, onMouseOverHandler);
					tmpObj.object.removeEventListener(MouseEvent.ROLL_OUT, onMouseOutHandler);
					// Удаляем обработчики, прикрепленные к stage, поскольку вызов метода terminate()
					// может происходить во время перетаскивания объекта
					if(tmpObj.object.stage != null){
						tmpObj.object.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
						tmpObj.object.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
					}
					// Удаляем объект из набора перетаскиваемых объектов
					delete objectsToDrag[tmpObj.id];
			}
		}
		
		public static function isDraggable(dObject:DisplayObject):Boolean{
			return getDraggableObject(dObject) != null;
		}
		
		// Метод возвращает объект DraggableObj из набора objectsToDrag, хранящий ссылку на переданный параметром DisplayObject
		private static function getDraggableObject(dObject:DisplayObject):DraggableObj{
			for (var i:String in objectsToDrag){
				if(objectsToDrag[i].object == dObject){
					var tmpObj = objectsToDrag[i];
					break;
				}
			}
			return tmpObj;
		}

		// Обработчики
		private static function onMouseDownHandler (e:MouseEvent){
			currentDragObject = getDraggableObject(e.currentTarget as DisplayObject);
			// Сохраняем дельту расстояний от объекта до курсора
			currentDragObject.initX = e.currentTarget.x;
			currentDragObject.initY = e.currentTarget.y;
			currentDragObject.dX = e.currentTarget.x - e.currentTarget.parent.mouseX;
			currentDragObject.dY = e.currentTarget.y - e.currentTarget.parent.mouseY;
			e.currentTarget.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
			e.currentTarget.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
			// Выводим перетаскиваемый объект на передний план
			if(currentDragObject.toFront){
				e.currentTarget.parent.setChildIndex(e.currentTarget, e.currentTarget.parent.numChildren - 1);
			}
			if(currentDragObject.onGrab != null){
				currentDragObject.onGrab(currentDragObject.object);
			}
		}
		
		private static function onMouseOverHandler (e:MouseEvent){
			var tmpObj:DraggableObj = getDraggableObject(e.currentTarget as DisplayObject);
			if(tmpObj.onOver != null){
				tmpObj.onOver(e.currentTarget);
			}
		}
		
		private static function onMouseOutHandler (e:MouseEvent){
			var tmpObj:DraggableObj = getDraggableObject(e.currentTarget as DisplayObject);
			if(tmpObj.onOut != null){
				tmpObj.onOut(e.currentTarget);
			}
		}
		
		private static function onMouseUpHandler (e:MouseEvent){
			e.currentTarget.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
			e.currentTarget.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
			if(currentDragObject.onDrop != null){
				currentDragObject.onDrop(currentDragObject.object);
			}
			currentDragObject = null;
		}
		
		private static function onMouseMoveHandler (e:MouseEvent){
			var c:DisplayObject = currentDragObject.object;
			var pt:Point;
			// Если курсор на точке регистрации
			if(currentDragObject.lc){
				c.x = c.parent.mouseX;
				c.y = c.parent.mouseY;
			}
			// Если курсор на точке, за которую схватился
			else{
				c.x = c.parent.mouseX + currentDragObject.dX;
				c.y = c.parent.mouseY + currentDragObject.dY;
			}
			// Если задана область перетаскивания - контроль ее границ
			if(currentDragObject.area != null){
				var a:Rectangle = currentDragObject.area;
				var l:Point = new Point(a.left, 0);
				var r:Point = new Point(a.right, 0);
				var t:Point = new Point(0, a.top);
				var b:Point = new Point(0, a.bottom);
				c.parent.globalToLocal(l);
				c.parent.globalToLocal(r);
				c.parent.globalToLocal(t);
				c.parent.globalToLocal(b);
				if(c.x < l.x) c.x = l.x;
				if(c.x > r.x) c.x = r.x;
				if(c.y < t.y) c.y = t.y;
				if(c.y > b.y) c.y = b.y;
			}
			if (currentDragObject.upd){
				e.updateAfterEvent();
			}
			if(currentDragObject.onDrag != null){
				currentDragObject.onDrag(c);
			}
		}
		
		/*
		// Возвращает точку, в которой должен оказаться объект, следующий за курсором только по диагонали. Два последних параметра - расстояние от объекта до мыши в момент захвата - используются, когда объект перетаскивается не за точку регистрации
		private static function getConstrainDragPoint(c:DisplayObject, offsetX:Number = 0, offsetY:Number = 0):Point{
			var tmpObj:DraggableObj = getDraggableObject(c);
			var ix:Number = tmpObj.initX;
			var iy:Number = tmpObj.initY;
			// Дельта мыши и объекта по горизонтали и вертикали
			var dx:Number = c.parent.mouseX - ix + offsetX;
			var dy:Number = c.parent.mouseY - iy + offsetY;
			// Абсолютные значения дельты
			var adx:Number = Math.abs(dx);
			var ady:Number = Math.abs(dy);
			// Знаки дельты (с проверкой деления на ноль)
			var sdx:Number = dx == 0 ? 0 : dx/adx;
			var sdy:Number = dy == 0 ? 0 : dy/ady;
			// Минимальная абсолютная дельта без учета знака
			var absOffset:Number = Math.min(adx, ady);
			// Результата - исходные уоординаты плюс минимальная дельта со исходным знаком дельты по каждому направлению
			var pt:Point = new Point();
			pt.x = (ix + sdx * absOffset);
			pt.y = (iy + sdy * absOffset);
			return(pt);
		}
		*/
	}
}
import flash.display.DisplayObject;
import flash.geom.Rectangle;

// Класс - обертка для перетаскиваемого объекта
internal class DraggableObj extends Object{
	// Идентификатор
	public var id:String;
	public var initX:Number;
	public var initY:Number;
	// Перетаскиваемый объект
	public var object:DisplayObject;
	// Расстояние между объектом и курсором
	public var dX:Number;
	public var dY:Number;
	// Курсор на точке регистрации
	public var lc:Boolean;
	// Использование updateAfterEvent
	public var upd:Boolean;
	// Выводить на передний план
	public var toFront:Boolean;
	// Область перетаскивания (в глобальных координатах)
	public var area:Rectangle;
	// Внешние функции, которые могут вызываться на рахных этапах взаимодействия с объектом
	public var onOver:Function;// Наведение
	public var onOut:Function;// Уход
	public var onGrab:Function;// Захват
	public var onDrag:Function;// Перемещение
	public var onDrop:Function;// Отпускание
	public var immediateDrag:Boolean; //Перетаскивание начинается автоматически при активации
	public function DraggableObj(id:String, obj:DisplayObject){
		this.id = id;
		this.object = obj;
	}
}