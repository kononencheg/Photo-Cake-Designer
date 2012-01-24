package infinitech.utils{
	public class StringFormator {
		// Выводит продолжительность, полученную в секундах, в формате мин:сек
		public static function parseSeconds(value:Number):String {
			value = Math.round(value);
			var minutes = Math.floor(value / 60);
			var seconds = value - minutes * 60;
			if (minutes < 10) {
				minutes = "0" + minutes;
			}
			if (seconds < 10) {
				seconds = "0" + seconds;
			}
			return minutes + ":" + seconds;
		}
	}
}