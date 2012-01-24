package cakeConstructor{
	
	// Dmitri Albert, 2011
	// Version 2
	// Changed: external assets loading
	
	import base64.Base64;
	
	import cakeConstructor.dataFormats.*;
	import cakeConstructor.events.CakeEvent;
	
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	import com.adobe.serialization.json.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.senocular.display.transform.*;
	
	import fl.controls.*;
	import fl.data.*;
	
	import flash.display.*;
	import flash.errors.IOError;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.geom.*;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.*;
	
	import infinitech.ui.scrollFrame.*;
	import infinitech.visual.*;
	

	public class CakeMain extends MovieClip{
		
		// Пунктирные кнопки
		public var openBtn:SimpleButton;
		public var removeImageBtn:SimpleButton;
		public var removeColorBtn:SimpleButton;
		
		//public var openPresetsBtn:SimpleButton;
		public var openGalleryBtn:SimpleButton;
		//public var saveBtn:SimpleButton;
		public var round_rb:RadioButton;
		public var rec_rb:RadioButton;
		public var shapeSelector:RadioButtonGroup;
		public var weight_cb:ComboBox;
		public var person_txt:TextField;
		
		public var cakeBase:CakeBase;
		public var initCakeBaseWidth:Number;
		public var initCakeBaseHeight:Number;
		public var textControls:TextControls;		
		// Спрайт с изображением
		private var topImageContainer:Sprite;
		// Спрайт с надписью
		private var topTextContainer:Sprite;
		// Спрайт, в который добавляются перетаскиваемые пользователем элементы украшения верха	
		private var topDecoContainer:Sprite;
		
		// Кнопки удаления элементов оформления
		public var clearTopDecoBtn1:SimpleButton;
		public var clearTopDecoBtn2:SimpleButton;
		public var clearTopDecoBtn3:SimpleButton;
		public var clearTopDecoBtn4:SimpleButton;
		// Массив с кнопками удаления элементов оформления
		private var clearTopDecoButtons:Array;
		
		// Контейнеры для селекторов элементов оформления
		public var topDecoChoserContainer1:ChoserContainer;
		public var topDecoChoserContainer2:ChoserContainer;
		public var topDecoChoserContainer3:ChoserContainer;
		public var topDecoChoserContainer4:ChoserContainer;		
		// Массив с контейнерами для селекторов выбора элементов украшения
		private var topDecoChoserContainers:Array;		
		private var topDecoChosers:Array;
		
		// Элементы оформления во всех селекторах
		private var decoElements:Array;
		private var curDragDecoElement:DecoElement;
		// Массив с элементами украшения, которые находятся на торте в данный момент
		private var curDecoElements:Array = [];
		
		// Спрайт с прокручиваемыми элементами выбора цвета
		private var topColorChoser:ScrollFrameController;
		// Спрайт, в котором находится topColorChoser
		public var topColorChoserContainer:MovieClip;
		// Элементы выбора цвета, расположенные в элементе выбора цвета
		private var topColorElements:Array;
		
		private var transformTool:TransformTool;
		// Объект с текстовой подсказкой
		private var toolTip:ToolTip;
		// Копия загруженного изображения оригинального размера
		private var sourceBitmapData:BitmapData;	
		private var loader:Loader;
		private var loadingIndicator:LoadingIndicator;
		private var dsf:DropShadowFilter = new DropShadowFilter(3, 90, 0, 1, 5, 5, .3);
		
		// Объект для открытия файлов
		private var fr:FileReference = new FileReference();
		// Объект для сохранения файлов
		private var fileSaver:FileReference = new FileReference();
		private var fileFilter:FileFilter = new FileFilter("Изображения (*.jpg, *.jpeg, *.png, *.gif)", "*.jpg; *.jpeg; *.png; *.gif")

		// Флаги наличия элементов
		private var imageIsOn:Boolean;
		private var transformToolIsOn:Boolean;
		private var colorIsOn:Boolean;
		private var textIsOn:Boolean;
		private var currentShape:String;
		

		
		private var currentWeight:Number;
		private var currentPersonsCount:uint;
		
		private var currentColor:Number = -1;
		private var scaleFactor:Number;
		// Откуда получено изображение
		private var imageSource:String;
		// Ссылка на картинку
		private var imageURL:String;
		private var imageTransformationMatrix:Matrix;
		private var writingTransformationMatrix:Matrix;
		private var weightsList:Array = []; //["1 кг", "1,5 кг", "2 кг", "2,5 кг", "3 кг", "3,5 кг", "4 кг", "4,5 кг", "5 кг"];
		private var scaleFactorsList:Array = []; //[.6, .55, .50, .45, .4, .38, .32, .3, .25];
		private var personsList:Array = [];// = [6, 10, 15, 20, 25, 30, 35, 40, 45];
		
		// Данные о селекторах и составе элементов оформления
		private var decoSelectorsData:Array;
		private var decoSelectorsNum:uint;
		
		public function CakeMain(){
// Временно отключено			
			openGalleryBtn.visible = false;
//
			//openPresetsBtn.visible = false;
			topDecoChoserContainers = [topDecoChoserContainer1, topDecoChoserContainer2, topDecoChoserContainer3, topDecoChoserContainer4];
			clearTopDecoButtons = [clearTopDecoBtn1, clearTopDecoBtn2, clearTopDecoBtn3, clearTopDecoBtn4];
			topDecoChosers = [];
		}
		
		// Для вызова из JS (через родительский объект Preloader)
		public function initialize (data:String, shape:String, scale:Number):void{
			try{
				var d:Object = JSON.decode(data);
			}
			catch(e:Error){
				var msg:String = "Ошибка парсинга в initialize(). Некорректный JSON.";
				ExternalInterface.call("onError", msg);
			}
			
			weightsList = d.weightsList;
			scaleFactorsList = d.ratiosList;
			personsList = d.personsList;
			
			currentShape = shape;
			setScaleFactor(scale);	
			
			decoSelectorsData = d.decoSelectors;
			decoSelectorsNum = decoSelectorsData.length;
			
			// Убираем лишние "болванки" селекторов и кнопок удаления элементов
			for(var i:uint = decoSelectorsNum; i < topDecoChoserContainers.length; i++){
				topDecoChoserContainers[i].visible = false;
				clearTopDecoButtons[i].visible = false;
			}
			// Количество элементов в каждом селекторе
			var numElements:uint;
			// Для каждого переданного селектора
			for(var sel:uint = 0; sel < decoSelectorsNum; sel++){
				numElements = decoSelectorsData[sel].deco.length;
				// Сохраняем в контейнере ссылку на очищающую его кнопку
				topDecoChoserContainers[sel].clearButton = clearTopDecoButtons[sel];
				for(var el:uint = 0; el < numElements; el ++){
					topDecoChoserContainers[sel].urls.push(decoSelectorsData[sel].deco[el].url);
					topDecoChoserContainers[sel].descriptions.push(decoSelectorsData[sel].deco[el].description);
					topDecoChoserContainers[sel].types.push(decoSelectorsData[sel].deco[el].name);
					topDecoChoserContainers[sel].autorotates.push(decoSelectorsData[sel].deco[el].autorotate);
				}		
			}
			setUI();
		}
		
		// Устанавливает scaleFactor, в наиболее близкое значение к допустимым
		// Если переданное значение лежит за пределами допустимых, оно устанавливается в граничное значение
		private function setScaleFactor(scale:Number){
			scaleFactor = NaN;
			for(var i:uint; i < scaleFactorsList.length - 1; i++){
				if(scale <= scaleFactorsList[i] && scale > scaleFactorsList[i + 1]){
					scaleFactor = scaleFactorsList[i];
					break;
				}
			}
			if(isNaN(scaleFactor)){
				if(scale > scaleFactorsList[0]){
					scaleFactor = scaleFactorsList[0];
				}
				else if(scale <= scaleFactorsList[scaleFactorsList.length - 1]){
					scaleFactor = scaleFactorsList[scaleFactorsList.length - 1]
				}
			}
		}
	
		public function loadCakePreset(data:String):void{
			try{
				var d:Object = JSON.decode(data);
			}
			catch(e:Error){
				var msg:String = "Ошибка парсинга в loadCakePreset(). Некорректный JSON.";
				ExternalInterface.call("onError", msg);
				data = '{"content":{"base_color":-1},"dimensions":{"persons_count":6,"ratio":0.6,"mass":1,"shape":"rect"}}';
				d = JSON.decode(data);
			}

			if(curDragDecoElement != null){
				curDragDecoElement = null;
			}
			setScaleFactor(d.dimensions.ratio);
			updateWeightChoser();

			reshape(d.dimensions.shape);
			updateShapeSelector();

			if(!isNaN(d.content.base_color)){
				setCakeBaseColor(d.content.base_color);
			}
			
			if(d.content.photo != null){
				imageSource = d.content.photo.image_source;
				imageTransformationMatrix = arrayToMatrix(d.content.photo.transform);
				if(imageSource == CakeImageData.NETWORK_IMAGE_SOURCE){
					loadExternalImage(d.content.photo.photo_url);
				}
			}
			
			if(d.content.text != null){
				textControls.setText(d.content.text.value, d.content.text.font, d.content.text.size, d.content.text.color);
				writingTransformationMatrix = arrayToMatrix(d.content.text.transform);
				topTextContainer.transform.matrix = writingTransformationMatrix;
			}
			
			if(d.content.deco != null){
				for(var i:uint = 0; i < d.content.deco.length; i++){
					var type = d.content.deco[i].name;
					var selector = getElementSelectorByType(type);
					var decoElementSource:DecoElement = getDecoElementInSelectorByType(type, selector);					
					curDragDecoElement = new DecoElement(type, null, null, decoElementSource);
					curDragDecoElement.setChoserContainer(selector);
					topDecoContainer.addChild(curDragDecoElement);
					curDragDecoElement.transform.matrix = arrayToMatrix(d.content.deco[i].transform);
					curDragDecoElement.getImage().scaleX = curDragDecoElement.getImage().scaleY = scaleFactor;
					curDragDecoElement.filters = [dsf];
					DragAndDrop.activate(curDragDecoElement, true, true, true, null, null, null, onGrabTopDecoFunc, onDragTopDecoFunc, onDropTopDecoFunc);
					curDecoElements.push(curDragDecoElement);
					selector.elementsInUse.push(curDragDecoElement);
					enableDashedBtn(selector.clearButton);
				}
				var p:Array = curDecoElements.join(",").split(",");
				ExternalInterface.call("onElementAdded", CakeData.PRESET, p);
				trace("Added from preset:  [" + p + "]");
			}
		}
		
		private function matrixToArray(m:Matrix):Array{
			return [m.a, m.b, m.c, m.d, m.tx, m.ty];
		}
		
		private function arrayToMatrix(a:Array):Matrix{
			return new Matrix (a[0], a[1], a[2], a[3], a[4], a[5]);
		}
		
		// Определяет, к какому селектору относится данный тип элемента
		private function getElementSelectorByType(type:String):ChoserContainer{
			var selector:ChoserContainer;
			outer: for(var sel:uint = 0; sel < decoSelectorsNum; sel++){
				for(var t:uint = 0; t < topDecoChoserContainers[sel].types.length; t++){
					if(type == topDecoChoserContainers[sel].types[t]){
						selector = topDecoChoserContainers[sel];
						break outer;
					}
				}	
			}
			return selector;
		}
		
		// Возвращает ссылку на элемент из селектора по заданному типу
		private function getDecoElementInSelectorByType(type:String, selector:ChoserContainer):DecoElement{
			var decoElement:DecoElement;
			for(var i:uint = 0; i < selector.choser.numChildren; i++){
				var curElement:DecoElement = selector.choser.getChildAt(i) as DecoElement;
				if(curElement.getType() == type){
					decoElement = curElement;
					break;
				}
			}
			return decoElement;
		}		
		
		// Удаляет ссылки на stage перед повторной инициализацией
		public function cleanUp(){
			prepareReshape();
			if(textControls != null){
				textControls.killStageReferences();
			}
			stage.removeEventListener(MouseEvent.CLICK, onStageClick);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);

		}
		
		private function prepareReshape(){
			clearCakeBaseColor();
			clearTopDecoContainer();
			removeImage();
			removeTransformTool();
			for(var sel:uint = 0; sel < decoSelectorsNum; sel++){
				disableDashedBtn(topDecoChoserContainers[sel].clearButton);
			}
		}
		
		// Инициализация с новой формой (сброс всего содержимого)
		private function reshape(shape:String){
			if(shape == CakeData.ROUNDED || shape == CakeData.RECT){
				currentShape = shape;
				prepareReshape();
				setCakeBase();
				setTextControls();
				cakeBase.applyMask(topImageContainer);
				setTransformTool();
				trace("onReset() called");
				ExternalInterface.call("onReset");
			}
			else{
				trace("В reshape() передано недопустимое значение формы: " + shape);
				var msg:String = "Передано недопустимое значение формы: " + shape + ". Допускаются только следующие значения: " + CakeData.ROUNDED + ", " + CakeData.RECT;
				ExternalInterface.call("onError", msg);
			}
		}
		
		private function setUI(){
			setCakeBase();
			setTopImageContainer();
			setTextControls();
			setTopDecoChosers();
			setTopColorChoser(CakeData.TOP_COLORS);			
			setFileOperationsAssets();
			setTransformTool();
			setToolTip();
			setContextMenu();
			setShapeSelector();
			setWeightChoser();
		}

		private function setCakeBase(){
			cakeBase.setShape(currentShape);
			initCakeBaseWidth = cakeBase.width;
			initCakeBaseHeight = cakeBase.height;
		}
		
		private function setTopImageContainer(){
			// Если контейнер уже существует, очищаем его, т.к. при смене формы торта нужно вновь создать маску, которая является растровым дубликатом формы контейнера
			if(topImageContainer != null){
				cakeBase.removeChild(topImageContainer);
				topImageContainer = null;
			}
			topImageContainer = new Sprite();
			cakeBase.addChild(topImageContainer);
			imageTransformationMatrix = new Matrix();
			cakeBase.applyMask(topImageContainer);
		}
		
		private function setTextControls(){
			textIsOn = false;
			if(topTextContainer == null){
				topTextContainer = new Sprite();
				cakeBase.addChild(topTextContainer);
			}
			else{
				textControls.removeText();
			}
			
			if(topTextContainer.numChildren > 0){
				topTextContainer.removeChildAt(0);
			}
			
			topTextContainer.transform.matrix = new Matrix();
			topTextContainer.x = cakeBase.color_mc.x + .5 * cakeBase.color_mc.width;
			topTextContainer.y = cakeBase.color_mc.y + .5 * cakeBase.color_mc.height;
			cakeBase.applyMask(topTextContainer);
			if(!textControls.hasEventListener(CakeEvent.TEXT_CHANGE_EVENT)){
				textControls.addEventListener(CakeEvent.TEXT_CHANGE_EVENT, onTextChange);
			}
			writingTransformationMatrix = new Matrix();
			disableDashedBtn(textControls.removeBtn);
		}
		
		private function setTopColorChoser(elementsList){
			topColorElements = [];
			// Для всех, кроме последнего, назначаем цвет. последний остается без цвета
			for (var i:uint; i <= elementsList.length; i++){
				var cnst:Class = getDefinitionByName("ColorPlate") as Class;
				var el:ColorElement = new cnst() as ColorElement;
				if(i < elementsList.length){
					el.setColor(elementsList[i]);
				}
				topColorElements.push(el);
			}
			topColorChoser = setChoser(topColorElements, topColorChoserContainer);
			topColorChoser.addEventListener(MouseEvent.CLICK, onColorChoserClick);
			removeColorBtn.addEventListener(MouseEvent.CLICK, onRemoveColorBtnClick);
			disableDashedBtn(removeColorBtn);
		}

		private function setTopDecoChosers(){
			decoElements;
			var urls:Array;
			var types:Array;
			var descriptions:Array;
			var autorotates:Array;
			var el:DecoElement;
			for(var sel:uint = 0; sel < decoSelectorsNum; sel++){
				decoElements = [];
				urls = topDecoChoserContainers[sel].urls;
				types = topDecoChoserContainers[sel].types;
				descriptions = topDecoChoserContainers[sel].descriptions;
				autorotates = topDecoChoserContainers[sel].autorotates;
				var i:uint;
				for (i = 0; i < urls.length; i++){
					el = new DecoElement(types[i], descriptions[i], urls[i], null, autorotates[i]);
					// Чтобы элемент "знал", к какому селектору он относится, сохраняем в нем ссылку на контейнер селектора
					el.setChoserContainer(topDecoChoserContainers[sel]);
					decoElements.push(el);
				}
				topDecoChosers[sel] = setChoser(decoElements, topDecoChoserContainers[sel]);
				topDecoChosers[sel].addEventListener(MouseEvent.MOUSE_DOWN, onTopDecoDown);				
				disableDashedBtn(topDecoChoserContainers[sel].clearButton);
			}
			setTopDecoContainer();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		// Проверяет окончание загрузки картинок в элементах оформления
		private function onEnterFrame(evt:Event){
			var allLoaded:Boolean = true;
			for(var i:uint = 0; i < decoElements.length; i++){
				if(!decoElements[i].isLoaded()){
					allLoaded = false;
					break;
				}
			}
			if(allLoaded){
				//openPresetsBtn.visible = true;
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				trace("Элементы оформления загрузились");
				ExternalInterface.call("onDecoElementsLoaded");
			}
		}
		
		private function setTopDecoContainer(){
			// Если контейнер уже существует, просто перемещаем его на передний план, т.к. он не маскируется и его форма не меняется
			if(topDecoContainer == null){
				topDecoContainer = new Sprite();
				cakeBase.addChild(topDecoContainer);
			}
			else{
				clearTopDecoContainer();
				cakeBase.setChildIndex(topDecoContainer, cakeBase.numChildren - 1);
			}
			// Устанавливаем обработчики для кнопок удаления элментов оформления, привязанных к каждому селектору
			for(var sel:uint = 0; sel < decoSelectorsNum; sel++){
				if(!topDecoChoserContainers[sel].clearButton.hasEventListener(MouseEvent.CLICK)){
					topDecoChoserContainers[sel].clearButton.addEventListener(MouseEvent.CLICK, onClearTopDecoBtnClick);
				}
			}
		}
		
		public function clearTopDecoContainer(){
			while(topDecoContainer.numChildren > 0){
				var c:DisplayObject = topDecoContainer.getChildAt(0);
				DragAndDrop.terminate(c);
				topDecoContainer.removeChild(c);
			}
			for(var sel:uint = 0; sel < decoSelectorsNum; sel++){
				topDecoChoserContainers[sel].elementsInUse = [];
				disableDashedBtn(topDecoChoserContainers[sel].clearButton);
			}
			curDecoElements = [];
		}
		
		private function setFileOperationsAssets(){
			openBtn.addEventListener(MouseEvent.CLICK, onOpenBtnClick);
			removeImageBtn.addEventListener(MouseEvent.CLICK, onRemoveImageBtnClick);
			//saveBtn.addEventListener(MouseEvent.CLICK, onSaveBtnClick);
			openGalleryBtn.addEventListener(MouseEvent.CLICK, onOpenGalleryBtnClick);
			//openPresetsBtn.addEventListener(MouseEvent.CLICK, onOpenPresetsBtnClick);
			loader = new Loader();
			fr.addEventListener(Event.SELECT, onFileSelect);
			fr.addEventListener(Event.COMPLETE, onFileOpen);
			loader.contentLoaderInfo.addEventListener(Event.OPEN, onFileLoadStart);
			loader.contentLoaderInfo.addEventListener(Event.INIT, onFileLoadComplete);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onFileLoadProgress);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			disableDashedBtn(removeImageBtn);
		}
		
		private function setTransformTool(){
			if(!transformToolIsOn){
				transformTool = new TransformTool(new ControlSetStandard());
				cakeBase.addChild(transformTool);
				// Ограничения для того чтобы при трансформации длинного текста он автоматически подгонялся по допустимый размер
				//transformTool.maxWidth = 400;
				//transformTool.maxHeight = 400;
				transformTool.moveBounds = new Rectangle(20, 20, 260, 260);
				if(stage != null){
					stage.addEventListener(MouseEvent.CLICK, onStageClick);
					stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
				}
				transformToolIsOn = true;
			}
		}
		
		private function removeTransformTool(){
			if(transformToolIsOn){
				cakeBase.removeChild(transformTool);
				transformTool.target = null;
				transformTool = null;
				transformToolIsOn = false;
			}
		}
		
		private function setToolTip(){
			toolTip = new ToolTip();
			addChild(toolTip);
		}
		
		private function setContextMenu(){
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
			var ci:ContextMenuItem = new ContextMenuItem("Дмитрий Альберт, 2011");
			menu.customItems.push(ci);
			contextMenu = menu;
		}
		
		private function setShapeSelector(){
			shapeSelector = new RadioButtonGroup("shapeSelector");
			round_rb.value = CakeData.ROUNDED;
			rec_rb.value = CakeData.RECT;
			var tf:TextFormat = new TextFormat("Arial", 12, 0x333333)
			shapeSelector.addRadioButton(round_rb);
			shapeSelector.addRadioButton(rec_rb);
			round_rb.setStyle("textFormat", tf);
			rec_rb.setStyle("textFormat", tf);
			shapeSelector.addEventListener(MouseEvent.CLICK, onShapeSelectorChange);
			updateShapeSelector();
		}
		
		private function updateShapeSelector(){
			for(var i:uint = 0; i < shapeSelector.numRadioButtons; i++){
				var rb:RadioButton = shapeSelector.getRadioButtonAt(i);
				rb.mouseEnabled = true;
				if(rb.value == currentShape){
					rb.mouseEnabled = false;
					shapeSelector.selection = rb;
				}
			}
		}
		// Вызывается из JS
		public function changeShape(shape:String){
			reshape(shape);
			// Вызывается для отключения кликабельности выбранной кнопки (исключение клика на уже выбранной кнопке)
			updateShapeSelector();
		}
		
		private function onShapeSelectorChange(evt:MouseEvent){
			var shape:String = evt.currentTarget.selectedData;
			
			if(colorIsOn || imageIsOn || textIsOn || topDecoContainer.numChildren > 0){
				trace("Вызвана функция confirmShapeChange()");
				ExternalInterface.call("confirmShapeChange", shape);
			} else {
				reshape(shape);
			}
			
			updateShapeSelector();
		}
		
		// Инициализирует элемент для установки веса торта
		private function setWeightChoser(){
			var dp:Array = [];
			// Объект, свойства которого будут связаны с элементом списка
			var tmpObj:Object;
			var currentIndex:int = -1;
			var i:uint;
			for(i = 0; i < weightsList.length; i++){
				tmpObj = new Object();
				tmpObj.label = weightsList[i] + " кг (на " + personsList[i] + (personsList[i] > 4 ? " человек" : " человека") + ")";
				tmpObj.scaleFactor = scaleFactorsList[i];
				tmpObj.weight = weightsList[i];
				tmpObj.persons = personsList[i];
				if(tmpObj.scaleFactor == scaleFactor){
					currentIndex = i;
				}
				tmpObj.persons = personsList[i];
				dp.push(tmpObj);
			}
			weight_cb.rowCount = 9;
			weight_cb.dataProvider = new DataProvider(dp);
			var currentItem = weight_cb.getItemAt(currentIndex);
			weight_cb.selectedItem = currentItem;
			currentWeight = currentItem.weight;
			currentPersonsCount = currentItem.persons;			
			weight_cb.addEventListener(Event.CHANGE, onWeightChange);
		}
		
		private function updateWeightChoser(){
			for(var i:uint = 0; i < weight_cb.length; i++){
				var currentItem = weight_cb.getItemAt(i);
				if(currentItem.scaleFactor == scaleFactor){
					weight_cb.selectedItem = currentItem;
					break;
				}
			}
		}
		
		private function onWeightChange(evt:Event){
			scaleFactor = evt.target.selectedItem.scaleFactor;
			currentWeight = evt.target.selectedItem.weight;
			currentPersonsCount = evt.target.selectedItem.persons;
			for(var i:uint = 0; i < curDecoElements.length; i++){
				TweenLite.to(curDecoElements[i].getImage(), 1, {scaleX:scaleFactor, scaleY:scaleFactor, ease:Elastic.easeOut})
			}
			trace("Вес изменен. Новый коэффициент масштаба: " + scaleFactor );
			ExternalInterface.call("onWeightChanged", scaleFactor);
		}
		
		public function setCakeBaseColor(color:Number){
			if(color > 0){
				cakeBase.setColor(color);
				currentColor = color;
				colorIsOn = true;
				enableDashedBtn(removeColorBtn);
				trace("added:  " + CakeData.COLOR);
				ExternalInterface.call("onElementAdded", CakeData.COLOR);
			}
			else{
				clearCakeBaseColor();
				trace("removed:  " + CakeData.COLOR);
				ExternalInterface.call("onElementRemoved", CakeData.COLOR);
			}
		}
		
		public function clearCakeBaseColor(){
			if(colorIsOn){
				cakeBase.clearColor();
				disableDashedBtn(removeColorBtn);
				currentColor = -1;
				colorIsOn = false;
			}
		}
		
		// Устанавливает элемент для выбора. Принимает массив элементов для прокрутки и ссылку на контейнер
		private function setChoser(objectsToChose:Array, container:MovieClip):ScrollFrameController{
			var prevBtn:SimpleButton;
			var nextBtn:SimpleButton;
			var choser:ScrollFrameController;
			container.removeChildAt(0);
			choser = new ScrollFrameController(objectsToChose, 4, 10);
			container.choser = choser;
			var cnst:Class = getDefinitionByName("scrollButton") as Class;
			prevBtn = new cnst() as SimpleButton;
			nextBtn = new cnst() as SimpleButton;
			container.addChild(choser);
			container.addChild(prevBtn);
			container.addChild(nextBtn);
			prevBtn.scaleX = -1;
			var b:Rectangle = choser.getVisibleBounds();
			prevBtn.x = prevBtn.width;
			choser.x = prevBtn.x + 10;
			nextBtn.x = choser.x + b.width + 10;
			prevBtn.addEventListener(MouseEvent.CLICK, onPrevBtnClick);
			nextBtn.addEventListener(MouseEvent.CLICK, onNextBtnClick);
			choser.addEventListener(MouseEvent.MOUSE_OVER, onChoserOver);
			choser.addEventListener(MouseEvent.MOUSE_OUT, onChoserOut);
			return choser;
		}
		
		private function onPrevBtnClick(evt:MouseEvent){
			evt.target.parent.choser.scrollPrev();
		}
		private function onNextBtnClick(evt:MouseEvent){
			evt.target.parent.choser.scrollNext();
		}
		
		private function onChoserOver(evt:MouseEvent){
			evt.target.parent.showPlate();
			if(evt.target.parent is DecoElement){
				var lpt:Point = new Point(evt.target.parent.x,  evt.target.parent.y + .5 * evt.target.parent.getPlate().height);
				var gpt:Point = evt.target.parent.parent.localToGlobal(lpt);
				toolTip.display(evt.target.parent.getInfo(), gpt.x, gpt.y)
			}
		}
		
		private function onChoserOut(evt:MouseEvent){			
			if(evt.target.parent is DecoElement){
				if(evt.target.parent.isLoaded()){
					evt.target.parent.clearPlate();
				}
				toolTip.clear();
			}
			else{
				evt.target.parent.clearPlate();
			}
		}
		
		// При нажатии на объекте в прокручиваемом списке элементов украшения
		private function onTopDecoDown(evt:MouseEvent){
			var elementClicked:DecoElement = evt.target.parent as DecoElement;
			// Перетаскивать можно только элемент с загруженной графикой
			if(elementClicked.isLoaded()){
				curDragDecoElement = new DecoElement(elementClicked.getType(), elementClicked.getInfo(), null, elementClicked);
				// Сохраняем в новом элементе ссылку на конейнер селектора, к которому он относится
				curDragDecoElement.setChoserContainer(elementClicked.getChoserContainer());
				topDecoContainer.addChild(curDragDecoElement);
				curDragDecoElement.alpha = .5;
				//trace(elementClicked.parent.parent == topDecoChoserContainers[0]);
				var pt:Point = new Point(elementClicked.x, elementClicked.y);
				pt = elementClicked.parent.localToGlobal(pt);
				pt = topDecoContainer.globalToLocal(pt);		
				curDragDecoElement.x = pt.x;
				curDragDecoElement.y = pt.y - 20;
				curDragDecoElement.getImage().scaleX = curDragDecoElement.getImage().scaleY = scaleFactor;
				DragAndDrop.activate(curDragDecoElement, true, true, true, null, null, null, onGrabTopDecoFunc, onDragTopDecoFunc, onDropTopDecoFunc, true);
			}
		}
		
		// При щелчке на цвете в прокручиваемом списке цветов
		private function onColorChoserClick(evt:MouseEvent){
			var color:Number = evt.target.parent.getColor();
			setCakeBaseColor(color);
		}
		
		// Функции, вызываемые на разных этапах перетаскивания
		private function onGrabTopDecoFunc(obj:DisplayObject){
			curDragDecoElement = obj as DecoElement;
			curDragDecoElement.filters = [];
			// Плавная полупрозрачность
			TweenLite.to(curDragDecoElement, 1, {alpha:.5});
			//curDragDecoElement.alpha = .5;
		}
		
		private function onDragTopDecoFunc(obj:DisplayObject){
			var el = obj as DecoElement;
			if(!el.getAutorotate()){
				return;
			}
			var pt:Point = new Point(obj.x, obj.y);
			var gpt:Point = obj.parent.localToGlobal(pt);
			var lcpt:Point = new Point(cakeBase.x + .5 * initCakeBaseWidth, cakeBase.y + .5 * initCakeBaseHeight);
			var cpt:Point = cakeBase.parent.localToGlobal(lcpt);
			var a:Number = Math.atan2(cpt.y - gpt.y, cpt.x - gpt.x)/Math.PI * 180;
			obj.rotation = a;
		}
		
		private function onDropTopDecoFunc (obj:DisplayObject){
			var curChoserContainer:ChoserContainer = curDragDecoElement.getChoserContainer();
			var lpt:Point = new Point(curDragDecoElement.x, curDragDecoElement.y);
			var gpt = cakeBase.localToGlobal(lpt);
			var j:uint;
			// Если не попали на торт
			if(!cakeBase.color_mc.hitTestPoint(gpt.x, gpt.y, true)){
				// Удаляем ссылку на объект из массива curDecoElements и сообщаем об удалении элемента
				for(var i:uint; i < curDecoElements.length; i++){
					// Если это элемент, который находится на торте, а не новый элемент, который "не дотащили"
					if(curDecoElements[i] == curDragDecoElement){
						// Удаляем также ссылку на объект из массива elementsInUse контейнера селектора
						var elementsInUse:Array = curChoserContainer.elementsInUse;
						for(j = 0; j < elementsInUse.length; j++){
							if(curDecoElements[i] == elementsInUse[j]){
								elementsInUse.splice(j, 1);
								break;
							}
						}
						curDecoElements.splice(i, 1);
						trace("removed:  " + curDragDecoElement.toString());
						ExternalInterface.call("onElementRemoved", curDragDecoElement.toString());
						break;
					}
				}
				DragAndDrop.terminate(curDragDecoElement);
				topDecoContainer.removeChild(curDragDecoElement);
				curDragDecoElement = null;
			
			}
			// Сброс в области торта
			else{
				// Анимация при сбросе
				var k = .8; // Относительное уменьшение масштаба
				var d = .15; // Время уменьшения масштаба
				var t:TimelineLite = new TimelineLite();
				// Восставновление непрозрачности
				t.append(new TweenLite(curDragDecoElement, d, {alpha:1}));
				// Уменьшение масштаба
				t.append(new TweenLite(curDragDecoElement.getImage(), d, {scaleX:k*scaleFactor, scaleY:k*scaleFactor, ease:Quad.easeOut}));
				// Возврат к прежнему масштабу с эластичным эффектом
				t.append(new TweenLite(curDragDecoElement.getImage(), 1, {scaleX:scaleFactor, scaleY:scaleFactor, ease:Elastic.easeOut})); 
				t.play();
				// Конец анимации при сбросе
				curDragDecoElement.filters = [dsf];
				// Флаг, обозначающий, добавляется ли на торт новый элемент (или просто был перемещен уже имеющийся)
				var newElement:Boolean = true;
				for(j = 0; j < curDecoElements.length; j++){
					if(curDecoElements[j] == curDragDecoElement){
						newElement = false;
						break;
					}
				}
				if(newElement){
					curDecoElements.push(curDragDecoElement);
					curChoserContainer.elementsInUse.push(curDragDecoElement);
					trace("added:  " + curDragDecoElement.toString());
					ExternalInterface.call("onElementAdded", curDragDecoElement.toString());
				}
				enableDashedBtn(curChoserContainer.clearButton);
			}
			// Если элементов оформления, относящихся к селектору текущего элемента на торте больше нет
			if(curChoserContainer.elementsInUse.length == 0){
				disableDashedBtn(curChoserContainer.clearButton);
			}
		}
		
		// Устанавка рамки трансформации для надписи или картинки при щелчке на них
		private function onStageClick(evt:MouseEvent){
			var textBitmapSprite:Sprite;
			if(topTextContainer.numChildren > 0){
				textBitmapSprite = topTextContainer.getChildAt(0) as Sprite;
			}
			// Клик на надписи
			if(evt.target == textBitmapSprite){
				transformTool.target = topTextContainer;
			}
			// Клик на картинке
			else if(evt.target == topImageContainer){
				transformTool.target = topImageContainer;
			}
			if(transformToolIsOn){
				transformTool.registrationManager.defaultUV = new Point(.5, .5);
			}
		}
		
		// Снятие рамки трансформации при нажатии мыши вне трансформируемых объектов
		private function onStageMouseDown(evt:MouseEvent){
			if(transformToolIsOn){
				var textBitmapSprite:Sprite;
				if(topTextContainer.numChildren > 0){
					textBitmapSprite = topTextContainer.getChildAt(0) as Sprite;
				}
				// Если мышь нажата не над надписью, картинкой или маркером рамки трансформации - снимаем рамку инструмента трансформации
				if(evt.target != textBitmapSprite && evt.target != topImageContainer && evt.target.parent != transformTool){
					transformTool.target = null;
					transformTool.registrationManager.defaultUV = new Point(.5, .5);
				}
			}
		}
		
		private function disableDashedBtn(btn:SimpleButton){
			btn.mouseEnabled = false;
			var t:Transform = new Transform(btn);
			var ct:ColorTransform = new ColorTransform();
			ct.color = 0xbbbbbb;
			t.colorTransform = ct;
		}
		
		private function enableDashedBtn(btn:SimpleButton){
			btn.mouseEnabled = true;
			var t:Transform = new Transform(btn);
			t.colorTransform = new ColorTransform();
		}
		
		private function onOpenBtnClick(evt:MouseEvent){
			fr.browse([fileFilter]);
		}
		
		private var imageCounter:uint;
		private function onOpenGalleryBtnClick(evt:MouseEvent){
			trace ("Вызвана функция openImageGallery()");
			ExternalInterface.call("openImageGallery");
			imageTransformationMatrix = new Matrix();
// Код для локальной демо-версии
//			var images:Array = ["http://t3.gstatic.com/images?q=tbn:ANd9GcRSQPXta7sN8BUT6eJzXrEN0vZX08YtZ8tqyiwQTGt32vsg4L_k",
//								"http://agudo.ru/uploads/posts/2009-09/1251785393_guinea-pig-square.jpg",
//								"http://www.babai.ru/upload/iblock/ea1/ea1851f38b8a5cc008218e095897559d.jpg",
//								"http://fotodryg.ru/clipart/1/4/2.png",
//								"http://img-fotki.yandex.ru/get/3611/tratatawinxalina.2/0_151a8_ebf099f1_L",
//								"http://t0.gstatic.com/images?q=tbn:ANd9GcRbtbWKasFzQBR1ZJ5yk0wgD-9xmRxZOCW-F7ly5OykoFz3-VSsAQ",
//								"http://t0.gstatic.com/images?q=tbn:ANd9GcTeHmf37UyVn6Cyj9U0Hbq2qiImpsbwQ0wInI-b4n07ZV5_SzSd",
//								"http://t0.gstatic.com/images?q=tbn:ANd9GcSKQfSoJPosX-yFPRUkvGJwSaPFId1TTsivH5VZkKb2EoGjHVJ3bQ"];
//			//var images:Array = ["images/1.jpg", "images/2.jpg", "images/3.jpg", "images/4.png", "images/5.jpg", "images/6.jpg", "images/7.jpg", "images/8.jpg"];
//			if(isNaN(imageCounter) || imageCounter == images.length) imageCounter = 0;
//			loadExternalImage(images[imageCounter]);
//			imageCounter++;
// Конец кода для локальной демо-версии
		}
		
		private var presetCounter:uint;
		private function onOpenPresetsBtnClick(evt:MouseEvent){
			ExternalInterface.call("openCakePresets");
// Код для локальной демо-версии
//			var preset1:String = '{"cakeBaseColor":3342336,"deco":{"decoElements":[{"type":"Raspberry","transformMatrix":{"ty":265,"a":-0.407440185546875,"b":-0.911895751953125,"c":0.911895751953125,"d":-0.407440185546875,"tx":203}},{"type":"Raspberry","transformMatrix":{"ty":265,"a":-0.5848541259765625,"b":-0.8092193603515625,"c":0.8092193603515625,"d":-0.5848541259765625,"tx":234}},{"type":"Raspberry","transformMatrix":{"ty":264,"a":-0.7071075439453125,"b":-0.7071075439453125,"c":0.7071075439453125,"d":-0.7071075439453125,"tx":264}},{"type":"Raspberry","transformMatrix":{"ty":240,"a":-0.602630615234375,"b":-0.7960357666015625,"c":0.7960357666015625,"d":-0.602630615234375,"tx":219}},{"type":"Raspberry","transformMatrix":{"ty":240,"a":-0.7372894287109375,"b":-0.67315673828125,"c":0.67315673828125,"d":-0.7372894287109375,"tx":248}},{"type":"Raspberry","transformMatrix":{"ty":214,"a":-0.7965545654296875,"b":-0.6019439697265625,"c":0.6019439697265625,"d":-0.7965545654296875,"tx":234}},{"type":"Raspberry","transformMatrix":{"ty":235,"a":0.7886505126953125,"b":-0.6122589111328125,"c":0.6122589111328125,"d":0.7886505126953125,"tx":46}},{"type":"Raspberry","transformMatrix":{"ty":100,"a":0.9189300537109375,"b":0.3914031982421875,"c":-0.3914031982421875,"d":0.9189300537109375,"tx":31}},{"type":"Raspberry","transformMatrix":{"ty":77,"a":-0.78851318359375,"b":0.6124267578125,"c":-0.6124267578125,"d":-0.78851318359375,"tx":251}},{"type":"Raspberry","transformMatrix":{"ty":68,"a":0.81671142578125,"b":0.5743560791015625,"c":-0.5743560791015625,"d":0.81671142578125,"tx":34}}]},"scaleFactor":0.7,"writing":{"text":"Поздравляю!","font":"Arial","size":24,"color":16777215,"transformMatrix":{"ty":22.85,"a":0.9999803900718689,"b":-0.006264772266149521,"c":0.006264772266149521,"d":0.9999803900718689,"tx":94.15}},"cakeBaseShape":"rectangular","image":{"imageSource":"network","imageURL":"images/4.png","transformMatrix":{"ty":16.1,"a":0.7391204833984375,"b":0,"c":0,"d":0.7391204833984375,"tx":12.35}}}';
//			var preset2:String = '{"cakeBaseColor":-1,"deco":{"decoElements":[{"type":"Kiwi","transformMatrix":{"ty":251,"a":-0.6886749267578125,"b":-0.722808837890625,"c":0.722808837890625,"d":-0.6886749267578125,"tx":246}},{"type":"Kiwi","transformMatrix":{"ty":192,"a":-0.948394775390625,"b":-0.3140106201171875,"c":0.3140106201171875,"d":-0.948394775390625,"tx":254}},{"type":"Kiwi","transformMatrix":{"ty":132,"a":-0.955108642578125,"b":0.29315185546875,"c":-0.29315185546875,"d":-0.955108642578125,"tx":253}},{"type":"Kiwi","transformMatrix":{"ty":68,"a":-0.691619873046875,"b":0.7199859619140625,"c":-0.7199859619140625,"d":-0.691619873046875,"tx":249}},{"type":"Kiwi","transformMatrix":{"ty":60,"a":0.704254150390625,"b":0.7076263427734375,"c":-0.7076263427734375,"d":0.704254150390625,"tx":60}},{"type":"Kiwi","transformMatrix":{"ty":121,"a":0.9383087158203125,"b":0.3427276611328125,"c":-0.3427276611328125,"d":0.9383087158203125,"tx":52}},{"type":"Kiwi","transformMatrix":{"ty":175,"a":0.991546630859375,"b":-0.126495361328125,"c":0.126495361328125,"d":0.991546630859375,"tx":49}},{"type":"Kiwi","transformMatrix":{"ty":233,"a":0.8367919921875,"b":-0.5447845458984375,"c":0.5447845458984375,"d":0.8367919921875,"tx":49}},{"type":"Kiwi","transformMatrix":{"ty":254,"a":0.55938720703125,"b":-0.8270721435546875,"c":0.8270721435546875,"d":0.55938720703125,"tx":98}},{"type":"Kiwi","transformMatrix":{"ty":257,"a":-0.39520263671875,"b":-0.91729736328125,"c":0.91729736328125,"d":-0.39520263671875,"tx":201}},{"type":"Kiwi","transformMatrix":{"ty":259,"a":0.2037506103515625,"b":-0.9783477783203125,"c":0.9783477783203125,"d":0.2037506103515625,"tx":140}},{"type":"Kiwi","transformMatrix":{"ty":54,"a":-0.263671875,"b":0.9637451171875,"c":-0.9637451171875,"d":-0.263671875,"tx":190}},{"type":"Kiwi","transformMatrix":{"ty":54,"a":0.27569580078125,"b":0.9603424072265625,"c":-0.9603424072265625,"d":0.27569580078125,"tx":129}},{"type":"Raspberry","transformMatrix":{"ty":201,"a":0.863861083984375,"b":-0.50091552734375,"c":0.50091552734375,"d":0.863861083984375,"tx":94}},{"type":"Raspberry","transformMatrix":{"ty":147,"a":0.9715576171875,"b":0.233642578125,"c":-0.233642578125,"d":0.9715576171875,"tx":96}},{"type":"Raspberry","transformMatrix":{"ty":95,"a":0.6823272705078125,"b":0.7288055419921875,"c":-0.7288055419921875,"d":0.6823272705078125,"tx":97}},{"type":"Raspberry","transformMatrix":{"ty":206,"a":-0.7462005615234375,"b":-0.6632843017578125,"c":0.6632843017578125,"d":-0.7462005615234375,"tx":209}},{"type":"Raspberry","transformMatrix":{"ty":213,"a":0.11822509765625,"b":-0.9925994873046875,"c":0.9925994873046875,"d":0.11822509765625,"tx":154}},{"type":"Raspberry","transformMatrix":{"ty":159,"a":-0.9976043701171875,"b":0.0659637451171875,"c":-0.0659637451171875,"d":-0.9976043701171875,"tx":211}},{"type":"Raspberry","transformMatrix":{"ty":102,"a":-0.6361541748046875,"b":0.76947021484375,"c":-0.76947021484375,"d":-0.6361541748046875,"tx":210}},{"type":"Raspberry","transformMatrix":{"ty":92,"a":0.05712890625,"b":0.9981689453125,"c":-0.9981689453125,"d":0.05712890625,"tx":156}},{"type":"Cherry","transformMatrix":{"ty":178,"a":0.89337158203125,"b":-0.446380615234375,"c":0.446380615234375,"d":0.89337158203125,"tx":129}},{"type":"Cherry","transformMatrix":{"ty":179,"a":-0.6916961669921875,"b":-0.7199249267578125,"c":0.7199249267578125,"d":-0.6916961669921875,"tx":176}},{"type":"Cherry","transformMatrix":{"ty":128,"a":0.6024169921875,"b":0.79620361328125,"c":-0.79620361328125,"d":0.6024169921875,"tx":134}},{"type":"Cherry","transformMatrix":{"ty":133,"a":-0.518798828125,"b":0.8531951904296875,"c":-0.8531951904296875,"d":-0.518798828125,"tx":178}},{"type":"Raspberry","transformMatrix":{"ty":156,"a":0.68841552734375,"b":0.723052978515625,"c":-0.723052978515625,"d":0.68841552734375,"tx":154}},{"type":"Strawberry","transformMatrix":{"ty":265,"a":-0.6921539306640625,"b":-0.719482421875,"c":0.719482421875,"d":-0.6921539306640625,"tx":259}},{"type":"Strawberry","transformMatrix":{"ty":53,"a":-0.67279052734375,"b":0.7376251220703125,"c":-0.7376251220703125,"d":-0.67279052734375,"tx":260}},{"type":"Strawberry","transformMatrix":{"ty":265,"a":0.7635498046875,"b":-0.6432342529296875,"c":0.6432342529296875,"d":0.7635498046875,"tx":39}},{"type":"Strawberry","transformMatrix":{"ty":46,"a":0.7103271484375,"b":0.7015380859375,"c":-0.7015380859375,"d":0.7103271484375,"tx":42}}]},"scaleFactor":0.7,"writing":null,"cakeBaseShape":"rectangular","image":null}';
//			var preset3:String = '{"cakeBaseColor":3342336,"deco":{"decoElements":[{"type":"Raspberry","transformMatrix":{"ty":264,"a":0.350433349609375,"b":-0.9354400634765625,"c":0.9354400634765625,"d":0.350433349609375,"tx":121}},{"type":"Raspberry","transformMatrix":{"ty":266,"a":0.07440185546875,"b":-0.996978759765625,"c":0.996978759765625,"d":0.07440185546875,"tx":152}},{"type":"Raspberry","transformMatrix":{"ty":260,"a":-0.2506866455078125,"b":-0.9672393798828125,"c":0.9672393798828125,"d":-0.2506866455078125,"tx":186}},{"type":"Raspberry","transformMatrix":{"ty":246,"a":-0.55645751953125,"b":-0.82904052734375,"c":0.82904052734375,"d":-0.55645751953125,"tx":218}},{"type":"Raspberry","transformMatrix":{"ty":224,"a":-0.7986907958984375,"b":-0.59912109375,"c":0.59912109375,"d":-0.7986907958984375,"tx":245}},{"type":"Raspberry","transformMatrix":{"ty":195,"a":-0.9458465576171875,"b":-0.3215179443359375,"c":0.3215179443359375,"d":-0.9458465576171875,"tx":263}},{"type":"Raspberry","transformMatrix":{"ty":160,"a":-1,"b":0,"c":0,"d":-1,"tx":270}},{"type":"Raspberry","transformMatrix":{"ty":129,"a":-0.9566192626953125,"b":0.2881927490234375,"c":-0.2881927490234375,"d":-0.9566192626953125,"tx":263}},{"type":"Raspberry","transformMatrix":{"ty":96,"a":-0.8042755126953125,"b":0.5916290283203125,"c":-0.5916290283203125,"d":-0.8042755126953125,"tx":247}},{"type":"Raspberry","transformMatrix":{"ty":72,"a":-0.5810546875,"b":0.81195068359375,"c":-0.81195068359375,"d":-0.5810546875,"tx":223}},{"type":"Raspberry","transformMatrix":{"ty":53,"a":-0.284637451171875,"b":0.95770263671875,"c":-0.95770263671875,"d":-0.284637451171875,"tx":192}},{"type":"Raspberry","transformMatrix":{"ty":48,"a":0.0087738037109375,"b":0.9999237060546875,"c":-0.9999237060546875,"d":0.0087738037109375,"tx":159}},{"type":"Raspberry","transformMatrix":{"ty":51,"a":0.32647705078125,"b":0.9441375732421875,"c":-0.9441375732421875,"d":0.32647705078125,"tx":122}},{"type":"Raspberry","transformMatrix":{"ty":68,"a":0.60931396484375,"b":0.7909393310546875,"c":-0.7909393310546875,"d":0.60931396484375,"tx":89}},{"type":"Raspberry","transformMatrix":{"ty":92,"a":0.8241729736328125,"b":0.5636444091796875,"c":-0.5636444091796875,"d":0.8241729736328125,"tx":61}},{"type":"Raspberry","transformMatrix":{"ty":125,"a":0.95526123046875,"b":0.2926483154296875,"c":-0.2926483154296875,"d":0.95526123046875,"tx":46}},{"type":"Raspberry","transformMatrix":{"ty":160,"a":1,"b":0,"c":0,"d":1,"tx":42}},{"type":"Raspberry","transformMatrix":{"ty":195,"a":0.955078125,"b":-0.293243408203125,"c":0.293243408203125,"d":0.955078125,"tx":47}},{"type":"Raspberry","transformMatrix":{"ty":228,"a":0.8171844482421875,"b":-0.5736846923828125,"c":0.5736846923828125,"d":0.8171844482421875,"tx":63}},{"type":"Raspberry","transformMatrix":{"ty":251,"a":0.61944580078125,"b":-0.7830047607421875,"c":0.7830047607421875,"d":0.61944580078125,"tx":88}},{"type":"Kiwi","transformMatrix":{"ty":207,"a":0.2464599609375,"b":-0.9683380126953125,"c":0.9683380126953125,"d":0.2464599609375,"tx":148}},{"type":"Kiwi","transformMatrix":{"ty":185,"a":-0.8197021484375,"b":-0.570098876953125,"c":0.570098876953125,"d":-0.8197021484375,"tx":196}},{"type":"Kiwi","transformMatrix":{"ty":130,"a":-0.7665863037109375,"b":0.639617919921875,"c":-0.639617919921875,"d":-0.7665863037109375,"tx":196}},{"type":"Kiwi","transformMatrix":{"ty":107,"a":0.2003326416015625,"b":0.97906494140625,"c":-0.97906494140625,"d":0.2003326416015625,"tx":149}},{"type":"Kiwi","transformMatrix":{"ty":136,"a":0.9102020263671875,"b":0.411163330078125,"c":-0.411163330078125,"d":0.9102020263671875,"tx":107}},{"type":"Kiwi","transformMatrix":{"ty":176,"a":0.9578704833984375,"b":-0.284027099609375,"c":0.284027099609375,"d":0.9578704833984375,"tx":106}},{"type":"Cherry","transformMatrix":{"ty":159,"a":0.9863128662109375,"b":0.161651611328125,"c":-0.161651611328125,"d":0.9863128662109375,"tx":154}}]},"scaleFactor":0.4,"writing":null,"cakeBaseShape":"round","image":null}';
//			var preset4:String = '{"cakeBaseColor":6723840,"deco":{"decoElements":[{"transformMatrix":{"ty":228,"a":-0.1999359130859375,"b":-0.9791412353515625,"c":0.9791412353515625,"d":-0.1999359130859375,"tx":174},"type":"Peach"},{"transformMatrix":{"ty":201,"a":-0.77203369140625,"b":-0.6330413818359375,"c":0.6330413818359375,"d":-0.77203369140625,"tx":210},"type":"Peach"},{"transformMatrix":{"ty":156,"a":-0.9981842041015625,"b":0.0569915771484375,"c":-0.0569915771484375,"d":-0.9981842041015625,"tx":229},"type":"Peach"},{"transformMatrix":{"ty":103,"a":-0.650054931640625,"b":0.75775146484375,"c":-0.75775146484375,"d":-0.650054931640625,"tx":209},"type":"Peach"},{"transformMatrix":{"ty":77,"a":-0.0958709716796875,"b":0.9950714111328125,"c":-0.9950714111328125,"d":-0.0958709716796875,"tx":168},"type":"Peach"},{"transformMatrix":{"ty":90,"a":0.5121002197265625,"b":0.8572540283203125,"c":-0.8572540283203125,"d":0.5121002197265625,"tx":118},"type":"Peach"},{"transformMatrix":{"ty":132,"a":0.9457244873046875,"b":0.321868896484375,"c":-0.321868896484375,"d":0.9457244873046875,"tx":78},"type":"Peach"},{"transformMatrix":{"ty":188,"a":0.9415130615234375,"b":-0.3338775634765625,"c":0.3338775634765625,"d":0.9415130615234375,"tx":81},"type":"Peach"},{"transformMatrix":{"ty":228,"a":0.52325439453125,"b":-0.8504638671875,"c":0.8504638671875,"d":0.52325439453125,"tx":118},"type":"Peach"},{"transformMatrix":{"ty":155,"a":0.7665863037109375,"b":0.639617919921875,"c":-0.639617919921875,"d":0.7665863037109375,"tx":154},"type":"Cherry"},{"transformMatrix":{"ty":253,"a":0.20849609375,"b":-0.9773406982421875,"c":0.9773406982421875,"d":0.20849609375,"tx":140},"type":"Cherry"},{"transformMatrix":{"ty":191,"a":-0.941375732421875,"b":-0.3342742919921875,"c":0.3342742919921875,"d":-0.941375732421875,"tx":247},"type":"Cherry"},{"transformMatrix":{"ty":58,"a":-0.438812255859375,"b":0.8971405029296875,"c":-0.8971405029296875,"d":-0.438812255859375,"tx":210},"type":"Cherry"},{"transformMatrix":{"ty":89,"a":0.7803497314453125,"b":0.6227874755859375,"c":-0.6227874755859375,"d":0.7803497314453125,"tx":71},"type":"Cherry"},{"transformMatrix":{"ty":240,"a":-0.4733428955078125,"b":-0.8793182373046875,"c":0.8793182373046875,"d":-0.4733428955078125,"tx":203},"type":"Cherry"},{"transformMatrix":{"ty":119,"a":-0.8973236083984375,"b":0.4384307861328125,"c":-0.4384307861328125,"d":-0.8973236083984375,"tx":244},"type":"Cherry"},{"transformMatrix":{"ty":53,"a":0.1739501953125,"b":0.9841766357421875,"c":-0.9841766357421875,"d":0.1739501953125,"tx":141},"type":"Cherry"},{"transformMatrix":{"ty":157,"a":0.9995574951171875,"b":0.026641845703125,"c":-0.026641845703125,"d":0.9995574951171875,"tx":53},"type":"Cherry"},{"transformMatrix":{"ty":218,"a":0.814697265625,"b":-0.5772247314453125,"c":0.5772247314453125,"d":0.814697265625,"tx":78},"type":"Cherry"}]},"scaleFactor":0.8,"writing":null,"cakeBaseShape":"round","image":null}';
//			var preset5:String = '{"cakeBaseColor":-1,"deco":{"decoElements":[{"transformMatrix":{"ty":271,"a":-0.0183563232421875,"b":-0.9997711181640625,"c":0.9997711181640625,"d":-0.0183563232421875,"tx":155},"type":"Raspberry"},{"transformMatrix":{"ty":247,"a":-0.60614013671875,"b":-0.793365478515625,"c":0.793365478515625,"d":-0.60614013671875,"tx":225},"type":"Raspberry"},{"transformMatrix":{"ty":95,"a":-0.8850860595703125,"b":0.4625396728515625,"c":-0.4625396728515625,"d":-0.8850860595703125,"tx":262},"type":"Raspberry"},{"transformMatrix":{"ty":188,"a":0.95654296875,"b":-0.2884521484375,"c":0.2884521484375,"d":0.95654296875,"tx":35},"type":"Raspberry"},{"transformMatrix":{"ty":116,"a":0.952484130859375,"b":0.30145263671875,"c":-0.30145263671875,"d":0.952484130859375,"tx":38},"type":"Raspberry"},{"transformMatrix":{"ty":215,"a":-0.8339385986328125,"b":-0.54913330078125,"c":0.54913330078125,"d":-0.8339385986328125,"tx":247},"type":"Grape"},{"transformMatrix":{"ty":137,"a":-0.990325927734375,"b":0.13555908203125,"c":-0.13555908203125,"d":-0.990325927734375,"tx":264},"type":"Grape"},{"transformMatrix":{"ty":263,"a":-0.3132781982421875,"b":-0.9486236572265625,"c":0.9486236572265625,"d":-0.3132781982421875,"tx":189},"type":"Grape"},{"transformMatrix":{"ty":262,"a":0.29241943359375,"b":-0.955322265625,"c":0.955322265625,"d":0.29241943359375,"tx":119},"type":"Grape"},{"transformMatrix":{"ty":213,"a":0.8461151123046875,"b":-0.5302276611328125,"c":0.5302276611328125,"d":0.8461151123046875,"tx":56},"type":"Grape"},{"transformMatrix":{"ty":152,"a":0.999969482421875,"b":0.0043792724609375,"c":-0.0043792724609375,"d":0.999969482421875,"tx":39},"type":"Grape"},{"transformMatrix":{"ty":247,"a":0.6229400634765625,"b":-0.7802276611328125,"c":0.7802276611328125,"d":0.6229400634765625,"tx":77},"type":"Raspberry"},{"transformMatrix":{"ty":78,"a":0.760650634765625,"b":0.64666748046875,"c":-0.64666748046875,"d":0.760650634765625,"tx":65},"type":"Grape"},{"transformMatrix":{"ty":178,"a":-0.9764404296875,"b":-0.21258544921875,"c":0.21258544921875,"d":-0.9764404296875,"tx":269},"type":"Raspberry"}]},"scaleFactor":0.7,"writing":null,"cakeBaseShape":"round","image":{"transformMatrix":{"ty":16,"a":0.60443115234375,"b":0,"c":0,"d":0.60443115234375,"tx":16},"imageURL":"images/2.jpg","imageSource":"network"}}';
//			var presets:Array = [preset1, preset2, preset3, preset4, preset5];
//			if(isNaN(presetCounter) || presetCounter == presets.length) presetCounter = 0;
//			loadCakePreset(presets[presetCounter]);
//			presetCounter++;
// Конец кода для локальной демо-версии
		}
		
		// При выборе файла
		private function onFileSelect(evt:Event){
			if(fr.size / 1048576 > CakeData.IMAGE_SIZE_LIMIT){
				var msg:String = "Объем выбранного файла превышает " + CakeData.IMAGE_SIZE_LIMIT + "Мб!"
				trace(msg);
				ExternalInterface.call("openMessageBox", msg);
			}
			else{
				fr.load();
			}
		}
		
		public function loadExternalImage(url:String){
			imageSource = CakeImageData.NETWORK_IMAGE_SOURCE;
			removeImage();
			imageURL = url;
			loader.load(new URLRequest(url));
			
		}
		
		private function removeImage(){
			loader.unload();
			
			imageURL = null;
			if(loadingIndicator != null){
				if(loadingIndicator.alpha > 0){
					TweenLite.to(loadingIndicator, 1, {alpha:0});
				}
			}
			if(imageIsOn){
				while(topImageContainer.numChildren > 0){
					topImageContainer.removeChildAt(0);
				}
				imageTransformationMatrix = new Matrix();
				topImageContainer.transform.matrix = imageTransformationMatrix;
				removeTransformTool();
				setTransformTool();
				//Очищаем свойство с копией исходного (полноразмерного) изображения 
				sourceBitmapData.dispose();
				sourceBitmapData = null;
				imageIsOn = false;
			}
			disableDashedBtn(removeImageBtn);
			//enableDashedBtn(openPresetsBtn);
			enableDashedBtn(openGalleryBtn);
		}

		
		// При открытии файла
		private function onFileOpen(evt:Event){
			removeImage();
			loader.loadBytes(fr.data);
			imageSource = CakeImageData.USER_IMAGE_SOURCE;
		}
		
		private function onFileLoadStart(evt:Event){
			if(loadingIndicator != null){
				removeChild(loadingIndicator);
				loadingIndicator = null;
			}
			loadingIndicator = new LoadingIndicator();
			addChild(loadingIndicator);
			loadingIndicator.alpha = 0;
			TweenLite.to(loadingIndicator, 1, {alpha:1});
			// Включаем кнопку удаления изображения, чтобы изображение можно было удалить, не дожилаясь окончания его загрузки
			enableDashedBtn(removeImageBtn);
			//disableDashedBtn(openPresetsBtn);
			disableDashedBtn(openGalleryBtn);
		}
		
		private function onFileLoadProgress(evt:ProgressEvent){
			// Используем contentLoaderInfo.bytesTotal а не evt.bytesTotal, т.к. последнее показывает суммарный объем, загруженный в Loader
			if(loader.contentLoaderInfo.bytesTotal != 0 && loadingIndicator != null){
				loadingIndicator.updateState(loader.contentLoaderInfo.bytesLoaded/loader.contentLoaderInfo.bytesTotal);
			}
		}
		
		// По окончании загрузки файла
		private function onFileLoadComplete(evt:Event){
			// Делаем прозрачным индикатор загрузки. Он будет удален при запуске следующей загрузки из обработчика onFileLoadStart
			if(loadingIndicator != null){// При открытии файла из файловой системы индикатора не будет, т.к. onFileLoadStart не вызывается
				TweenLite.to(loadingIndicator, 1, {alpha:0});
			}
			var msg:String = "";
			if(evt.currentTarget.content.width > CakeData.IMAGE_DIMENSIONS_LIMIT && evt.currentTarget.content.height > CakeData.IMAGE_DIMENSIONS_LIMIT){
				msg = "Выбранное изображение имеет недопустимые размеры: " + evt.currentTarget.content.width + "x" + evt.currentTarget.content.height + "px. Сторона не может быть больше " + CakeData.IMAGE_DIMENSIONS_LIMIT +"px";
			}
			else if(evt.currentTarget.content.width > CakeData.IMAGE_DIMENSIONS_LIMIT){
				msg = "Ширина выбранного изображения превышает 1200px";
			} 
			else if(evt.currentTarget.content.height > CakeData.IMAGE_DIMENSIONS_LIMIT){
				msg = "Высота выбранного изображения превышает 1200px";
			}
			else{
				sourceBitmapData = evt.currentTarget.content.bitmapData.clone();
				topImageContainer.x = cakeBase.color_mc.x;
				topImageContainer.y = cakeBase.color_mc.y;
				topImageContainer.addChild(evt.currentTarget.content);
				evt.currentTarget.content.smoothing = true;
				removeTransformTool();
				setTransformTool();
				imageIsOn = true;
				trace("complete: " + imageTransformationMatrix);
				//enableDashedBtn(removeImageBtn);
				// Если изображение загружено в пресете, трансформируем его с помощью заданной в пресете матрицы
				// только в этом случае imageTransformationMatrix хранит матрицу, отличную от единичной
				// Изображения из пресета не требуют подгонки размеров
				if(imageSource == CakeImageData.NETWORK_IMAGE_SOURCE && imageTransformationMatrix.toString() != "(a=1, b=0, c=0, d=1, tx=0, ty=0)"){
					topImageContainer.transform.matrix = imageTransformationMatrix;
				}
				// Если изображение загружено из компьютера пользователя или из сети (стандартной галереи), оно подгоняется под размер
				else{
					DisplayObjectTools.changeSizeToFit(topImageContainer, cakeBase.color_mc.width, cakeBase.color_mc.height);
				}
				// Добавлено для исправления бага: иногда центр трансформации картинки находится не в центре а в левом верхнем углу.
				// Нужно проверить, помогло ли это!
				if(transformToolIsOn){
					transformTool.registrationManager.defaultUV = new Point(.5, .5);
				}
				enableDashedBtn(removeImageBtn);
				//enableDashedBtn(openPresetsBtn);
				enableDashedBtn(openGalleryBtn);
				trace("added:  " + CakeData.IMAGE);
				ExternalInterface.call("onElementAdded", CakeData.IMAGE);
			}
			// Если размеры картинки превышают допустимые, удаляем ее
			if (msg != ""){
				removeImage();
				trace(msg);
				ExternalInterface.call("openMessageBox", msg);
			}
		}
		
		private function onIoError(evt:IOErrorEvent){
			trace(evt.text);
			ExternalInterface.call("onError", evt.text);
		}
		
		private function onRemoveColorBtnClick(evt:MouseEvent){
			clearCakeBaseColor();
			trace("removed:  " + CakeData.COLOR);
			ExternalInterface.call("onElementRemoved", CakeData.COLOR);
		}
		
		private function onRemoveImageBtnClick(evt:MouseEvent){
			removeImage();
			trace("removed:  " + CakeData.IMAGE);
			ExternalInterface.call("onElementRemoved", CakeData.IMAGE);
		}
		
		// При любых изменениях текста надписи или параметров ее форматирования, а также при ее удалении
		private function onTextChange(evt:CakeEvent){
			var txtSprite:Sprite = DisplayObjectTools.duplicateAsBitmap(textControls.getTextSprite());
			// Отображаем изменения только, если размеры надписи не превышают размеров основы (с тарелкой)
			//if(txtSprite.width < cakeBase.width && txtSprite.height < cakeBase.height){
				if(topTextContainer.numChildren > 0){
					topTextContainer.removeChildAt(0);
				}
				topTextContainer.addChildAt(txtSprite, 0);
				// Центрируем текстовое поле внутри контейнера по вертикали при вводе текста,
				// поскольку высота определяется текущим выбранным кеглем
				//topTextContainer.getChildAt(0).y = - .5 * topTextContainer.height;
				if(transformToolIsOn){
					removeTransformTool();
					setTransformTool();
				}
			//}
			// При вводе первого символа
			if(!textIsOn){
				trace("added:  " + CakeData.WRITING);
				ExternalInterface.call("onElementAdded", CakeData.WRITING);
			}
			// Проверяем, иммется ли надпись на основе того, есть ли в поле текст.
			// Пользователь может удалить текст в том числе и не нажимая на кнопку очистки (e.g. с помощью <backspace>)
			textIsOn = (topTextContainer.numChildren > 0 && textControls.getText() != "" && textControls.getText() != null);
			enableDashedBtn(textControls.removeBtn);
			// Если textIsOn==false - значит поле не содержит символов, считаем, что надписи нет
			if(!textIsOn){
				if(transformToolIsOn && transformTool.target == topTextContainer){
					transformTool.target = null;
				}
				topTextContainer.transform.matrix = new Matrix();
				topTextContainer.x = cakeBase.color_mc.x + .5 * cakeBase.color_mc.width;
				topTextContainer.y = cakeBase.color_mc.y + .5 * cakeBase.color_mc.height;
				disableDashedBtn(textControls.removeBtn);
				trace("removed from text area:  " + CakeData.WRITING);
				ExternalInterface.call("onElementRemoved", CakeData.WRITING);
			}
		}
		
		private function onClearTopDecoBtnClick(evt:MouseEvent){
			// Определяем, к какому селектору относится кнопка
			var selector:ChoserContainer;
			for(var sel:uint = 0; sel < decoSelectorsNum; sel++){
				if(evt.currentTarget ==  topDecoChoserContainers[sel].clearButton){
					selector = topDecoChoserContainers[sel];
					break;
				}
			}
			// Для каждого элемента, относящегося к этому селектору, который находится на торте
			for(var el:uint = 0; el < selector.elementsInUse.length; el++){
				// Удаляем ссылку на него из curDecoElements
				for(var i:uint = 0; i < curDecoElements.length; i++){
					if(selector.elementsInUse[el] == curDecoElements[i]){
						curDecoElements.splice(i, 1);
						break;
					}
				}
				var decoEl:DecoElement;
				// Удаляем его из спрайта topDecoContainer
				for(var d:uint = 0; d < topDecoContainer.numChildren; d++){
					decoEl = topDecoContainer.getChildAt(d) as DecoElement;
					if(decoEl != null){
						if(selector.elementsInUse[el] == decoEl){
							DragAndDrop.terminate(decoEl);
							topDecoContainer.removeChild(decoEl);
							break;
						}
					}
				}
			}
			selector.elementsInUse = [];
			disableDashedBtn(selector.clearButton);
			
			trace("removed:  " + CakeData.DECO);
			ExternalInterface.call("onElementRemoved", CakeData.DECO);	
		}
		
		private function onSaveBtnClick(evt:MouseEvent){
// Код для локальной демо-версии
//			fileSaver.save(getCakeSnapshotBytes(), "Новый торт.jpg");
// Конец кода для локальной демо-версии			
			getCakeData();
		}
		
		// Возвращает ByteArray со снимком текущего изображения торта
		private function getCakeSnapshotBytes():ByteArray{
			var b:Bitmap = new Bitmap();
			var fullImage:Sprite = new Sprite();
			fullImage.x = cakeBase.x;
			fullImage.y = cakeBase.y;
			// Временно добавляем клип с тортом во временный спрайт, который будет растрирован (туда же будет добавлено изображение боковинки)
			fullImage.addChild(cakeBase);
			// Убираем инструмент трансформации, чтобы на рисунке не осталась рамка трансформации
			removeTransformTool();
			// Поля для того, чтобы избежать обрезки краев картинки
			var offset:Number = 6;
			var bd:BitmapData = new BitmapData(initCakeBaseWidth + offset * 2, initCakeBaseWidth + offset * 2, false, 0xffffff);
			var m:Matrix = new Matrix();
			m.translate(-cakeBase.x + offset, -cakeBase.y + offset / 3);
			bd.draw(fullImage, m);
			var JPEGEncoder:JPGEncoder = new JPGEncoder(100);
			var JPEGBytes:ByteArray = JPEGEncoder.encode(bd);
			// Возвращаем клип с тортом обратно в его контейнер
			addChild(cakeBase);
			// Восстанавливаем объект инструмента трансформации
			setTransformTool();
			return JPEGBytes;
		}
		
		// Данные о растре нужны только при сохранении. При изменении состояния достаточно только JSON состояния
		public function getCakeData():Array{
			var cd:Object = {};
			cd.dimensions = {};
			cd.content = {};
			
			cd.dimensions.mass = currentWeight;
			cd.dimensions.persons_count = currentPersonsCount;
			cd.dimensions.ratio = scaleFactor;
			cd.dimensions.shape = currentShape;
			
			cd.content.base_color = currentColor;

			
			var csb:ByteArray = getCakeSnapshotBytes();
			var cakeSnapshotBase64:String;
			cakeSnapshotBase64 = Base64.encode(csb);
			var originalImageBase64:String;
			
			if(imageIsOn){
				cd.content.photo = {};
				cd.content.photo.image_source = imageSource;
				cd.content.photo.transform = matrixToArray(topImageContainer.transform.matrix);
				// Картинка была загружена пользователем
				if(imageSource == CakeImageData.USER_IMAGE_SOURCE){
					//var bytes:ByteArray = sourceBitmapData.getPixels(sourceBitmapData.rect);
					var JPEGEncoder:JPGEncoder = new JPGEncoder(100);
					var JPEGBytes:ByteArray = JPEGEncoder.encode(sourceBitmapData);
					//originalImageBase64 = Base64.encode(bytes);
					originalImageBase64 = Base64.encode(JPEGBytes);
					//
//					var l:Loader = new Loader();
//					l.loadBytes(JPEGBytes);
//					addChild(l);
//					trace("ok");
//					var b:Bitmap = new Bitmap(sourceBitmapData);
//					addChild(b);
//					trace(sourceBitmapData.rect);
					//
				}
				// Картинка была загружена из сети
				else if(imageSource == CakeImageData.NETWORK_IMAGE_SOURCE){
					cd.content.photo.photo_url = imageURL;
				}
			}
			
			if(textIsOn){
				cd.content.text = {};				
				cd.content.text.value = textControls.getText();
				cd.content.text.font = textControls.getFont();
				cd.content.text.size = textControls.getSize();
				cd.content.text.color = textControls.getColor();
				cd.content.text.transform = matrixToArray(topTextContainer.transform.matrix);
			}
			
			if(curDecoElements.length > 0){
				cd.content.deco = [];
				for (var k:uint = 0; k < curDecoElements.length; k++){
					var del:Object = {};
					var el:DecoElement = topDecoContainer.getChildAt(k) as DecoElement;
					del.name = el.getType();
					del.transform = matrixToArray(el.transform.matrix);
					cd.content.deco.push(del);
				}
			}
			var cdJSON:String = JSON.encode(cd);
			//trace(cdJSON);
			//ExternalInterface.call("saveCakeData", cdJSON, cakeSnapshotBase64, originalImageBase64);
			return [cdJSON, cakeSnapshotBase64, originalImageBase64];
		}
	}
}