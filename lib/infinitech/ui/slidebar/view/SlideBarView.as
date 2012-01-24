package infinitech.ui.slidebar.view{
	
	import flash.display.MovieClip;
	
	public class SlideBarView extends MovieClip {
		
		// Ползунок
		public var slider:MovieClip;
		// Пиктограмма в клипе-ползунке
		public var icon:MovieClip
		// Полоса прокрутки
		public var slideTrack:MovieClip;
		// Индикатор (загрузки) на полосе прокрутки
		public var bufferIndicator:MovieClip;
		// Активная область полосы прокрутки
		public var slideTrackHitArea:MovieClip;
		
		public function SlideBarView(sliderCLip:MovieClip, slideTrackClip:MovieClip, slideTrackHitAreaClip:MovieClip, bufferIndicatorCLip = null){
				// Ползунок 
				slider = sliderCLip;
				// В ползунке может находиться клип icon, с пиктограммой, который при наведении может масштабироваться иначе, чем ползунок
				if(slider.icon != null){
					icon = slider.icon;
					icon.mouseEnabled = false;
				}
				slider.buttonMode = true;
				slideTrack = slideTrackClip;
				bufferIndicator = bufferIndicatorCLip;
				slideTrackHitArea = slideTrackHitAreaClip;
				slideTrackHitArea.alpha = 0;
				addChild(slideTrack);
				addChild(bufferIndicator);
				addChild(slideTrackHitArea);
				addChild(slider);
				
		}
	}
}