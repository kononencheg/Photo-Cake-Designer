﻿package infinitech.utils {
	import infinitech.math.MathOperations;
	public class ColorConversion {
	
	/**
	* Конвертирует RGB-значениe цвета в HSB-представление и возвращает массив с его компонентами
	* rgb - значение цвета (hex)
	*/
	public static function RGBtoHSB (rgb:Number):Array{
		// Выделяем цветовые составляющие
		var R:uint = (rgb&0xff0000)>>16; 
		var G:uint = (rgb&0xff00)>>8;
		var B:uint = (rgb&0xff);
		var S:Number;
		var H:Number;
		// Яркость определяется как максимальная интенсивность составляющей (от 0 до 255)
		var Br:Number = MathOperations.max(R, G, B);
		// Определяем минимальное значение интенсивности составляющей в цвете
		var minVal:uint = MathOperations.min(R, G, B); 
		// Диапазон значений, соответствующих насыщенности цвета
		var delta = Br - minVal;
		// Если интенсивность каждой составляющей равна нулю, получаем черный цвет, насыщенность которого равна нулю
		if (Br == 0){
			S = 0;
		}
		// При ненулевой яркости насыщенность определяется как отношение разности максимальной и минимальной интенсивности составляющих цвета к его яркости (от 0 до 255), умноженное на 100
		else {
			S = delta / Br * 100;
		}
		// При нулевой насыщенности - ахроматический цвет, поэтому параметру Hue присвоим значение 0 (строго говоря тон неопределен)
		if (S == 0)H = 0;
		// При ненулевой насыщенности - хроматический цвет. Определяем тон как угол(в градусах) на цветовом круге
		else {
			// Если красная составляющая имеет максимальную интенсивность, то цветовой тон лежит между пурпурным и желтым
			if (R == Br){
				H = 60 * (G - B) / delta; 
			}
			else{
			// Если зеленая составляющая имеет максимальную интенсивность, то цветовой тон лежит между голубым и желтым
				if (G == Br){
					H = 120 + 60 * (B - R) / delta;
				}	
				// Если синяя составляющая имеет максимальную интенсивность, то цветовой тон лежит между пурпурным и голубым
				else {
					H = 240 + 60 * (R - G) / delta;
				}	
			}
		} 
		// Если тон получился отрицательным, добавляем полный оборот для получения положительного значения
		if (H < 0) H += 360;
		// Возвращаем массив с полученными значенями Hue, Saturation и Brightness
		return ([Math.round(H), Math.round(S), Math.round(Br / 255 * 100)]);
	}
	
	
	/**
	* Конвертирует HSB-значения цвета в 16-ричное RGB-представление
	* H - тон 0 - 360 градусов
	* S - насыщенность 0 - 100 процентов
	* Br - яркость 0 - 100 процентов
	*/
	public static function HSBtoRGB(H:Number, S:Number, Br:Number):Number {
		// Нормируем Br, так чтобы значение яркости изменялось в диапазоне от 0 до 255
		Br = Br/100 * 255;
		var R:uint; 
		var G:uint;
		var B:uint;
		// При нулевой насыщенности - ахроматический цвет (оттенок серого). Все цветовые составляющие имеют одинаковое значение, определяемое яркостью
		if (S==0){
			R=G=B=Br;
		}
		// Если насыщенность отлична от нуля - хроматический цвет
		else {
			// Вычисляем долю 60-градусного сектора цветового круга, отделяющую заданный тон от границы этого сектора
			var resH = H/60 - Math.floor(H/60);
			//trace(H + "  " + H/60 + "  "+ "res " + resH);
			 // Определяем минимальное значение цветовой составляющей
			var bot=Br*(1-S/100);
			 // Определяем промежуточное значение цветовой составляющей на убывающей части графика
			var dec=Br*(1-(S*resH)/100);
			 // Определяем промежуточное значение цветовой составляющей на возрастающей части графика
			var inc=Br*(1-(S*(1-resH)/100));
			// В зависимости от принадлежности заданного тона к определенному сектору цветового круга, устанавливаем значения цветовых составляющих в соответствии с графиком
			switch(Math.floor(H/60)){
			  case 0: // Красный цвет
				R = Br; 
				G = inc;
				B = bot;
				break;
			  case 1: // Желтый цвет
				R = dec; 
				G = Br; 
				B = bot;
				break;
			  case 2: // Зеленый цвет
				R = bot; 
				G = Br; 
				B = inc;
				break;
			  case 3: // Голубой цвет
				R = bot; 
				G = dec; 
				B = Br;
				break;
			  case 4: // Синий цвет
				R = inc; 
				G = bot;
				B = Br;
				break;
			  case 5: // Пурпурный цвет
				R = Br; 
				G = bot;
				B = dec;
				break;
			}
		}
		// Возвращаем шестнадцатеричное значение цвета
		return Math.round(R)<<16|Math.round(G)<<8|Math.round(B);
		}
	}
}