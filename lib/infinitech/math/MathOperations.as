package  infinitech.math{
	public class MathOperations {
		//Возвращает максимальное из переданных ей значений
		public static function max(...args):Number {
			var max = -Infinity;
			for (var i = 0; i < args.length; i++) {
				max = Math.max(max, args[i]);
			}
			return max;
			}
		//Возвращает минимальное из переданных ей значений
		public static function min(...args):Number {
			var min = Infinity;
			for (var i = 0; i < args.length; i++) {
				min = Math.min(min, args[i]);
			}
			return min;
		}
	}
}
