package cakeConstructor{

	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import fl.controls.ComboBox;
	import fl.controls.TextArea;
	import fl.controls.ColorPicker;
	import fl.data.DataProvider;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import fl.events.ColorPickerEvent;
	import fl.events.ListEvent;
	import cakeConstructor.events.CakeEvent;
	import flash.display.InteractiveObject;
	
	/**
	  * Класс для создания надписи с элементами управления, позволяющими устанавливать текст, шрифт, кегль и цвет
	  */
	public class TextControls extends Sprite {
		
		// Экземпляры управляющих компонентов
		public var fontNameCB:ComboBox;
		public var fontSizeCB:ComboBox;
		public var colorPicker:ColorPicker;
		public var textTA:TextArea;
		public var removeBtn:SimpleButton;
		// Массив с объектами Font шрифтов, установленных у пользователя
		private var _fontsList:Array;
		// Массив с названиями шрифтов пользователя
		private var _fontsNameList:Array;
		// Минимальный/максимальный кегль
		private var _minFontSize:uint = 8;
		private var _maxFontSize:uint = 92;
		// Контейнер с надписью для вывода
		private var _displaySprite:Sprite;
		// Текстовое поле вывода в контейнере
		private var _txtField:TextField;
		// Формат текстового поля вывода
		private var _txtFormat:TextFormat;
		// Текст в поле ввода по умолчанию
		private var _messageText:String = "Введите сюда текст надписи на торте.";
		// Шрифт и кегль текста вывода по умолчанию
		private var _defaultFont:String = "Arial";
		private var _defaultFontSize:uint = 20;
		// Индексы шрифта и размера в раскрывающихся списках
		private var _defaultFontIndex:uint;
		private var _defaultFontSizeIndex:uint;
		// Цвет текста вывода
		private var _defaultTextColor:uint = 0x000000;
		// Формат надписи по умолчанию в поле ввода
		private var _messageFormat:TextFormat = new TextFormat("Arial",12,0xaaaaaa,null,true);
		// Формат вводимого текста в поле ввода
		private var _inputTextFormat:TextFormat = new TextFormat("Arial",12,0x000000,null,false);
		// Текущий текст вывода
		private var _currentText:String;
		// Текущие параметры шрифта текста вывода
		private var _font:String = _defaultFont;
		private var _color:uint = _defaultTextColor;
		private var _size:uint = _defaultFontSize;

		public function TextControls() {
			populateFontsList();
			initFontNameCB();
			initFontSizeCB();
			initRemoveBtn();
			initColorPicker();
			setTextDisplayContainer();		
			initTextTA();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		// Возвращает ссылку на спрайт с текстом
		public function getTextSprite():Sprite{
			return _displaySprite;
		}
		// Создает контейнер для текста вывода
		private function setTextDisplayContainer(){
			_displaySprite = new Sprite();
			_txtField = new TextField();
			_txtField.width = 0;
			_txtField.height = 0;
			_txtField.selectable = false;
			_txtField.autoSize = TextFieldAutoSize.CENTER;
			_displaySprite.addChild(_txtField);
			_txtFormat = new TextFormat(_defaultFont, _defaultFontSize, _defaultTextColor);
			_txtFormat.align = TextFormatAlign.CENTER;
			_txtField.defaultTextFormat = _txtFormat;
		}
		
		// Устанавливает текущий текст и параметры форматирования надписи
		private function updateTextDisplayContainer(){
			_txtField.text = _currentText == null ? "" : _currentText;
			_txtField.setTextFormat(new TextFormat(_font, _size, _color));
//			var evt:CakeEvent = new CakeEvent(CakeEvent.TEXT_CHANGE_EVENT);
//			evt.textContainer = getTextSprite();
//			dispatchEvent(evt);
		}
		
		// Создает надпись с заданными атрибутами и устанавливает элементы UI в текущее состояние
		public function setText(text:String, font:String, size:uint, color:uint){
			_currentText = text;
			// Если у пользователя нет указанного шрифта, проверяем есть ли у него Arial, затем Times New Roman
			// Если ни одного из перечисленных шрифтов не установлено, используем первый шрифт в отсортированном по алфавиту списке доступных шрифтов
			var fontAvailable:Boolean;
			var sans:Boolean;
			var serif:Boolean;
			var sansFont:String = "Arial";
			var serifFont:String = "Times New Roman";
			for (var i:uint = 0; i < _fontsNameList.length; i++) {
				if(_fontsNameList[i] == font){
					fontAvailable = true;
					_font = font;
					break;
				}
				else if(_fontsNameList[i] == sansFont){
					sans = true;
				}
				else if(_fontsNameList[i] == serifFont){
					serif = true;
				}
			}
			if(!fontAvailable){
				if(sans){
					_font = sansFont;
				}
				else if (serif){
					_font = serifFont;
				}
				else _font = _fontsNameList[0];
			}
			_size = size;
			_color = color;
			textTA.text = text;
			textTA.setStyle("textFormat", _inputTextFormat);
			setSelectedItemByLabel(fontNameCB, _font);
			setSelectedItemByLabel(fontSizeCB, _size.toString());
			colorPicker.selectedColor = _color;
			updateTextDisplayContainer();
			var evt:CakeEvent = new CakeEvent(CakeEvent.TEXT_CHANGE_EVENT);
			evt.textContainer = getTextSprite();
			dispatchEvent(evt);
		}
		
		// Устанавливает выделение на элемент списка с заданной меткой
		private function setSelectedItemByLabel(cb:ComboBox, label:String){
			var index:uint;
			for(var i:uint; i < cb.length; i++){
				if(cb.getItemAt(i).label == label){
					index = i
					break;
				}
			}
			cb.selectedIndex = index;
		}
		
		// Формирует список шрифтов, установленных у пользователя
		private function populateFontsList():Array {
			_fontsList = Font.enumerateFonts(true);
			_fontsList.sortOn("fontName", Array.CASEINSENSITIVE);
			_fontsNameList = new Array();
			for (var i:uint = 0; i < _fontsList.length; i++) {
				_fontsNameList.push(_fontsList[i].fontName);
				if (_fontsList[i].fontName == _defaultFont) {
					_defaultFontIndex = i;
				}
			}
			return _fontsList;
		}

		private function initFontNameCB() {
			fontNameCB.editable = false;
			fontNameCB.dataProvider = new DataProvider(_fontsNameList);
			fontNameCB.selectedItem = fontNameCB.getItemAt(_defaultFontIndex);
			fontNameCB.addEventListener(Event.CHANGE, onFontNameCBChange);
			fontNameCB.addEventListener(ListEvent.ITEM_ROLL_OVER, onFontNameCBOver);
			fontNameCB.addEventListener(Event.CLOSE, onFontNameCBChange);
		}

		private function initFontSizeCB() {
			fontNameCB.editable = false;
			var sizes:Array = new Array();
			for (var i:uint = _minFontSize; i <= _maxFontSize; i += 2) {
				sizes.push(i);
				if (i == _defaultFontSize) {
					_defaultFontSizeIndex = (_defaultFontSize - _minFontSize)/2;
				}
			}
			fontSizeCB.dataProvider = new DataProvider(sizes);
			fontSizeCB.selectedItem = fontSizeCB.getItemAt(_defaultFontSizeIndex);
			fontSizeCB.addEventListener(Event.CHANGE, onFontSizeCBChange);
			fontSizeCB.addEventListener(ListEvent.ITEM_ROLL_OVER, onFontSizeCBOver);
			fontSizeCB.addEventListener(Event.CLOSE, onFontSizeCBChange);
		}

		private function initRemoveBtn() {
			removeBtn.addEventListener(MouseEvent.CLICK, onRemoveBtnClick);
		}

		private function initTextTA() {
			textTA.addEventListener(Event.CHANGE, onTextChange);
			textTA.addEventListener(MouseEvent.MOUSE_DOWN, onTextDown);
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, onTextTAClickOut);
			setDefaultText();
		}
		
		private function onAddedToStage(evt:Event){
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onTextTAClickOut);
		}
		
		private function initColorPicker() {
			colorPicker.selectedColor = _defaultTextColor;
			colorPicker.addEventListener(ColorPickerEvent.ENTER, onColorSet);
			colorPicker.addEventListener(ColorPickerEvent.ITEM_ROLL_OVER, onColorSet);
		}

		private function setDefaultText() {
			if(textTA.text != _messageText){
				textTA.text = _messageText;
				textTA.setStyle("textFormat", _messageFormat);
			}
		}
		
		public function removeText(){
			_currentText = "";
			setDefaultText();
			updateTextDisplayContainer();
		}
		
		private function onRemoveBtnClick(e:MouseEvent) {
			removeText();
			var evt:CakeEvent = new CakeEvent(CakeEvent.TEXT_CHANGE_EVENT);
			evt.textContainer = getTextSprite();
			dispatchEvent(evt);
		}
		
		private function onTextChange(e:Event) {
			_currentText = e.currentTarget.text;
			updateTextDisplayContainer();
			var evt:CakeEvent = new CakeEvent(CakeEvent.TEXT_CHANGE_EVENT);
			evt.textContainer = getTextSprite();
			dispatchEvent(evt);
		}

		private function onTextDown(evt:MouseEvent) {
			if (_currentText == null || _currentText == "") {
				textTA.text = "";
				textTA.setStyle("textFormat", _inputTextFormat);
			}
		}

		private function onTextTAClickOut(evt:MouseEvent) {
			if(evt.target != textTA.textField){
				if (_currentText == null || _currentText == "") {
					setDefaultText();
				}
				// Убираем фокус с текстового поля, чтобы при работе с другими элементами текст ввести было нельзя
				textTA.focusManager.setFocus(null);
			}
		}

		private function onFontNameCBChange(e:Event) {
			_font = e.currentTarget.selectedLabel;
			// Обновляем вывод только если в поле ввода имеется набранный текст (если сначала установить параметры форматирования, а потом начать вводить текст, то вывод обновится при вводе текста)
			if (_currentText != null && _currentText != ""){
				updateTextDisplayContainer();
				//trace("font:  " + _font);
				var evt:CakeEvent = new CakeEvent(CakeEvent.TEXT_CHANGE_EVENT);
				evt.textContainer = getTextSprite();
				dispatchEvent(evt);
			}
		}
		
		private function onFontNameCBOver(e) {
			_font = e.currentTarget.getItemAt(e.rowIndex).label;
			if (_currentText != null && _currentText != ""){
				updateTextDisplayContainer();
				//trace("font:  " + _font);
				var evt:CakeEvent = new CakeEvent(CakeEvent.TEXT_CHANGE_EVENT);
				evt.textContainer = getTextSprite();
				dispatchEvent(evt);
			}
		}

		private function onFontSizeCBChange(e:Event) {
			_size = e.currentTarget.selectedLabel;
			if (_currentText != null && _currentText != ""){
				updateTextDisplayContainer();
				//trace("size:  " + _size);
				var evt:CakeEvent = new CakeEvent(CakeEvent.TEXT_CHANGE_EVENT);
				evt.textContainer = getTextSprite();
				dispatchEvent(evt);
			}
		}
		
		private function onFontSizeCBOver(e) {
			_size = e.currentTarget.getItemAt(e.rowIndex).label;
			if (_currentText != null && _currentText != ""){
				updateTextDisplayContainer();
				//trace("size:  " + _size);
				var evt:CakeEvent = new CakeEvent(CakeEvent.TEXT_CHANGE_EVENT);
				evt.textContainer = getTextSprite();
				dispatchEvent(evt);
			}
		}

		private function onColorSet(e:Event) {
			_color = e.currentTarget.selectedColor;
			if (_currentText != null && _currentText != ""){
				updateTextDisplayContainer();
				//trace("color:  " + _color);
				var evt:CakeEvent = new CakeEvent(CakeEvent.TEXT_CHANGE_EVENT);
				evt.textContainer = getTextSprite();
				dispatchEvent(evt);
			}
		}
		
		public function getText():String{
			return _currentText;
		}
		
		public function getFont():String{
			return _font;
		}
		
		public function getSize():uint{
			return _size;
		}
		
		public function getColor():uint{
			return _color;
		}
		
		public function killStageReferences(){
//			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
//			fontNameCB.removeEventListener(Event.CHANGE, onFontNameCBChange);
//			fontNameCB.removeEventListener(ListEvent.ITEM_ROLL_OVER, onFontNameCBOver);
//			fontNameCB.removeEventListener(Event.CLOSE, onFontNameCBChange);
//			fontSizeCB.removeEventListener(Event.CHANGE, onFontSizeCBChange);
//			fontSizeCB.removeEventListener(ListEvent.ITEM_ROLL_OVER, onFontSizeCBOver);
//			fontSizeCB.removeEventListener(Event.CLOSE, onFontSizeCBChange);
//			removeBtn.removeEventListener(MouseEvent.CLICK, onRemoveBtnClick);
//			textTA.removeEventListener(Event.CHANGE, onTextChange);
//			textTA.removeEventListener(MouseEvent.MOUSE_DOWN, onTextDown);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onTextTAClickOut);
//			colorPicker.removeEventListener(ColorPickerEvent.ENTER, onColorSet);
//			colorPicker.removeEventListener(ColorPickerEvent.ITEM_ROLL_OVER, onColorSet);
//			_displaySprite.removeChild(_txtField);
//			_txtField = null;
//			_displaySprite = null
		}
		
	}

}