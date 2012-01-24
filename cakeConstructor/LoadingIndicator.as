package cakeConstructor{
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class LoadingIndicator extends MovieClip {
		public var statusBar:MovieClip;
		public var statusTxt:TextField;
		
		public function LoadingIndicator(){
			x = 380;
			y = 247;			
			updateState(0);
		}
		
		public function updateState(status:Number){
			statusBar.scaleX = status;
			statusTxt.text = Math.floor(status * 100).toString() + "%";
		}
	}
}
