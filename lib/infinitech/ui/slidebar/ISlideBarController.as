package infinitech.ui.slidebar{
	
	import infinitech.ui.slidebar.view.SlideBarView;
	
	public interface ISlideBarController {
		
		function setSlideBarView (view:SlideBarView);
		
		function setSlidePosition(position:Number):void;
		
		function getSlidePosition():Number;
		
		function getSlideValue():Number;
		
		function setSlideRange(minValue:Number, maxValue:Number):void;
		
		function resizeSlide(size:Number):void
		
	}
}