package CellStuff {
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	
	import flash.geom.Point;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	public class CellViewCover extends CellGridCover {
		
		private var m_viewer:CellGridViewer;
		
		private var m_stockTiles:Array;
		
		private var m_dv:Point;
		
		private var m_bitmapManager:CellBitmapManager;
		
		// stats
		
		private var m_numTiles:int;
		private var m_numGridObjects:int;
		
		// consts
		
		public static const c_defaultWidth:Number = 550;
		public static const c_defaultHeight:Number = 550;
		
		/* Constructor
		*/
		public function CellViewCover(cellGrid:CellGridLocations, viewCoverData:Object, bitmapManager:CellBitmapManager):void {
			m_stockTiles = new Array();
			
			m_viewer = viewCoverData.viewer;
			
			m_numTiles = 0;
			m_numGridObjects = 0;
			
			m_dv = new Point(0, 0);
			
			m_bitmapManager = bitmapManager;
			
			super(cellGrid, viewCoverData);
			
		}
		
		/* GenerateCoverCell
		* overrided to include grabbing an existing sprite tile from the stock if needed,
		* and adding it to the view display
		*/
		protected override function GenerateCoverCell(coverCell:Object,
		gridCell:Object, 
		top:Object = null,
		bottom:Object = null,
		left:Object = null,
		right:Object = null):Object {
			
			var X:Number = 0;
			var Y:Number = 0;
			
			if (top) {
				X = top.x;
				Y = top.y + m_cellHeight;
			} else if (bottom) {
				X = bottom.x;
				Y = bottom.y - m_cellHeight;
			} else if (left) {
				X = left.x + m_cellWidth;
				Y = left.y;
			} else if (right) {
				X = right.x - m_cellWidth;
				Y = right.y;
			} else {
				X = -m_width/2 - m_startOffset.x;
				Y = -m_height/2 - m_startOffset.y;
			}
			
			if (m_stockTiles.length) {
				var gridTile:Sprite = m_stockTiles.pop();
			} else {
				gridTile = new Sprite();
			}
			
			if (m_stockTiles.length) {
				var objectTile:Sprite = m_stockTiles.pop();
			} else {
				objectTile = new Sprite();
			}
			
			if (m_stockTiles.length) {
				var topTile:Sprite = m_stockTiles.pop();
			} else {
				topTile = new Sprite();
			}
			
			coverCell.gridTile = gridTile;
			coverCell.objectTile = objectTile;
			coverCell.topTile = topTile;
			coverCell.x = X;
			coverCell.y = Y;
			
			coverCell.gridTile.x = coverCell.x;
			coverCell.gridTile.y = coverCell.y;
			coverCell.objectTile.x = coverCell.x;
			coverCell.objectTile.y = coverCell.y;
			coverCell.topTile.x = coverCell.x;
			coverCell.topTile.y = coverCell.y;
			
			DrawCellBorder(coverCell);
			
			m_viewer.AddGridTile(coverCell.gridTile);
			m_viewer.AddObjectTile(coverCell.objectTile);
			m_viewer.AddTopTile(coverCell.topTile);
			
			coverCell.cover = this;
			
			coverCell = super.GenerateCoverCell(coverCell, gridCell, top, bottom, left, right);
			
			
			m_numTiles++;
			
			return coverCell;
		}
		
		/* GridObjectEnter
		* adds the grid object to the set
		*/
		public override function GridObjectEnter(coverCell:Object, go:CellGridObject):void {
			RegisterGridObject(coverCell, go);
		}
		
		/* GridObjectLeave
		* removes the grid object from the set
		*/
		public override function GridObjectLeave(coverCell:Object, go:CellGridObject):void {
			UnregisterGridObject(coverCell, go);
		}
		
		
		/* RegisterGridObject
		* registers a coverCell with a grid object.
		* this places the grid object on the tile if not already registered, but also
		* places coverCells on the stack so that the gridObject stays visible when it should
		*/
		private function RegisterGridObject(coverCell:Object, go:CellGridObject):void {
			if (!go.m_registered) {
				
				go.m_registered = coverCell;
				
				if ( !m_bitmapManager.IsGridObjectSetSprite(go) ) {
					go.m_sprite = m_bitmapManager.SetGridObjectSprite(go);
				}
				
				for each (var goAbsorbed:CellGridObject in go.m_absorbedList) {
					if ( !m_bitmapManager.IsGridObjectSetSprite(goAbsorbed) ) {
						goAbsorbed.m_sprite = m_bitmapManager.SetGridObjectSprite(goAbsorbed);
					}
				}
				
				UpdateGridObject(go);
				
				for each (goAbsorbed in go.m_absorbedList) {
					go.m_sprite.addChild( goAbsorbed.m_sprite );
				}
				
				coverCell.objectTile.addChild( go.m_sprite );
				
				
				m_numGridObjects++;
				
			} else {
				go.m_registeredStack.push(coverCell);
			}
		}
		
		/* UnregisterCoverCell
		* removes the grid object from the tile, but also adds to another existing tile if needed.
		* this helps with keeping grid objects in view
		*/
		private function UnregisterGridObject(coverCell:Object, go:CellGridObject, removeAbsorbed:Boolean = true):void {
			if (go.m_registered == coverCell) {
				
				if (removeAbsorbed) {
					for each (var goAbsorbed:CellGridObject in go.m_absorbedList) {
						go.m_sprite.removeChild( goAbsorbed.m_sprite );
					}
				}
				
				go.m_registered.objectTile.removeChild( go.m_sprite );
				go.m_registered = null;
				
				m_numGridObjects--;
				
				if (go.m_registeredStack.length) {
					RegisterGridObject(go.m_registeredStack.pop(), go);
				} else {
					m_bitmapManager.ReleaseGridObjectSprite(go);
				}
			} else {
				var i:int = go.m_registeredStack.indexOf(coverCell);
				go.m_registeredStack.splice(i, 1);
			}
		}
		
		/* UpdateGridObject
		* updates the sprite and possibly other things about the grid object
		*/
		public function UpdateGridObject(go:CellGridObject):void {
			go.m_dv = m_cellGrid.CalculateDistanceVector_CellToLocal(go.m_dv, go.m_registered.cell, go.m_localPoint, go.m_col, go.m_row);
			
			go.m_sprite.x = -go.m_dv.x;
			go.m_sprite.y = -go.m_dv.y;
			
			for each (var goAbsorbed:CellGridObject in go.m_absorbedList) {
				goAbsorbed.m_dv = m_cellGrid.CalculateDistanceVector_GridObjects(goAbsorbed.m_dv, go, goAbsorbed);
				
				goAbsorbed.m_sprite.x = goAbsorbed.m_dv.x;
				goAbsorbed.m_sprite.y = goAbsorbed.m_dv.y;
			}
		}
		
		/* RedrawGridObject
		* redraws the grid object
		*/
		public function RedrawGridObject(go:CellGridObject):void {
			var coverCell:Object = go.m_registered;
			UnregisterGridObject(coverCell, go, false);
			RegisterGridObject(coverCell, go);
		}
		
		/* RemoveCoverCell
		* removes a sprite tile and everything attached to the sprite.
		* places the sprite tile on the stock in case we need it immediately
		*/
		protected override function RemoveCoverCell(coverCell:Object):void {
			super.RemoveCoverCell(coverCell);
			
			coverCell.gridTile.graphics.clear();
			while(coverCell.gridTile.numChildren) {
				coverCell.gridTile.removeChild(coverCell.gridTile.getChildAt(0));
			}
			
			coverCell.objectTile.graphics.clear();
			while(coverCell.objectTile.numChildren) {
				coverCell.objectTile.removeChild(coverCell.objectTile.getChildAt(0));
			}
			
			coverCell.topTile.graphics.clear();
			while(coverCell.topTile.numChildren) {
				coverCell.topTile.removeChild(coverCell.topTile.getChildAt(0));
			}
			
			m_viewer.RemoveGridTile(coverCell.gridTile);
			m_viewer.RemoveObjectTile(coverCell.objectTile);
			m_viewer.RemoveTopTile(coverCell.topTile);
			
			m_stockTiles.push(coverCell.gridTile);
			m_stockTiles.push(coverCell.objectTile);
			m_stockTiles.push(coverCell.topTile);
			
			coverCell.gridTile = null;
			coverCell.objectTile = null;
			coverCell.topTile = null;
			
			m_numTiles--;
		}
		
		/* GrowViewer
		* grows the viewer and adds new cells if necessary
		*/
		public override function GrowCover(widthAmount:Number, heightAmount:Number):void {
			super.GrowCover(widthAmount, heightAmount);
			
			Draw(m_viewer.TopLayer());
		}
		
		/* ShiftCells
		* shifts all the cells by X and Y pixels
		*/
		private function ShiftCells(dx:Number, dy:Number):void {
			var currentRowCell:Object = m_topLeft;
			
			while(currentRowCell) {
				var currentCell:Object = currentRowCell;
				while(currentCell) {
					currentCell.x += dx;
					currentCell.y += dy;
					
					currentCell.gridTile.x = currentCell.x;
					currentCell.gridTile.y = currentCell.y;
					currentCell.objectTile.x = currentCell.x;
					currentCell.objectTile.y = currentCell.y;
					
					currentCell = currentCell.right;
				}
				currentRowCell = currentRowCell.bottom;
			}
		}
		
		/* MoveCover
		* moves the cells under the cover and maintains the view cover
		*/
		public override function MoveCover(dx:Number, dy:Number):void {
			ShiftCells(-dx, -dy);
			
			super.MoveCover(dx, dy);
		}
		
		/* GetDistanceToGridObject
		* returns the distance from the center of the cover to the grid object
		*/
		public function GetDistanceToGridObject(go:CellGridObject):Point {
			return m_cellGrid.CalculateDistancVector_WorldToGridObject(m_dv, m_worldCenter, go);
		}
		
		/* GetViewerWidth
		* returns te view cover's width
		*/
		public function GetWidth():Number {
			return m_width;
		}
		
		/* GetViewerHeight
		* returns te view cover's height
		*/
		public function GetHeight():Number {
			return m_height;
		}
		
		/* UpdatePerformanceStatistics
		*/
		public function UpdatePerformanceStatistics(pStats:CellPerformanceStatistics):CellPerformanceStatistics {
			pStats.m_numStockTiles = m_stockTiles.length;
			pStats.m_numViewTiles = m_numTiles;
			pStats.m_numViewGridObjects = m_numGridObjects;
			
			return pStats;
		}
		
		/* DrawCellBorder
		* used if we need to draw the cell border, used in debug
		*/
		private function DrawCellBorder(cell:Object):void {
			cell.gridTile.graphics.clear();
			
			var randomColorDark:uint = uint(Math.random()*0x666666);
			var randomColorLight:uint = uint(Math.random()*0x666666 + 0x999999);
			//cell.gridTile.graphics.lineStyle(0, randomColorDark);
			cell.gridTile.graphics.beginFill(randomColorLight);
			cell.gridTile.graphics.moveTo(0, 0);
			cell.gridTile.graphics.lineTo(m_cellWidth, 0);
			cell.gridTile.graphics.lineTo(m_cellWidth, m_cellHeight);
			cell.gridTile.graphics.lineTo(0, m_cellHeight);
			cell.gridTile.graphics.lineTo(0, 0);
			cell.gridTile.graphics.endFill();
			
			/*
			var tf:TextField = new TextField();
			tf.x = 0;
			tf.y = 0;
			tf.autoSize = TextFieldAutoSize.LEFT;
			var format:TextFormat = new TextFormat();
			format.font = "Courier New";
			format.color = randomColorDark;
			format.size = 10;
			tf.defaultTextFormat = format;
			tf.selectable = false;
			tf.text = String(cell.cell.id);
			cell.gridTile.addChild(tf);
			*/
		}
		
		/* CreateCellViewDataObject
		*/
		public static function UpdateCellViewCoverDataFull(coverData:Object, viewer:CellGridViewer):Object {
			coverData.viewer = viewer;
			return coverData;
		}
		
		public static function CreateViewCoverData(cellGrid:CellGridLocations):Object {
			
			var start:Point = new Point(cellGrid.GetGridWidth()/2 - c_defaultWidth/2, cellGrid.GetGridHeight()/2 - c_defaultHeight/2);
			var col:int = cellGrid.GetColFromWorld(start);
			var row:int = cellGrid.GetRowFromWorld(start);
			
			start = cellGrid.WorldToLocal(start, col, row);
			
			var coverData:Object = CellGridCover.CreateGridCoverDataFull(cellGrid, start, col, row, c_defaultWidth, c_defaultHeight);
			
			return UpdateCellViewCoverDataFull(coverData, null);
		}
		
		
	}
}