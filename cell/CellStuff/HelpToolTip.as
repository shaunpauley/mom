package CellStuff {
	import flash.display.MovieClip;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class HelpToolTip extends MovieClip{
		public static var myHelpText:TextField;
		
		public function HelpToolTip() {
			mouseEnabled = false;
			mouseChildren = false;
			
			// text
			myHelpText = new TextField();
			myHelpText.x = 0;
			myHelpText.y = -100;
			myHelpText.autoSize = TextFieldAutoSize.LEFT;
			
			var Format:TextFormat = new TextFormat();
			Format.font = "Courier New";
			Format.color = 0x441111;
			Format.size = 10;
			
			myHelpText.defaultTextFormat = Format;
			myHelpText.selectable = false;
			myHelpText.text = "";
			
			myHelpText.mouseEnabled = false;
			addChild(myHelpText);
		}
		
		public static function updateText(s:String) {
			myHelpText.text = s;
		}
		
	}
}