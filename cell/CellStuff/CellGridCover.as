package CellStuff {
	
	import flash.display.Sprite;
	
	import flash.geom.Point;
	
	public class CellGridCover {
		
		private var m_cellGrid:CellGridLocations;
		
		protected var m_startOffset:Point;
		private var m_endOffset:Point;
		
		protected var m_width:Number;
		protected var m_height:Number;
		
		protected var m_cellWidth:Number;
		protected var m_cellHeight:Number;
		
		protected var m_topLeft:Object;
		private var m_topRight:Object;
		private var m_bottomLeft:Object;
		private var m_bottomRight:Object;
		
		/* Constructor
		*/
		public function CellGridCover(coverData:Object):void {
			
			m_cellGrid = coverData.cellGrid;
			
			m_startOffset = coverData.startLocal;
			m_endOffset = m_startOffset.clone();
			
			m_width = coverData.width;
			m_height = coverData.height;
			
			m_cellWidth = m_cellGrid.GetCellWidth();
			m_cellHeight = m_cellGrid.GetCellHeight();
			
			var gridCell:Object = m_cellGrid.GetGridCell(coverData.startCol, coverData.startRow);
			CoverInit(gridCell);
		}
		
		/* CoverInit
		* quickly creates the cover by growing cells to the right and then growing the row down
		*/
		private function CoverInit(gridCell:Object):void {
			m_topLeft = CreateCoverCell(gridCell);
			m_topRight = m_topLeft;
			m_bottomLeft = m_topLeft;
			m_bottomRight = m_topLeft;
			
			var current:Object = m_topLeft;
			m_endOffset.x = m_startOffset.x + m_width;
			while(m_endOffset.x > m_cellWidth) {
				current = CreateCoverCell(current.cell.right, null, null, current);
				m_endOffset.x -= m_cellWidth;
				m_topRight = m_topRight.right;
				m_bottomRight = m_topRight;
			}
			
			m_endOffset.y = m_startOffset.y + m_height;
			while (m_endOffset.y > m_cellHeight) {
				AddRow(m_bottomLeft, false);
				m_bottomLeft = m_bottomLeft.bottom;
				m_bottomRight = m_bottomRight.bottom;
				m_endOffset.y -= m_cellHeight;
			}
		}
		
		/* CreateCoverCell
		* creates a linked cover cell
		*/
		protected function CreateCoverCell(gridCell:Object, 
		top:Object = null,
		bottom:Object = null,
		left:Object = null,
		right:Object = null):Object {
			
			var coverCell:Object = {cell:gridCell, top:top, bottom:bottom, left:left, right:right};
			
			if (top) {
				top.bottom = coverCell;
			}
			if (bottom) {
				bottom.top = coverCell;
			}
			if (left) {
				left.right = coverCell;
			}
			if (right) {
				right.left = coverCell;
			}
			
			return coverCell;
		}
		
		/* AddColumn
		* add a column starting at current and to the left if not specified
		*/
		private function AddColumn(current:Object, isLeft:Boolean = true):void {
			var previous:Object = null;
			
			while (current) {
				
				if (isLeft) {
					current.left = CreateCoverCell(current.cell.left, previous, null, null, current);
					previous = current.left;
				} else {
					current.right = CreateCoverCell(current.cell.right, previous, null, current);
					previous = current.right;
				}
				
				current = current.bottom;
			}
			
		}
		
		/* AddRow
		* adds a row starting at the current and to the top if not specified
		*/
		private function AddRow(current:Object, isTop:Boolean = true):void {
			var previous:Object = null;
			
			while (current) {
				
				if (isTop) {
					current.top = CreateCoverCell(current.cell.top, null, current, previous);
					previous = current.top;
				} else {
					current.bottom = CreateCoverCell(current.cell.bottom, current, null, previous);
					previous = current.bottom;
				}					
				
				current = current.right;
			}
		}
		
		/* RemoveColumn
		* remove a column, moving down
		*/
		private function RemoveColumn(current:Object):void {
			while(current) {
				var next:Object = current.bottom;
				RemoveCoverCell(current);
				current = next;
			}
		}
		
		/* RemoveRow
		* removes a row, moving right
		*/
		private function RemoveRow(current:Object):void {
			while(current) {
				var next:Object = current.right;
				RemoveCoverCell(current);
				current = next;
			}
		}
		
		/* MoveStartOffset
		* moves our start offset and determines what to add or remove from the edges of the cover.
		* This is ultimately used to grow, shrink, and shift the cover
		*/
		private function MoveStartOffset(dx:Number, dy:Number):void {
			m_startOffset.x += dx;
			while (m_startOffset.x < 0) {
				AddColumn(m_topLeft);
				m_topLeft = m_topLeft.left;
				m_bottomLeft = m_bottomLeft.left;
				m_startOffset.x += m_cellWidth;
				
			}
			while (m_startOffset.x > m_cellWidth) {
				if (!m_topLeft.right || !m_bottomLeft.right) {
					break;
				}
				var temp1:Object = m_topLeft.right;
				var temp2:Object = m_bottomLeft.right;
				RemoveColumn(m_topLeft);
				m_topLeft = temp1;
				m_bottomLeft = temp2;
				m_startOffset.x -= m_cellWidth;
			}
			
			m_startOffset.y += dy;
			while (m_startOffset.y < 0) {
				AddRow(m_topLeft);
				m_topLeft = m_topLeft.top;
				m_topRight = m_topRight.top;
				m_startOffset.y += m_cellHeight;
				
			}
			while (m_startOffset.y > m_cellHeight) {
				if (!m_topRight.bottom || !m_topLeft.bottom) {
					break;
				}
				temp1 = m_topRight.bottom;
				temp2 = m_topLeft.bottom;
				RemoveRow(m_topLeft);
				m_topRight = temp1;
				m_topLeft = temp2;
				m_startOffset.y -= m_cellHeight;
			}
			
		}
		
		/* MoveEndOffset
		* moving the end offset can grow, shrink, or shift the cover
		*/
		private function MoveEndOffset(dx:Number, dy:Number):void {
			m_endOffset.x += dx;
			while (m_endOffset.x > m_cellWidth) {
				AddColumn(m_topRight, false);
				m_topRight = m_topRight.right;
				m_bottomRight = m_bottomRight.right;
				m_endOffset.x -= m_cellWidth;
				
			}
			while (m_endOffset.x < 0) {
				if (!m_topRight.left || !m_bottomRight.left) {
					break;
				}
				var temp1:Object = m_topRight.left;
				var temp2:Object = m_bottomRight.left;
				RemoveColumn(m_topRight);
				m_topRight = temp1;
				m_bottomRight = temp2;
				m_endOffset.x += m_cellWidth;
			}
			
			m_endOffset.y += dy;
			while (m_endOffset.y > m_cellHeight) {
				AddRow(m_bottomLeft, false);
				m_bottomLeft = m_bottomLeft.bottom;
				m_bottomRight = m_bottomRight.bottom;
				m_endOffset.y -= m_cellHeight;
				
			}
			while (m_endOffset.y < 0) {
				if (!m_bottomRight.top || !m_bottomLeft.top) {
					break;
				}
				temp1 = m_bottomRight.top;
				temp2 = m_bottomLeft.top;
				RemoveRow(m_bottomLeft);
				m_bottomRight = temp1;
				m_bottomLeft = temp2;
				m_endOffset.y += m_cellHeight;
			}
			
		}
		
		/* GrowViewer
		* grows the viewer and adds new s if necessary
		*/
		public function GrowCover(widthAmount:Number, heightAmount:Number):void {
			var widthAmountHalf:Number = widthAmount/2;
			var heightAmountHalf:Number = heightAmount/2;
			
			MoveStartOffset(-widthAmountHalf, -heightAmountHalf);
			MoveEndOffset(widthAmountHalf, heightAmountHalf);
			
			m_width += widthAmount;
			m_height += heightAmount;
			
		}
		
		/* ShrinkCover
		* shrinks the cover, and removes cells if needed.
		*/
		public function ShrinkCover(widthAmount:Number, heightAmount:Number):void {
			GrowCover(-widthAmount, -heightAmount);
		}
		
		/* MoveCover
		* moves the cells under the cover and maintains the cover
		*/
		public function MoveCover(dx:Number, dy:Number):void {
			MoveStartOffset(dx, dy);
			MoveEndOffset(dx, dy);
		}
		
		/* RemoveCoverCell
		* frees a grid cell and puts it into the stock so it can be flushed later.
		* (This is sort of a a way to control Garbage Collecting, and may be useful later)
		*/
		protected function RemoveCoverCell(coverCell:Object):void {
			if (coverCell.top) {
				coverCell.top.bottom = coverCell.bottom;
			}
			
			if (coverCell.bottom) {
				coverCell.bottom.top = coverCell.top;
			}
			
			if (coverCell.left) {
				coverCell.left.right = coverCell.right;
			}
			
			if (coverCell.right) {
				coverCell.right.left = coverCell.left;
			}
			
			coverCell.top = null;
			coverCell.bottom = null;
			coverCell.left = null;
			coverCell.right = null;
		}
		
		/* Draw
		* used if we need to draw the cell cover
		*/
		protected function Draw(sprite:Sprite):void {
			var startX:Number = m_topLeft.x + m_startOffset.x;
			var startY:Number = m_topLeft.y + m_startOffset.y;
			
			sprite.graphics.clear();
			sprite.graphics.lineStyle(2, 0xFFFFFF);
			sprite.graphics.moveTo(startX, startY);
			sprite.graphics.lineTo(startX + m_width, startY);
			sprite.graphics.lineTo(startX + m_width, startY + m_height);
			sprite.graphics.lineTo(startX, startY + m_height);
			sprite.graphics.lineTo(startX, startY);
			
		}
		
		// debug
		public function ToString():String {
			var str:String = "CellGridCover:\n";
			str += "\tso:" + m_startOffset.x + ", " + m_startOffset.y + "\n";
			str += "\teo:" + m_endOffset.x + ", " + m_endOffset.y + "\n";
			str += "\twh:" + m_width + ", " + m_height + "\n";
			str += "\ttopLeft: " + m_topLeft.cell.id + ": " + m_topLeft.x + ", " + m_topLeft.y + "\n";
			str += "\ttopRight: " + m_topRight.cell.id + ": " + m_topRight.x + ", " + m_topRight.y + "\n";
			str += "\tbottomLeft: " + m_bottomLeft.cell.id + ": " + m_bottomLeft.x + ", " + m_bottomLeft.y + "\n";
			str += "\tbottomRight: " + m_bottomRight.cell.id + ": " + m_bottomRight.x + ", " + m_bottomRight.y + "\n";
			str += "\ttiles:\n";
			
			var currentTile:Object = m_topLeft;
			while(currentTile) {
				var currentRowTile:Object = currentTile;
				while (currentRowTile) {
					str += "\t" + currentRowTile.cell.id;
					str += (currentRowTile.top?"T":"");
					str += (currentRowTile.bottom?"B":"");
					str += (currentRowTile.left?"L":"");
					str += (currentRowTile.right?"R":"");
					
					currentRowTile = currentRowTile.right;
					
				}
				str += "\n";
				currentTile = currentTile.bottom;
			}
			
			return str;
		}
		
		/* CreateGridCoverDataObject
		*/
		public static function CreateGridCoverDataFull(cellGrid:CellGridLocations, 
		startLocal:Point, 
		startCol:int, 
		startRow:int, 
		width:Number, 
		height:Number):Object {
			
			return {cellGrid:cellGrid,
			startLocal:startLocal,
			startCol:startCol,
			startRow:startRow,
			width:width,
			height:height};
		}
	}
	
}