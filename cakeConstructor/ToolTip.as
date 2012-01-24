package cakeConstructor{
	import flash.display.Sprite;
	import flash.text.*;

	public class ToolTip extends Sprite {

		private  var infoLabel:TextField;
		private  var infoLabelFormat:TextFormat = new TextFormat("Arial",12,0x555555,null,null,null,null,null,TextFormatAlign.CENTER);
		private  var isOn:Boolean = false;
		
		public function ToolTip(){
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		public  function display(value:String, xCoord:Number, yCoord:Number) {
			clear();
			if(!isOn){
				infoLabel = new TextField();
				infoLabel.width = infoLabel.height = 0;
				this.x = xCoord;
				this.y = yCoord;
				infoLabel.defaultTextFormat = infoLabelFormat;
				infoLabel.autoSize = TextFieldAutoSize.CENTER;
				infoLabel.text = value;
				this.addChild(infoLabel);
				isOn = true;
			}
		}
		
		public  function clear() {
			if(isOn){
				this.removeChild(infoLabel);
				infoLabel = null;
				isOn = false;
			}
		}
	}
}