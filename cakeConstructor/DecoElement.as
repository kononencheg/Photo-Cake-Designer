package cakeConstructor{
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.errors.*;
	import flash.events.Event;
	import flash.net.*;
	import flash.utils.getQualifiedClassName;
	import flash.system.LoaderContext;
	
	import infinitech.visual.DisplayObjectTools;
	
	// Класс представления элемента оформления, содержащего отмасштабированное изображение
	// Для изменения размеров следует масштабировать дочерний объект image, а не сам DecoElement
	internal class DecoElement extends MovieClip{
		
		// Клип с элементами
		private var _plate:MovieClip;
		private var _image:Sprite;
		
		private var _type:String;
		private var _url:String;
		private var _info:String;
		private var _autorotate:Boolean;
		private var _margin:uint = 5;
		
		private var _loader:Loader;
		private var _choserContainer:ChoserContainer;
		
		private var _imageloaded:Boolean = false;
		private var _indicator:DecoIndicator;
		
		public function DecoElement(type:String, info:String = "", url:String = null, imageSource:DecoElement = null, autorotate:Boolean = true){
			_type = type;
			_url = url;
			if(info == null || info == "undefined"){
				_info = "";
			}
			else{
				_info = info;
			}
			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = true;
			
			_plate = new Plate();			
			_plate.getChildAt(0).x -= .5 * _plate.width;
			_plate.getChildAt(0).y -= .5 * _plate.height;
			if(url != null){
				_image = new Sprite();
			
				_loader = new Loader();
				_loader.load(new URLRequest(url), context);
				_loader.contentLoaderInfo.addEventListener(Event.OPEN, onImageLoadStart);
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoadComplete);
				
				_autorotate = autorotate;
			}
			else if (imageSource != null){
				var simg:Sprite = imageSource.getImage();
				var curScaleX = simg.scaleX;
				var curScaleY = simg.scaleY;
				_autorotate = imageSource.getAutorotate();
				simg.scaleX = simg.scaleY = 1;
				_image = DisplayObjectTools.duplicateAsBitmap(simg);
				simg.scaleX = curScaleX;
				simg.scaleY = curScaleY;
				clearPlate();
				DisplayObjectTools.changeSizeToFit(_image, _plate.width - _margin * 2, _plate.height - _margin * 2);
				
			}
			else{
				throw new Error("Error in DecoElement constructor. No url or source provided");
			}			
			_plate.buttonMode = false;
			_plate.mouseChildren = false;
			_image.buttonMode = true;
			addChild(_plate);
			addChild(_image);
			
		}
		
		private function onImageLoadStart(evt:Event){
			_indicator = new DecoIndicator();
			addChild(_indicator);
			_indicator.mouseChildren = false;
			_indicator.gotoAndPlay(Math.floor(Math.random() * _indicator.totalFrames + 1));
		}
		
		private function onImageLoadComplete(evt:Event){
			_imageloaded = true;
			removeChild(_indicator);
			_indicator = null;
			clearPlate();
			var img:Bitmap = evt.currentTarget.content as Bitmap;
			img.smoothing = true;
			img.x -= img.width * .5;
			img.y -= img.height * .5;
			_image.addChild(img);
			DisplayObjectTools.changeSizeToFit(_image, _plate.width - _margin * 2, _plate.height - _margin * 2);
		}
		
		override public function toString():String{
			return _type;
		}
		
		public function clearPlate(){
			_plate.visible = false;
		}
		
		public function showPlate(){
			_plate.visible = true;
		}
		
		public function getPlate(){
			return _plate;
		}
		
		public function getImage(){
			return _image;
		}
		
		public function getType():String{
			return _type;
		}
		
		public function getInfo():String{
			return _info;
		}
		
		public function getURL():String{
			return _url;
		}
		public function getAutorotate():Boolean{
			return _autorotate;
		}
		
		public function setChoserContainer(container:ChoserContainer){
			_choserContainer = container;
		}
		
		public function getChoserContainer():ChoserContainer{
			return _choserContainer;
		}
		
		public function isLoaded():Boolean{
			return _imageloaded;
		}
	}
}