package CellStuff {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import flash.display.BitmapData;
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class CellCachedBitmapData {
		
		private var m_sourceMC:MovieClip;
		private var m_frames:Array;
		
		/* Constructor
		*/
		public function CellCachedBitmapData(mc:MovieClip):void {
			m_sourceMC = mc;
			
			m_frames = GenerateBitmapFramesFromMovie(new Array(), mc);
		}
		
		/* GenerateBitmapFramesFromMovie
		* generates each bitmap data frame from each frame of a movie clip
		*/
		private function GenerateBitmapFramesFromMovie(frames:Array, mc:MovieClip):Array {
			
			var rect:Rectangle = mc.getRect(mc);
			
			for (var i:int = 1; i <= mc.totalFrames; ++i)
			{
				mc.gotoAndStop(i)
				
				var bitmapData:BitmapData = new BitmapData(rect.width, rect.height, true, 0x00000000);
				
				var trans:Matrix = new Matrix();
				trans.translate(-rect.x, -rect.y);
				trans.scale(mc.scaleX, mc.scaleY);
				
				bitmapData.draw(mc, trans);
				
				frames.push(bitmapData);
			}
			
			return frames
		}
		
		/* CreateNewMovieClipCached
		* creates a new bitmap instance using the bitmap data
		*/
		public function CreateNewMovieClipCached():CellMovieClip {
			return new CellMovieClip(m_sourceMC.getRect(m_sourceMC), m_frames);
		}
		
		/* GetFrames
		* returns a list of frames,
		* each frame is BitmapData that reprents a frame of the source movieclip
		*/
		public function GetFrames():Array {
			return m_frames;
		}
		
		/* GetSourceRectangle
		* returns the source rectangle dimensions
		*/
		public function GetSourceRectangle():Rectangle {
			return m_sourceMC.getRect(m_sourceMC);
		}
		
	}
}