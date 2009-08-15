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
		private var m_numIssuedMovieClips:int;
		
		/* Constructor
		*/
		public function CellBitmapManager():void {
			m_bitmapCachedLibrary = new Dictionary();
			
			m_movieClipStack = new Array();
			
			m_numBitmaps = 0;
			m_numIssuedMovieClips = 0;
			
		}
		
		public function SetCoverCellSprite(coverCell:Object):void {
			var mc:CellMovieClip = NewCellMovieClip(coverCell.cell.libraryName, 1);
			
			coverCell.gridTile.scaleX = coverCell.cover.GetCellWidth()/mc.width;
			coverCell.gridTile.scaleY = coverCell.cover.GetCellHeight()/mc.height;
			
			mc.smoothing = true;
			coverCell.gridTile.addChild(mc);
			coverCell.mc = mc;
		}
		
		/* SetGridObjectSprite
		* sets a sprite to the object
		* this either creates a movieclip or a bitmap
		*/
		public function SetGridObjectSprite(go:CellGridObject):Sprite {
			if (go.m_sprite) {
				// empty
				if (go.m_sprite.numChildren) {
					throw ( new Error("go already has sprite for gridobject: " + go.m_radius) );
				}
			} else {
				go.m_sprite = new Sprite();
			}
			
			if (go.m_isDrawn) {
				var sprite:Sprite = new Sprite();
				sprite.graphics.clear();
				sprite.graphics.beginFill( go.m_color );
				sprite.graphics.drawCircle(0, 0, go.m_radius);
				sprite.graphics.endFill();
				
				go.m_display = DisplayObject(sprite);
			} else if (go.m_isBitmapCached) {
				go.m_display = DisplayObject( NewCellMovieClip(go.m_libraryName, go.m_frame) );
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
		private function NewCellMovieClip(name:String, frame:int):CellMovieClip {
			var cachedBitmap:CellCachedBitmapData = NewCachedBitmap(name);
			
			if (m_movieClipStack.length) {
				var mc:CellMovieClip = m_movieClipStack.pop();
				mc.Reset(cachedBitmap.GetSourceRectangle(), cachedBitmap.GetFrames());
				mc.gotoAndPlay(frame);
			} else {
				mc = cachedBitmap.CreateNewMovieClipCached();
				mc.gotoAndPlay(frame);
			}
			
			m_numIssuedMovieClips++;
			
			return mc;
		}
		
		/* RemoveCellMovieClip
		* removes a cell movie clip after use (puts it on the stack for further use)
		*/
		private function RemoveCellMovieClip(mc:CellMovieClip):void {
			mc.stop();
			m_movieClipStack.push(mc);
			m_numIssuedMovieClips--;
		}
		
		/* FlushMovieClips
		* flushes the movieclip stack
		*/
		public function FlushMovieClips():void {
			while (m_movieClipStack.length) {
				m_movieClipStack.pop();
			}
		}
		
		/* ReleaseCoverCellSprite
		* releases the cover cell sprite
		*/
		public function ReleaseCoverCellSprite(coverCell:Object):void {
			coverCell.gridTile.removeChild(coverCell.mc);
			RemoveCellMovieClip(coverCell.mc);
			delete coverCell.mc;
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
						var mc:CellMovieClip = CellMovieClip(go.m_display);
						go.m_frame = mc.currentFrame;
						RemoveCellMovieClip( mc );
					}
					
					go.m_display = null;
				}
				
				if (go.m_sprite.numChildren) {
					throw ( new Error("go already has sprite for gridobject: " + go.m_radius) );
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
			pStats.m_numMovieClipsIssues = m_numIssuedMovieClips;
			
			return pStats;
		}
		
	}
}