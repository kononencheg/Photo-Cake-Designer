package cakeConstructor{
	
	import flash.display.*;
	import flash.text.TextField;
	import flash.events.*;
	import flash.external.ExternalInterface;
	
	public class Preloader extends MovieClip {
		
		private const mainFrame:uint = 2;
		private const mainClassName:String = "Main";
		private var main:Object;
		private var _initialized:Boolean = false;
		public var clip:MovieClip;
		public var statusTxt:TextField;
		public var labelTxt:TextField;
		
		public function Preloader() {
			stop();
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loaderInfo.addEventListener(Event.COMPLETE, completeHandler);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			var loaded:uint = event.bytesLoaded;
			var total:uint = event.bytesTotal;
			var s:Number = Math.floor(loaded/total*100);
			statusTxt.text = s.toString() + "%";
			clip.gotoAndStop(s);
		}
		
		private function completeHandler(event:Event):void {
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(event:Event):void {			
			if (currentFrame >= mainFrame) {
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				run();
				// На этом месте флэш готов к взаимодействию
				ExternalInterface.call("onFlashReady");
				// Тестирование
				//test();
				// Конец тестирования
			}
			else nextFrame();
		}	
	
		// Тестирование
		private function test(){
			import flash.utils.setTimeout;
			var preset1 = '{"content":{"text":{"transform":[0.8671967387199402,-0.49796563386917114,0.49796563386917114,0.8671967387199402,123.65,107.5],"font":"Arial","value":"Привет","size":72,"color":13369344},"deco":[{"name":"cherry","transform":[-0.0966339111328125,-0.9949951171875,0.9949951171875,-0.0966339111328125,162,248]},{"name":"grape","transform":[-0.6793670654296875,-0.7315826416015625,0.7315826416015625,-0.6793670654296875,219,224]},{"name":"kiwi","transform":[0.5707550048828125,0.819244384765625,-0.819244384765625,0.5707550048828125,106,86]},{"name":"car1","transform":[1,0,0,1,229,161]}],"base_color":6723840},"dimensions":{"persons_count":15,"ratio":0.5,"mass":2,"shape":"rect"}}';
			var preset2 = '{"content":{"base_color":16737843,"deco":[{"name":"cherry","transform":[-0.0966339111328125,-0.9949951171875,0.9949951171875,-0.0966339111328125,162,248]},{"name":"grape","transform":[-0.6793670654296875,-0.7315826416015625,0.7315826416015625,-0.6793670654296875,219,224]},{"name":"kiwi","transform":[0.5707550048828125,0.819244384765625,-0.819244384765625,0.5707550048828125,106,86]},{"name":"pig1","transform":[1,0,0,1,225,97]},{"name":"bear1","transform":[1,0,0,1,67,140]},{"name":"car1","transform":[1,0,0,1,153,192]},{"name":"kiwi","transform":[0.74066162109375,-0.6694488525390625,0.6694488525390625,0.74066162109375,80,218]},{"name":"kiwi","transform":[0.013214111328125,0.9998626708984375,-0.9998626708984375,0.013214111328125,151,42]}],"text":{"transform":[0.956829845905304,0.2906486988067627,-0.2906486988067627,0.956829845905304,175.5,87.3],"font":"Arial","value":"xkjsd","size":92,"color":13369344},"photo":{"transform":[0.226654052734375,0,0,0.226654052734375,16,16],"image_source":"user"}},"dimensions":{"ratio":0.5,"persons_count":15,"mass":2,"shape":"round"}}';
			var preset3 = '{"content":{"deco":[{"name":"kiwi","transform":[0.6978759765625,-0.71392822265625,0.71392822265625,0.6978759765625,74,233]},{"name":"car1","transform":[1,0,0,1,210,104]},{"name":"pig1","transform":[1,0,0,1,68,94]}],"photo":{"image_source":"network","photo_url":"Photo.jpg","transform":[0.226654052734375,0,0,0.226654052734375,16,16.1]},"text":{"transform":[1,0,0,1,125,131],"font":"Arial","value":"ijij","size":92,"color":255},"base_color":-1},"dimensions":{"ratio":0.6,"persons_count":6,"mass":1,"shape":"rect"}}';
			var preset4 = '{"content":{"base_color":-1,"deco":[{"name":"car1","transform":[1,0,0,1,209,89]},{"name":"pig1","transform":[1,0,0,1,210,173]},{"name":"bear1","transform":[1,0,0,1,156,232]},{"name":"kiwi","transform":[0.5154266357421875,0.8552398681640625,-0.8552398681640625,0.5154266357421875,116,92]},{"name":"grape","transform":[0.98565673828125,0.165496826171875,-0.165496826171875,0.98565673828125,55,136]},{"name":"cherry","transform":[0.850921630859375,-0.52252197265625,0.52252197265625,0.850921630859375,75,200]},{"name":"grape","transform":[0.9242401123046875,-0.3787994384765625,0.3787994384765625,0.9242401123046875,122,165]},{"name":"raspberry","transform":[-0.990325927734375,0.135498046875,-0.135498046875,-0.990325927734375,257,138]},{"name":"kiwi","transform":[-0.544677734375,-0.83685302734375,0.83685302734375,-0.544677734375,210,241]}]},"dimensions":{"persons_count":45,"ratio":0.25,"mass":5,"shape":"round"}}';
			var preset5 = '{"dimensions":{"persons_count":6,"mass":1,"shape":"round","ratio":0.25},"content":{"photo":{"transform":[0.60443115234375,0,0,0.60443115234375,16,16],"photo_url":"http://agudo.ru/uploads/posts/2009-09/1251785393_guinea-pig-square.jpg","image_source":"network"},"base_color":-1}}';

			var initData = '{"weightsList":[1,1.5,2,2.5,3,3.5,4,4.5,5],"ratiosList":[0.6,0.55,0.5,0.45,0.4,0.38,0.32,0.3,0.25],"decoSelectors":[{"deco":[{"url":"images/cherry.png","autorotate":true,"name":"cherry","description":"Вишня"},{"url":"images/grape.png","autorotate":true,"name":"grape","description":"Виноград"},{"url":"images/kiwi.png","autorotate":true,"name":"kiwi","description":"Киви"},{"url":"images/raspberry.png","autorotate":true,"name":"raspberry","description":"Малина"},{"url":"images/strawberry.png","autorotate":true,"name":"strawberry","description":"Клубника"},{"url":"images/orange.png","autorotate":true,"name":"orange","description":"Апельсин"},{"url":"images/peach.png","autorotate":true,"name":"peach","description":"Персик"},{"url":"images/lemon.png","autorotate":true,"name":"lemon","description":"Лимон"}]}],"personsList":[6,10,15,20,25,30,35,40,45]}';
			var initData2 = '{"weightsList":[1,1.5,2,2.5,3,3.5,4,4.5,5],"decoSelectors":[{"deco":[{"url":"images/cherry.png","autorotate":true,"name":"cherry","description":"Вишня"},{"url":"images/grape.png","autorotate":true,"name":"grape","description":"Виноград"},{"url":"images/kiwi.png","autorotate":true,"name":"kiwi","description":"Киви"},{"url":"images/raspberry.png","autorotate":true,"name":"raspberry","description":"Малина"},{"url":"images/strawberry.png","autorotate":true,"name":"strawberry","description":"Клубника"},{"url":"images/orange.png","autorotate":true,"name":"orange","description":"Апельсин"},{"url":"images/peach.png","autorotate":true,"name":"peach","description":"Персик"},{"url":"images/lemon.png","autorotate":true,"name":"lemon","description":"Лимон"}]},{"deco":[{"url":"images/bear1.png","autorotate":false,"name":"bear1","description":"Сахарная фигурка"},{"url":"images/pig1.png","autorotate":false,"name":"pig1","description":"Сахарная фигурка"},{"url":"images/car1.png","autorotate":false,"name":"car1","description":"Сахарная фигурка"},{"url":"images/hare1.png","autorotate":false,"name":"hare1","description":"Сахарная фигурка"},{"url":"images/hedgehog1.png","autorotate":false,"name":"hedgehog1","description":"Сахарная фигурка"},{"url":"images/moose1.png","autorotate":false,"name":"moose1","description":"Сахарная фигурка"},{"url":"images/owl1.png","autorotate":false,"name":"owl1","description":"Сахарная фигурка"},{"url":"images/pin1.png","autorotate":false,"name":"pin1","description":"Сахарная фигурка"},{"url":"images/sheep1.png","autorotate":false,"name":"sheep1","description":"Сахарная фигурка"},{"url":"images/raven1.png","autorotate":false,"name":"raven1","description":"Сахарная фигурка"},{"url":"images/mat1.png","autorotate":false,"name":"mat1","description":"Сахарная фигурка"}]}],"ratiosList":[0.6,0.55,0.5,0.45,0.4,0.38,0.32,0.3,0.25],"personsList":[6,10,15,20,25,30,35,40,45]}';
			var initData3 = '{"weightsList":[1,1.5,2,2.5,3,3.5,4,4.5,5],"ratiosList":[0.6,0.55,0.5,0.45,0.4,0.38,0.32,0.3,0.25],"personsList":[6,10,15,20,25,30,35,40,45],"decoSelectors":[{"deco":[{"url":"images/cherry.png","autorotate":true,"name":"cherry","description":"Вишня"},{"url":"images/grape.png","autorotate":true,"name":"grape","description":"Виноград"},{"url":"images/kiwi.png","autorotate":true,"name":"kiwi","description":"Киви"},{"url":"images/raspberry.png","autorotate":true,"name":"raspberry","description":"Малина"},{"url":"images/strawberry.png","autorotate":true,"name":"strawberry","description":"Клубника"},{"url":"images/orange.png","autorotate":true,"name":"orange","description":"Апельсин"},{"url":"images/peach.png","autorotate":true,"name":"peach","description":"Персик"},{"url":"images/lemon.png","autorotate":true,"name":"lemon","description":"Лимон"}]},{"deco":[{"url":"images/pig1.png","autorotate":false,"name":"pig1","description":"Сахарная фигурка"},{"url":"images/car1.png","autorotate":false,"name":"car1","description":"Сахарная фигурка"},{"url":"images/hare1.png","autorotate":false,"name":"hare1","description":"Сахарная фигурка"},{"url":"images/hedgehog1.png","autorotate":false,"name":"hedgehog1","description":"Сахарная фигурка"},{"url":"images/moose1.png","autorotate":false,"name":"moose1","description":"Сахарная фигурка"},{"url":"images/owl1.png","autorotate":false,"name":"owl1","description":"Сахарная фигурка"},{"url":"images/pin1.png","autorotate":false,"name":"pin1","description":"Сахарная фигурка"},{"url":"images/sheep1.png","autorotate":false,"name":"sheep1","description":"Сахарная фигурка"},{"url":"images/raven1.png","autorotate":false,"name":"raven1","description":"Сахарная фигурка"},{"url":"images/bear1.png","autorotate":false,"name":"bear1","description":"Сахарная фигурка"},{"url":"images/car2.png","autorotate":false,"name":"car2","description":"Сахарная фигурка"},{"url":"images/car3.png","autorotate":false,"name":"car3","description":"Сахарная фигурка"},{"url":"images/mat1.png","autorotate":false,"name":"mat1","description":"Сахарная фигурка"},{"url":"images/doll1.png","autorotate":false,"name":"doll1","description":"Сахарная фигурка"},{"url":"images/doll2.png","autorotate":false,"name":"doll2","description":"Сахарная фигурка"}]},{"deco":[{"url":"images/flower1.png","autorotate":false,"name":"flower1","description":"Сахарная фигурка"},{"url":"images/flower2.png","autorotate":false,"name":"flower2","description":"Сахарная фигурка"},{"url":"images/flower3.png","autorotate":false,"name":"flower3","description":"Сахарная фигурка"},{"url":"images/flower4.png","autorotate":false,"name":"flower4","description":"Сахарная фигурка"},{"url":"images/flower5.png","autorotate":false,"name":"flower5","description":"Сахарная фигурка"},{"url":"images/flower6.png","autorotate":false,"name":"flower6","description":"Сахарная фигурка"}]}]}';
			var initData4 = '{"weightsList":[1,1.5,2,2.5,3,3.5,4,4.5,5],"decoSelectors":[{"deco":[{"url":"images/cherry.png","autorotate":true,"name":"cherry","description":"Вишня"},{"url":"images/grape.png","autorotate":true,"name":"grape","description":"Виноград"},{"url":"images/kiwi.png","autorotate":true,"name":"kiwi","description":"Киви"},{"url":"images/raspberry.png","autorotate":true,"name":"raspberry","description":"Малина"},{"url":"images/strawberry.png","autorotate":true,"name":"strawberry","description":"Клубника"},{"url":"images/orange.png","autorotate":true,"name":"orange","description":"Апельсин"},{"url":"images/peach.png","autorotate":true,"name":"peach","description":"Персик"},{"url":"images/lemon.png","autorotate":true,"name":"lemon","description":"Лимон"}]},{"deco":[{"url":"images/bear1.png","autorotate":false,"name":"bear1","description":"Сахарная фигурка"},{"url":"images/pig1.png","autorotate":false,"name":"pig1","description":"Сахарная фигурка"},{"url":"images/car1.png","autorotate":false,"name":"car1","description":"Сахарная фигурка"},{"url":"images/hare1.png","autorotate":false,"name":"hare1","description":"Сахарная фигурка"},{"url":"images/hedgehog1.png","autorotate":false,"name":"hedgehog1","description":"Сахарная фигурка"},{"url":"images/moose1.png","autorotate":false,"name":"moose1","description":"Сахарная фигурка"},{"url":"images/owl1.png","autorotate":false,"name":"owl1","description":"Сахарная фигурка"},{"url":"images/pin1.png","autorotate":false,"name":"pin1","description":"Сахарная фигурка"},{"url":"images/sheep1.png","autorotate":false,"name":"sheep1","description":"Сахарная фигурка"},{"url":"images/raven1.png","autorotate":false,"name":"raven1","description":"Сахарная фигурка"},{"url":"images/mat1.png","autorotate":false,"name":"mat1","description":"Сахарная фигурка"}]},{"deco":[{"url":"images/bear1.png","autorotate":false,"name":"bear1","description":"Сахарная фигурка"},{"url":"images/pig1.png","autorotate":false,"name":"pig1","description":"Сахарная фигурка"},{"url":"images/car1.png","autorotate":false,"name":"car1","description":"Сахарная фигурка"},{"url":"images/hare1.png","autorotate":false,"name":"hare1","description":"Сахарная фигурка"},{"url":"images/hedgehog1.png","autorotate":false,"name":"hedgehog1","description":"Сахарная фигурка"},{"url":"images/moose1.png","autorotate":false,"name":"moose1","description":"Сахарная фигурка"},{"url":"images/owl1.png","autorotate":false,"name":"owl1","description":"Сахарная фигурка"},{"url":"images/pin1.png","autorotate":false,"name":"pin1","description":"Сахарная фигурка"},{"url":"images/sheep1.png","autorotate":false,"name":"sheep1","description":"Сахарная фигурка"},{"url":"images/raven1.png","autorotate":false,"name":"raven1","description":"Сахарная фигурка"},{"url":"images/mat1.png","autorotate":false,"name":"mat1","description":"Сахарная фигурка"}]},{"deco":[{"url":"images/cherry.png","autorotate":true,"name":"cherry","description":"Вишня"},{"url":"images/grape.png","autorotate":true,"name":"grape","description":"Виноград"},{"url":"images/kiwi.png","autorotate":true,"name":"kiwi","description":"Киви"},{"url":"images/raspberry.png","autorotate":true,"name":"raspberry","description":"Малина"},{"url":"images/strawberry.png","autorotate":true,"name":"strawberry","description":"Клубника"},{"url":"images/orange.png","autorotate":true,"name":"orange","description":"Апельсин"},{"url":"images/peach.png","autorotate":true,"name":"peach","description":"Персик"},{"url":"images/lemon.png","autorotate":true,"name":"lemon","description":"Лимон"}]}],"ratiosList":[0.6,0.55,0.5,0.45,0.4,0.38,0.32,0.3,0.25],"personsList":[6,10,15,20,25,30,35,40,45]}';
			init(initData4, "rect", .5);
//			setTimeout(main.getCakeData, 8000);
//			setTimeout(main.changeShape, 3000, "rect");
//			setTimeout(main.loadExternalImage, 5000, 'http://www.babai.ru/upload/iblock/ea1/ea1851f38b8a5cc008218e095897559d.jpg');
//			setTimeout(main.getCakeData, 8000);
			//setTimeout(main.loadCakePreset, 10000, preset1);
//			setTimeout(main.loadCakePreset, 14000, preset2);
//			setTimeout(main.loadCakePreset, 15000, preset3);
//			setTimeout(main.loadCakePreset, 16000, preset4);
			setTimeout(main.loadCakePreset, 1000, preset5);
		}
		
				
		private function run():void {
			var programClass:Class = loaderInfo.applicationDomain.getDefinition(mainClassName) as Class;
			main = new programClass();
			ExternalInterface.addCallback("initialize", init);
			ExternalInterface.addCallback("loadExternalImage", main.loadExternalImage);
			ExternalInterface.addCallback("loadCakePreset", main.loadCakePreset);
			ExternalInterface.addCallback("changeShape", main.changeShape);
			ExternalInterface.addCallback("getCakeData", main.getCakeData);
			ExternalInterface.addCallback("getCakeWeight", main.getCakeWeight);
		}

		internal function init(data, shape:String, scale:Number){
			if(!_initialized){
				addChild(main as DisplayObject);
				main.initialize(data, shape, scale);
				_initialized = true;
			}
		}
	}
}
