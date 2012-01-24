package infinitech.ui.slidebar{
	
	import flash.events.MouseEvent;
	import infinitech.ui.slidebar.view.SlideBarView;
	import flash.events.EventDispatcher;
	import infinitech.ui.slidebar.events.SlideBarEvent;
	
	/*
	// Генерирует события:
	// При наведении на полосу прокрутки
	SlideBarEvent.SLIDETRACK_OVER
	// При уходе с полосы прокрутки
	SlideBarEvent.SLIDETRACK_OUT
	// При перемещении ползунка
	SlideBarEvent.SLIDER_EVENT
	// При прекращении перемещения ползунка
	SlideBarEvent.SLIDING_DONE
	// При щелчке на полосе прокрутки
	SlideBarEvent.SLIDETRACK_CLICK
	// При вызове метода setSlidePosition(), устанавливающего положение ползунка
	SlideBarEvent.SLIDER_SET_POSITION
	// При перемещении курсора вдоль полосы прокрутки без нажатия кнопки мыши (при наведении с нажатой)
	SlideBarEvent.OVER_SLIDING
	*/
	
	public class SlideBarController extends EventDispatcher implements ISlideBarController{
		
		// Клип с элементами полосы прокрутки
		private var slideBarView:SlideBarView;
		// Максимальный масштаб ползунка при наведении
		private var sliderMaxScale:Number = 1.7;
		// Должна ли масштабироваться пиктограмма в слайдере, если она там есть
		private var sliderIconScaling:Boolean = false;
		// Выполняется ли прокрутка
		public var sliding:Boolean = false;
		// Минимальное значение диапазона прокрутки
		private var minValue:Number;
		// Максимальное значение диапазона прокрутки
		private var maxValue:Number;
		// Текущее значение прокрутки
		private var currentSlideValue:Number = 0;
		// Отображается ли индикатор буфера
		private var bufferIndicatorOn:Boolean;
		// Активен ли слайдер
		private var active:Boolean;
			
		public function SlideBarController(view:SlideBarView, min:Number, max:Number, bufferIndicatorVisible:Boolean = false, autoactivate:Boolean = true){
			setSlideBarView(view);
			setSlideRange(min, max);
			bufferIndicatorOn = bufferIndicatorVisible;
			displayBufferIndicator(bufferIndicatorOn);
			if(autoactivate) activate();
		}
		
		public function activate(){
			if(!active){
				slideBarView.slider.addEventListener(MouseEvent.MOUSE_OVER, onSliderMouseOver);
				slideBarView.slider.addEventListener(MouseEvent.MOUSE_OUT, onSliderMouseOut);
				slideBarView.slider.addEventListener(MouseEvent.MOUSE_DOWN, onSliderMouseDown);
				slideBarView.slideTrackHitArea.addEventListener(MouseEvent.CLICK, onSlideTrackClick);
				slideBarView.slideTrackHitArea.addEventListener(MouseEvent.MOUSE_OVER, onSlideTrackMouseOver);
				slideBarView.slideTrackHitArea.addEventListener(MouseEvent.MOUSE_OUT, onSlideTrackMouseOut);
				active = true;
			}
		}
		public function deactivate(){
			if(active){
				slideBarView.slider.removeEventListener(MouseEvent.MOUSE_OVER, onSliderMouseOver);
				slideBarView.slider.removeEventListener(MouseEvent.MOUSE_OUT, onSliderMouseOut);
				slideBarView.slider.removeEventListener(MouseEvent.MOUSE_DOWN, onSliderMouseDown);
				slideBarView.slideTrackHitArea.removeEventListener(MouseEvent.CLICK, onSlideTrackClick);
				slideBarView.slideTrackHitArea.removeEventListener(MouseEvent.MOUSE_OVER, onSlideTrackMouseOver);
				slideBarView.slideTrackHitArea.removeEventListener(MouseEvent.MOUSE_OUT, onSlideTrackMouseOut);
				active = false;
			}
		}
		
		// Устанавливает отображение
		public function setSlideBarView (view:SlideBarView){
			slideBarView = view;
		}
		
		
		// Устанавливает положение ползунка прокрутки в диапазоне от minValue до maxValue
		public function setSlidePosition(position:Number):void{
			slideBarView.slider.x = getPositionByValue(position);
			currentSlideValue = position;
			var se:SlideBarEvent = new SlideBarEvent(SlideBarEvent.SLIDER_SET_POSITION);
			se.slideValue = currentSlideValue;
			dispatchEvent(se);
		}
		
		private function getPositionByValue(value:Number){
			return slideBarView.slideTrack.width * ((value - minValue)/(maxValue - minValue));
		}
		
		// Возвращает текущее значение прокрутки в диапазоне от minValue до maxValue
		public function getSlideValue():Number{
			return minValue + (maxValue - minValue) * ((slideBarView.slider.x - slideBarView.slideTrack.x) / slideBarView.slideTrack.width);
		}		
		
		// Возвращает координату ползунка
		public function getSlidePosition():Number{
			return slideBarView.slider.x;
		}
		
		// Задает диапазон изменения значений
		public function setSlideRange(min:Number, max:Number):void{
			minValue = min;
			maxValue = max;
			setSlidePosition(currentSlideValue);
		}
		
		// Включает отображение индикатора буфера
		public function displayBufferIndicator(visibility:Boolean){
			slideBarView.bufferIndicator.visible = visibility;
		}
		
		// Перемещает индикатор буфера в позицию, заданную в пикселах в системе координат, в которой находится bufferIndicator
		public function moveBufferIndicator(position:Number){
			slideBarView.bufferIndicator.x = position;
		}
		
		// Устанавливает заданный размер в пикселах регулятору прокрутки, сохраняя относительное положение всех элементов
		public function resizeSlide(size:Number):void{
			if(bufferIndicatorOn){
				var bufferX = slideBarView.bufferIndicator.x;
				var bufferPosition = bufferX/slideBarView.slideTrack.width;
			}
			var trackWidth = slideBarView.slideTrack.width;
			slideBarView.slideTrack.width = size;
			slideBarView.slideTrackHitArea.width = size;
			setSlidePosition(currentSlideValue);
			var trackRatio = size/trackWidth;
			if(bufferIndicatorOn){
				var newBufferPosition = slideBarView.slideTrack.width * bufferPosition;
				slideBarView.bufferIndicator.width *= trackRatio;
				moveBufferIndicator(newBufferPosition);
			}
		}
		
		// Устанавливает размер полосы буфера на основе относительного значения. Принимает долю заполнения буфера
		public function resizeBufferIndicator(portion:Number){
			slideBarView.bufferIndicator.width = (slideBarView.slideTrack.width - slideBarView.bufferIndicator.x) * portion;
		}
		// Устанавливает размер полосы буфера до заданного значения в диапазоне от min до max
		public function setBufferIndicatorTo(value:Number){
			 slideBarView.bufferIndicator.width = getPositionByValue(value) - slideBarView.bufferIndicator.x;
		}
		
		// Перемещает слайдер в начало и обнуляет индикатор буфера
		public function resetSlideBar(){
			setSlidePosition(minValue);
			if(bufferIndicatorOn){
				resizeBufferIndicator(0);
				moveBufferIndicator(0);
			}
		}
		
//---------------------СОБЫТИЯ------------------------------------------------------------------------------------------		
		
		// Наведение на ползунок
		private function onSliderMouseOver(evt:MouseEvent):void{
			evt.currentTarget.scaleX = evt.target.scaleY = sliderMaxScale;
			if(evt.currentTarget.icon != null && !sliderIconScaling){
				evt.currentTarget.icon.scaleX = evt.currentTarget.icon.scaleY = sliderMaxScale - 1;
			}
		}
		
		// Уход с ползунка
		private function onSliderMouseOut(evt:MouseEvent):void{
			if(!sliding){
				evt.currentTarget.scaleX = evt.currentTarget.scaleY = 1
				if(evt.currentTarget.icon != null && !sliderIconScaling){
					evt.currentTarget.icon.scaleX = evt.currentTarget.icon.scaleY = 1;
				}
			};
		}
		
		// Наведение на полосу прокрутки 
		private function onSlideTrackMouseOver(evt:MouseEvent){
			var se:SlideBarEvent = new SlideBarEvent(SlideBarEvent.SLIDETRACK_OVER);
			se.slideOverPosition = evt.currentTarget.parent.mouseX;
			se.slideValue = minValue + (maxValue - minValue) * ((evt.currentTarget.parent.mouseX - slideBarView.slideTrack.x) / slideBarView.slideTrack.width);
			slideBarView.slideTrackHitArea.addEventListener(MouseEvent.MOUSE_MOVE, onOverSliding);
			dispatchEvent(se);
		}
		
		// Уход с полосы прокрутки
		private function onSlideTrackMouseOut(evt:MouseEvent){
			var se:SlideBarEvent = new SlideBarEvent(SlideBarEvent.SLIDETRACK_OUT);
			se.slideOverPosition = NaN;
			slideBarView.slideTrackHitArea.removeEventListener(MouseEvent.MOUSE_MOVE, onOverSliding);
			dispatchEvent(se);
		}
		
		// Нажатие мыши на ползунке
		private function onSliderMouseDown(evt:MouseEvent):void{
			slideBarView.slider.scaleX = slideBarView.slider.scaleY = sliderMaxScale;
			slideBarView.stage.addEventListener(MouseEvent.MOUSE_MOVE, onSlideHandler);
			slideBarView.stage.addEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp);
			if(slideBarView.slideTrackHitArea.hasEventListener(SlideBarEvent.OVER_SLIDING)){
				slideBarView.slideTrackHitArea.removeEventListener(MouseEvent.MOUSE_MOVE, onOverSliding);
			}
		}
		
		// Отпускание кнопки мыши на всей области сцены
		private function onSliderMouseUp(evt:MouseEvent):void{
			slideBarView.slider.scaleX = slideBarView.slider.scaleY = 1;
			sliding = false;
			var se:SlideBarEvent = new SlideBarEvent(SlideBarEvent.SLIDING_DONE);
			currentSlideValue = getSlideValue();
			se.slideValue = currentSlideValue;
			dispatchEvent(se);
			slideBarView.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSlideHandler);
			slideBarView.stage.removeEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp);
		}
		
		// Щелчок на полосе прокрутки
		private function onSlideTrackClick(evt:MouseEvent){
			slideBarView.slider.x = evt.currentTarget.parent.mouseX;
			var se:SlideBarEvent = new SlideBarEvent(SlideBarEvent.SLIDETRACK_CLICK);
			currentSlideValue = getSlideValue();
			se.slideValue = currentSlideValue;
			if(slideBarView.slideTrackHitArea.hasEventListener(SlideBarEvent.OVER_SLIDING)){
				slideBarView.slideTrackHitArea.removeEventListener(MouseEvent.MOUSE_MOVE, onOverSliding);
			}
			dispatchEvent(se);	
		}
		
		// Вызывается периодически при прокрутке
		private function onSlideHandler (evt:MouseEvent){
			slideBarView.slider.x = slideBarView.slider.parent.mouseX;
			// Проверка границ
			if(slideBarView.slider.x < slideBarView.slideTrack.x) {
				slideBarView.slider.x = slideBarView.slideTrack.x;
			}
			if(slideBarView.slider.x > slideBarView.slideTrack.x + slideBarView.slideTrack.width){
				slideBarView.slider.x = slideBarView.slideTrack.x + slideBarView.slideTrack.width;
			}
				sliding = true;
				evt.updateAfterEvent();
				var se:SlideBarEvent = new SlideBarEvent(SlideBarEvent.SLIDER_EVENT);
				currentSlideValue = getSlideValue();
				se.slideValue = currentSlideValue;
				dispatchEvent(se);
		}
		
		// Вызывается периодически при перемещении курсора вдоль полосы прокрутки
		private function onOverSliding(evt:MouseEvent){
			var se:SlideBarEvent = new SlideBarEvent(SlideBarEvent.OVER_SLIDING);
			se.slideOverPosition = evt.currentTarget.parent.mouseX;
			se.slideValue = minValue + (maxValue - minValue) * ((evt.currentTarget.parent.mouseX - slideBarView.slideTrack.x) / slideBarView.slideTrack.width);
			evt.updateAfterEvent();
			dispatchEvent(se);
		}
	}
}