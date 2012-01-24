package cakeConstructor.dataFormats{
	
	import flash.utils.ByteArray;
	public class CakeImageData{
		// Откуда получено изображение (значения свойства imageSource)
		public static const USER_IMAGE_SOURCE:String = "user";
		public static const NETWORK_IMAGE_SOURCE:String = "network";
		// Откуда получено изображение
		public var imageSource:String;
		// Ссылка (для изображения, загруженного из сети)
		public var imageURL:String;
		// Матрица трансформации изображения
		public var transformMatrix:Object;
		
	}
}