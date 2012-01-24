package infinitech.utils{
	import flash.utils.ByteArray;
	public class ObjectOperations{
		// Создает копию объекта
		public static function clone(value:Object):Object{
			 var buffer:ByteArray = new ByteArray();
			 buffer.writeObject(value);
			 buffer.position = 0;
			 return buffer.readObject();
    	 }
		 // Возвращает объем объекта в байтах
		 public static function getSizeInBytes(value:Object):int{
			 var buffer:ByteArray = new ByteArray();
			 buffer.writeObject(value);
			 buffer.position = 0;
			 return buffer.length;
    	 }
	}
}