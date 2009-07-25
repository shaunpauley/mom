package CellStuff {
	
	import flash.display.Sprite;
	
	import flash.geom.Point;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	public class CellViewCover extends CellGridCover {
		
		private var m_viewer:CellGridViewer;
		
		private var m_stockTiles:Array;
		
		// consts
		
		public static const c_defaultWidth:Number = 550;
		public static const c_defaultHeight:Number = 550;
		
		/* Constructor
		*/
		public function CellViewCover(viewCoverData:Object):void {
			m_stockTiles = new Array();
			
			m_viewer = viewCoverData.viewer;
			
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
			
			if (m_stockTiles.length) {
				var tile:Sprite = m_stockTiles.pop();
			} else {
				tile = new Sprite();
			}
			
			var cell:Object = super.CreateCoverCell(gridCell, top, bottom, left, right);
			
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
			
			cell.sprite = tile;
			cell.x = X;
			cell.y = Y;
			
			cell.sprite.x = cell.x;
			cell.sprite.y = cell.y;
			
			if (CellWorld.c_debug) {
				DrawCellBorder(cell);
			}
			
			m_viewer.addChild(cell.sprite);
			
			return cell;
		}
		
		/* RemoveCoverCell
		* removes a sprite tile and everything attached to the sprite.
		* places the sprite tile on the stock in case we need it immediately
		*/
		protected override function RemoveCoverCell(coverCell:Object):void {
			super.RemoveCoverCell(coverCell);
			
			coverCell.sprite.graphics.clear();
			while(coverCell.sprite.numChildren) {
				coverCell.sprite.removeChild(coverCell.sprite.getChildAt(0));
			}
			m_viewer.removeChild(coverCell.sprite);
			
			m_stockTiles.push(coverCell.sprite);
		}
		
		/* GrowViewer
		* grows the viewer and adds new s if necessary
		*/
		public override function GrowCover(widthAmount:Number, heightAmount:Number):void {
			super.GrowCover(widthAmount, heightAmount);
			
			if (CellWorld.c_debug) {
				Draw(m_viewer);
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
					
					currentCell.sprite.x = currentCell.x;
					currentCell.sprite.y = currentCell.y;
					
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
		
		/* DrawCellBorder
		* used if we need to draw the cell border, used in debug
		*/
		private function DrawCellBorder(cell:Object):void {
			cell.sprite.graphics.clear();
			
			var randomColor:uint = uint(Math.random()*0xFFFFFF);
			
			cell.sprite.graphics.lineStyle(1, randomColor);
			cell.sprite.graphics.moveTo(0, 0);
			cell.sprite.graphics.lineTo(m_cellWidth, 0);
			cell.sprite.graphics.lineTo(m_cellWidth, m_cellHeight);
			cell.sprite.graphics.lineTo(0, m_cellHeight);
			cell.sprite.graphics.lineTo(0, 0);
			
			var tf:TextField = new TextField();
			tf.x = 0;
			tf.y = 0;
			tf.autoSize = TextFieldAutoSize.LEFT;
			var format:TextFormat = new TextFormat();
			format.font = "Courier New";
			format.color = randomColor;
			format.size = 10;
			tf.defaultTextFormat = format;
			tf.selectable = false;
			tf.text = String(cell.cell.id);
			
			cell.sprite.addChild(tf);
		}
		
		/* CreateCellViewDataObject
		*/
		public static function UpdateCellViewCoverDataFull(coverData:Object, viewer:CellGridViewer):Object {
			coverData.viewer = viewer;
			return coverData;
		}
		
		public static function CreateViewCoverData():Object {
			var cellGrid:CellGridLocations = new CellGridLocations( CellGridLocations.CreateGridLocationsData() );
			
			var start:Point = new Point(cellGrid.GetGridWidth()/2 - c_defaultWidth/2, cellGrid.GetGridHeight()/2 - c_defaultHeight/2);
			var col:int = cellGrid.GetColFromWorld(start);
			var row:int = cellGrid.GetRowFromWorld(start);
			
			start = cellGrid.WorldToLocal(start, col, row);
			
			var coverData:Object = CellGridCover.CreateGridCoverDataFull(cellGrid, start, col, row, c_defaultWidth, c_defaultHeight);
			
			return UpdateCellViewCoverDataFull(coverData, null);
		}
		
		
	}
}