package CellStuff {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	
	import flash.utils.Dictionary;
	
	import flash.utils.getDefinitionByName;
	
	public class CellBitmapManager {
		
		private var m_bitmapCachedLibrary:Dictionary;
		
		private var m_movieClipStack:Array;
		
		// stats
		
		private var m_numBitmaps:int;
		
		/* Constructor
		*/
		public function CellBitmapManager():void {
			m_bitmapCachedLibrary = new Dictionary();
			
			m_movieClipStack = new Array();
			
			m_numBitmaps = 0;
			
		}
		
		/* SetGridObjectSprite
		* sets a sprite to the object
		* this either creates a movieclip or a bitmap
		*/
		public function SetGridObjectSprite(go:CellGridObject):Sprite {
			if (go.m_sprite) {
				// empty
				while(go.m_sprite.numChildren) {
					go.m_sprite.removeChild(go.m_sprite.getChildAt(0));
				}
				go.m_sprite.x = 0;
				go.m_sprite.y = 0;
				go.m_sprite.scaleX = 1.0;
				go.m_sprite.scaleY = 1.0;
				
			} else {
				go.m_sprite = new Sprite();
			}
			
			if (go.m_isDrawn) {
				var sprite:Sprite = new Sprite();
				sprite.graphics.clear();
				sprite.graphics.beginFill( uint(Math.random()*0x666666 + 0x666666) );
				sprite.graphics.drawCircle(0, 0, go.m_radius);
				sprite.graphics.endFill();
				
				go.m_display = DisplayObject(sprite);
			} else if (go.m_isBitmapCached) {
				go.m_display = DisplayObject( NewCellMovieClip(go.m_libraryName) );
			} else {
				go.m_display = DisplayObject( new (getDefinitionByName(go.m_libraryName))() );
			}
			
			go.m_sprite.addChild(go.m_display);
			go.m_sprite.scaleX = go.m_radius*2/go.m_display.width;
			go.m_sprite.scaleY = go.m_radius*2/go.m_display.height;
			
			return go.m_sprite;
		}
		
		/* NewCachedBitmap
		* grabs a bitmapdataset if it exists, if not then it creates one
		*/
		private function NewCachedBitmap(name:String):CellCachedBitmapData {
			if (!m_bitmapCachedLibrary[name]) {
				var mc:MovieClip = new (getDefinitionByName(name))()
				m_bitmapCachedLibrary[name] = new CellCachedBitmapData(mc);
				m_numBitmaps++;
			}
			
			return m_bitmapCachedLibrary[name];
			
		}
		
		/* NewCellMovieClip
		* grabs a cellmovieclip if it exists, if not then it creates one
		* this is just a cell for the cachedbitmap frames
		*/
		private function NewCellMovieClip(name:String):CellMovieClip {
			var cachedBitmap:CellCachedBitmapData = NewCachedBitmap(name);
			
			if (m_movieClipStack.length) {
				var mc:CellMovieClip = m_movieClipStack.pop();
				mc.Reset(cachedBitmap.GetSourceRectangle(), cachedBitmap.GetFrames());
			} else {
				mc = cachedBitmap.CreateNewMovieClipCached();
			}
			
			return mc;
		}
		
		/* RemoveCellMovieClip
		* removes a cell movie clip after use (puts it on the stack for further use)
		*/
		private function RemoveCellMovieClip(mc:CellMovieClip):void {
			m_movieClipStack.push(mc);
		}
		
		/* FlushMovieClips
		* flushes the movieclip stack
		*/
		public function FlushMovieClips():void {
			while (m_movieClipStack.length) {
				m_movieClipStack.pop();
			}
		}
		
		/* ReleaseGridObjectSprite
		* releases the grid object sprite.
		* this removes any movie clips and any other stuff that is attached to the sprite
		*/
		public function ReleaseGridObjectSprite(go:CellGridObject):void {
			if (go.m_sprite) {
				
				if (go.m_display) {
					
					go.m_sprite.removeChild(go.m_display);
					
					if (!go.m_isDrawn && go.m_isBitmapCached) {
						RemoveCellMovieClip( CellMovieClip(go.m_display) );
					}
					
					go.m_display = null;
				}
				
				while(go.m_sprite.numChildren) {
					go.m_sprite.removeChild(go.m_sprite.getChildAt(0));
				}
			}
		}
		
		/* IsGridObjectSetSprite
		* returns true if the object has a sprite
		*/
		public function IsGridObjectSetSprite(go:CellGridObject):Boolean {
			return (go.m_display != null);
		}
		
		/* UpdatePerformanceStatistics
		*/
		public function UpdatePerformanceStatistics(pStats:CellPerformanceStatistics):CellPerformanceStatistics {
			pStats.m_numBitmapLibraryEntries = m_numBitmaps;
			pStats.m_numMovieClips = m_movieClipStack.length;
			
			return pStats;
		}
		
	}
}