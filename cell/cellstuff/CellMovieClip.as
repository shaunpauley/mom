package CellStuff {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	
	import flash.geom.Rectangle;
	
	import flash.events.Event;
	
	public class CellMovieClip extends Bitmap {
		
		private var m_frames:Array;
		
		private var m_currentFrame:int;
		private var m_numFrames:int;
		
		private var m_isPlaying:Boolean;
		
		/* Constructor
		*/
		public function CellMovieClip(sourceRect:Rectangle, bitmapFrames:Array):void {
			Reset(sourceRect, bitmapFrames);
			play();
		}
		
		/* Reset 
		* resets the cell movie with frames and start rectangle
		*/
		public function Reset(sourceRect:Rectangle, bitmapFrames:Array):void {
			m_frames = bitmapFrames;
			
			m_numFrames = m_frames.length;
			m_currentFrame = 1;
			
			m_isPlaying = false;
			
			bitmapData = m_frames[m_currentFrame-1];
			
			x = sourceRect.x;
			y = sourceRect.y;
		}
		
		/* totalFrames
		* returns the number of frames, like in MovieClip
		*/
		public function get totalFrames():Number {
			return m_numFrames;
		}
		
		/* play
		* plays the animation
		*/
		public function play():void {
			if (!m_isPlaying) {
				addEventListener(Event.ENTER_FRAME, Update);
				m_isPlaying = true;
			}
			
		}
		
		/* stop
		* stops the animation
		*/
		public function stop():void {
			if (m_isPlaying) {
				removeEventListener(Event.ENTER_FRAME, Update);
				m_isPlaying = false;
			}
		}
		
		/* gotoAndPlay
		*/
		public function gotoAndPlay(frameNum:int):void {
			m_currentFrame = frameNum;
			play();
		}
		
		/* gotoAndStop
		*/
		public function gotoAndStop(frameNum:int):void {
			m_currentFrame = frameNum;
			stop();
		}
		
		/* Update
		* called on each ENTER FRAME, displays the correct frame
		*/
		private function Update(event:Event):void {
			bitmapData = m_frames[m_currentFrame-1];
			m_currentFrame++;
			if (m_currentFrame > totalFrames) {
				m_currentFrame = 1;
			}
		}
		
		/* CurrentFrame
		* returns the current frame
		*/
		public function get currentFrame():int {
			return m_currentFrame;
		}
	}
	
}