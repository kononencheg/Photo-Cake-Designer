package cakeConstructor.dataFormats{
	public class CakeData{
		// JSON данных о торте для отправки/загрузки состояния
		/*
		"cake": {
		"dimensions": {
		"mass": 1,
		"shape": "square|circle", // round|rect как будет удобнее!
		"width": 21,
		"height": 5,
		"persons_count": 5,
		"ratio": 0.75
		},

		"image_url": "", // картинка торта (готовая)
		"content": {
		"base_color": 3342336,
		"deco": [
		{
		"name": "Kiwi",
		"picture_url": "",
		"transform": [
		0.0, 0.0, 0.0,
		0.0, 0.0, 0.0,
		0.0, 0.0, 0.0
		]
		},
		 ... 
					],
		"text": {
			"color": 16777215,
			"value": "Hello, world!",
			"size":42,
			"font":"Verdana",
			"transform": [
				0.0, 0.0, 0.0,
				0.0, 0.0, 0.0,
				0.0, 0.0, 0.0
			]
		},
		"photo" : {
			"image_source": user|network
			"photo_url": "",
			"transform": [
				0.0, 0.0, 0.0,
				0.0, 0.0, 0.0,
				0.0, 0.0, 0.0
			]
		}
	}
}
		*/
				
		// Константы
		// Максимально допустимая длина стороны загружаемого изображения в пикселях
		public static const IMAGE_DIMENSIONS_LIMIT:uint = 1200;
		// Максимально допустимый объем загружаемого изображения в мегабайтах
		public static const IMAGE_SIZE_LIMIT:uint = 5;
		// Доступные формы
		public static const RECT:String = "rect";
		public static const ROUNDED:String = "round";
		public static const SHAPES:Array = [RECT, ROUNDED];
		// Доступные элементы декора верха (Идентификаторы символов в библиотеке)
		public static const RASPBERRY:String = "Raspberry";
		public static const STRAWBERRY:String = "Strawberry";
		public static const KIWI:String = "Kiwi";
		public static const LEMON:String = "Lemon";
		public static const ORANGE:String = "Orange";
		public static const PEACH:String = "Peach";
		public static const GRAPE:String = "Grape";
		public static const CHERRY:String = "Cherry";
		public static const PRESET:String = "preset";
		public static const TOP_DECO:Array = [RASPBERRY, STRAWBERRY, KIWI, LEMON, ORANGE, PEACH, GRAPE, CHERRY];
		// Подписи к элементам декора верха
		public static const TOP_DECO_INFO:Array = ["Малина", "Клубника", "Киви", "Лимон", "Апельсин", "Персик", "Виноград", "Вишня"];
		// Доступные цвета верха
		public static const TOP_COLORS:Array = [0xF8187B, 0xF56473, 0xF02835, 0x790206, 0x9E3F00, 0xCF5200, 0xFD6B04, 0xF88A4D,  0xFFB180,  0xFFD485, 0xFFF3E5, 0xFBF480, 0xFEE800, 0xA4FF80, 0xA8E4FC];
		// Флаги, используемые для передачи в JS сведений об изменениях при конструировании
		public static const COLOR:String = "color";
		public static const IMAGE:String = "image";
		public static const WRITING:String = "writing";
		public static const DECO:String = "alldeco";
		// Текущие параметры значения должны присваиваться только извне
		// Текущая форма
		public var cakeBaseShape:String;
		// Текущий цвет. -1 - отсутствие цвета
		public var cakeBaseColor:Number;		
		// Масштабный коэффициент
		public var scaleFactor:Number;
		
		public var image:CakeImageData;
		public var writing:CakeWritingData;
		public var deco:CakeDecoData;
		// Массив байтов для изображения созданного торта в base64
		// public var cakeSnapshotBase64:String;
		// Массив байтов для изображения, загруженного пользователем, в base64
		// public var imageBytesBase64:String;
		
		
		public var dimensions:Object;
		public var content:Object;
		
		
		public function CakeData(){
		}
	}
}