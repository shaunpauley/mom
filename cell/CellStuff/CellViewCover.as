package CellStuff {
	
	import flash.display.Sprite;
	
	import flash.geom.Point;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	public class CellViewCover extends CellGridCover {
		
		private var m_viewer:CellGridViewer;
		
		private var m_stockTiles:Array;
		
		private var m_dv:Point;
		
		// stats
		
		private var m_numTiles:int;
		private var m_numGridObjects:int;
		
		// consts
		
		public static const c_defaultWidth:Number = 550;
		public static const c_defaultHeight:Number = 550;
		
		/* Constructor
		*/
		public function CellViewCover(viewCoverData:Object):void {
			m_stockTiles = new Array();
			
			m_viewer = viewCoverData.viewer;
			
			m_numTiles = 0;
			m_numGridObjects = 0;
			
			m_dv = new Point(0, 0);
			
			super(viewCoverData);
			
		}
		
		/* CreateCoverCell
		* overrided to include grabbing an existing sprite tile from the stock if needed,
		* and adding it to the view display
		*/
		protected override function CreateCoverCell(gridCell:Object, 
		top:Object = null,
		bottom:Object = null,
		left:Object = null,
		right:Object = null):Object {
			
			var cellCover:Object = super.CreateCoverCell(gridCell, top, bottom, left, right);
			cellCover.cover = this;
			
			gridCell.viewCell = cellCover;
			
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
			
			cellCover.gridTile = gridTile;
			cellCover.objectTile = objectTile;
			cellCover.x = X;
			cellCover.y = Y;
			
			cellCover.gridTile.x = cellCover.x;
			cellCover.gridTile.y = cellCover.y;
			cellCover.objectTile.x = cellCover.x;
			cellCover.objectTile.y = cellCover.y;
			
			for each (var go:CellGridObject in gridCell.objects) {
				RegisterGridObject(cellCover, go);
			}
			
			if (CellWorld.c_debug) {
				DrawCellBorder(cellCover);
			}
			
			m_viewer.AddGridTile(cellCover.gridTile);
			m_viewer.AddObjectTile(cellCover.objectTile);
			
			m_numTiles++;
			
			return cellCover;
		}
		
		/* RegisterGridObject
		* registers a coverCell with a grid object.
		* this places the grid object on the tile if not already registered, but also
		* places coverCells on the stack so that the gridObject stays visible when it should
		*/
		public function RegisterGridObject(coverCell:Object, go:CellGridObject):void {
			if (!go.m_registered) {
				
				go.m_registered = coverCell;
				
				go.m_sprite = BuildSpriteForGridObject(go);
				
				UpdateGridObject(go);
				
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
		public function UnregisterGridObject(coverCell:Object, go:CellGridObject):void {
			if (go.m_registered == coverCell) {
				go.m_registered.objectTile.removeChild( go.m_sprite );
				go.m_registered = null;
				
				m_numGridObjects--;
				
				if (go.m_registeredStack.length) {
					RegisterGridObject(go.m_registeredStack.pop(), go);
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
			if (go.m_registered) {
				go.m_dv = m_cellGrid.CalculateDistanceVector_CellToLocal(go.m_dv, go.m_registered.cell, go.m_localPoint, go.m_col, go.m_row);
				
				go.m_sprite.x = -go.m_dv.x;
				go.m_sprite.y = -go.m_dv.y;
			}
		}
		
		/* BuildSpriteForGridObject
		* Makes a sprite for our grid object
		*/
		private function BuildSpriteForGridObject(go:CellGridObject):Sprite {
			if (!go.m_sprite) {
				go.m_sprite = new Sprite();
				
				go.m_sprite.graphics.clear();
				go.m_sprite.graphics.lineStyle(1.5, 0xFF6699);
				go.m_sprite.graphics.beginFill(0xCC3366);
				go.m_sprite.graphics.drawCircle(0, 0, go.m_radius);
				go.m_sprite.graphics.endFill();
			}
			
			return go.m_sprite;
		}
		
		/* RemoveCoverCell
		* removes a sprite tile and everything attached to the sprite.
		* places the sprite tile on the stock in case we need it immediately
		*/
		protected override function RemoveCoverCell(coverCell:Object):void {
			super.RemoveCoverCell(coverCell);
			
			coverCell.cell.viewCell = null;
			
			for each (var go:CellGridObject in coverCell.cell.objects) {
				UnregisterGridObject(coverCell, go);
			}
			
			coverCell.gridTile.graphics.clear();
			while(coverCell.gridTile.numChildren) {
				coverCell.gridTile.removeChild(coverCell.gridTile.getChildAt(0));
			}
			
			coverCell.objectTile.graphics.clear();
			while(coverCell.gridTile.numChildren) {
				coverCell.gridTile.removeChild(coverCell.gridTile.getChildAt(0));
			}
			
			m_viewer.RemoveGridTile(coverCell.gridTile);
			m_viewer.RemoveObjectTile(coverCell.objectTile);
			
			m_stockTiles.push(coverCell.gridTile);
			m_stockTiles.push(coverCell.objectTile);
			
			m_numTiles--;
		}
		
		/* GrowViewer
		* grows the viewer and adds new cells if necessary
		*/
		public override function GrowCover(widthAmount:Number, heightAmount:Number):void {
			super.GrowCover(widthAmount, heightAmount);
			
			if (CellWorld.c_debug) {
				Draw(m_viewer.TopLayer());
			}
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
			
			cell.gridTile.graphics.lineStyle(1, randomColorDark);
			cell.gridTile.graphics.beginFill(randomColorLight);
			cell.gridTile.graphics.moveTo(0, 0);
			cell.gridTile.graphics.lineTo(m_cellWidth, 0);
			cell.gridTile.graphics.lineTo(m_cellWidth, m_cellHeight);
			cell.gridTile.graphics.lineTo(0, m_cellHeight);
			cell.gridTile.graphics.lineTo(0, 0);
			cell.gridTile.graphics.endFill();
			
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