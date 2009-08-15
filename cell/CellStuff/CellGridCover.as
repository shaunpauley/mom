package CellStuff {
	
	import flash.display.Sprite;
	
	import flash.geom.Point;
	
	import flash.utils.Dictionary;
	
	public class CellGridCover {
		
		protected var m_cellGrid:CellGridLocations;
		
		private var m_gridObject:CellGridObject;
		protected var m_gridObjectSet:Dictionary;
		private var m_gridObjectList:Array;
		protected var m_isGridObjectListChanged:Boolean;
		
		protected var m_startOffset:Point;
		private var m_endOffset:Point;
		
		protected var m_width:Number;
		protected var m_height:Number;
		
		protected var m_cellWidth:Number;
		protected var m_cellHeight:Number;
		
		protected var m_topLeft:Object;
		private var m_topRight:Object;
		private var m_bottomLeft:Object;
		protected var m_bottomRight:Object;
		
		protected var m_worldCenter:Point;
		
		/* Constructor
		*/
		public function CellGridCover(cellGrid:CellGridLocations, coverData:Object):void {
			m_cellGrid = cellGrid;
			
			m_gridObjectSet = new Dictionary(true);
			m_gridObjectList = new Array();
			
			m_worldCenter = new Point(0, 0);
			
			m_gridObject = null;
			
			ResetCover(coverData);
		}
		
		/* ResetCover
		* resets the cover so it can be remade
		*/
		public function ResetCover(coverData:Object):void {
			
			for each (var key:* in m_gridObjectSet) {
				delete m_gridObjectSet[key];
			}
			
			while(m_gridObjectList.length) {
				m_gridObjectList.pop();
			}
			
			m_isGridObjectListChanged = false;
			
			m_startOffset = coverData.startLocal;
			m_endOffset = m_startOffset.clone();
			
			m_width = coverData.width;
			m_height = coverData.height;
			
			m_cellWidth = m_cellGrid.GetCellWidth();
			m_cellHeight = m_cellGrid.GetCellHeight();
			
			var gridCell:Object = m_cellGrid.GetGridCell(coverData.startCol, coverData.startRow);
			
			CoverInit(gridCell);
			
			m_worldCenter.x = 0;
			m_worldCenter.y = 0;
			m_worldCenter = CalculateCenterWorld(m_worldCenter);
		}
		
		/* CoverInit
		* quickly creates the cover by growing cells to the right and then growing the row down
		*/
		private function CoverInit(gridCell:Object):void {
			m_topLeft = GenerateCoverCell(m_cellGrid.NewCoverCell(), gridCell);
			m_topRight = m_topLeft;
			m_bottomLeft = m_topLeft;
			m_bottomRight = m_topLeft;
			
			var current:Object = m_topLeft;
			m_endOffset.x = m_startOffset.x + m_width;
			while(m_endOffset.x > m_cellWidth) {
				current = GenerateCoverCell(m_cellGrid.NewCoverCell(), current.cell.right, null, null, current);
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
		
		/* GenerateCoverCell
		* generates a linked cover cell
		*/
		protected function GenerateCoverCell(coverCell:Object,
		gridCell:Object, 
		top:Object = null,
		bottom:Object = null,
		left:Object = null,
		right:Object = null):Object {
			
			if (!coverCell.cover) {
				coverCell.cover = this;
			}
			coverCell.cell = gridCell;
			coverCell.top = top;
			coverCell.bottom = bottom;
			coverCell.left = left;
			coverCell.right = right;
			
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
			
			// add cover and objects to the gridcell
			if (m_gridObject) {
				m_cellGrid.AddGridObjectAndCoverCell(gridCell, m_gridObject, coverCell);
			} else {
				m_cellGrid.AddCoverCell(gridCell, coverCell);
			}
			
			return coverCell;
		}
		
		/* AddColumn
		* add a column starting at current and to the left if not specified
		*/
		protected function AddColumn(current:Object, isLeft:Boolean = true):void {
			var previous:Object = null;
			
			while (current) {
				
				if (isLeft) {
					current.left = GenerateCoverCell(m_cellGrid.NewCoverCell(), current.cell.left, previous, null, null, current);
					previous = current.left;
				} else {
					current.right = GenerateCoverCell(m_cellGrid.NewCoverCell(), current.cell.right, previous, null, current);
					previous = current.right;
				}
				
				current = current.bottom;
			}
			
		}
		
		/* AddRow
		* adds a row starting at the current and to the top if not specified
		*/
		protected function AddRow(current:Object, isTop:Boolean = true):void {
			var previous:Object = null;
			
			while (current) {
				
				if (isTop) {
					current.top = GenerateCoverCell(m_cellGrid.NewCoverCell(), current.cell.top, null, current, previous);
					previous = current.top;
				} else {
					current.bottom = GenerateCoverCell(m_cellGrid.NewCoverCell(), current.cell.bottom, current, null, previous);
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
			while (m_startOffset.x >= m_cellWidth) {
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
			while (m_startOffset.y >= m_cellHeight) {
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
			while (m_endOffset.x >= m_cellWidth) {
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
			while (m_endOffset.y >= m_cellHeight) {
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
			
			m_worldCenter.x += dx;
			m_worldCenter.y += dy;
			m_worldCenter = m_cellGrid.CalculateWorld(m_worldCenter);
			
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
			
			// remove any objects and grid part of this cover
			if (m_gridObject) {
				m_cellGrid.RemoveGridObjectAndCoverCell(coverCell.cell, m_gridObject, coverCell);
			} else {
				m_cellGrid.RemoveCoverCell(coverCell.cell, coverCell);
			}
			
			coverCell.cell = null;
			coverCell.cover = null;
			
			m_cellGrid.StockCoverCell(coverCell);
		}
		
		/* SetGridObject
		* adds an object to each grid cell of the cover
		*/
		public function SetGridObject(go:CellGridObject):void {
			if (m_gridObject) {
				ReleaseGridObject();
			}
			
			m_gridObject = go;
			
			// loop through all the cells
			var currentRow:Object = m_topLeft;
			while (currentRow) {
				var current:Object = currentRow;
				while (current) {
					m_cellGrid.RemoveCoverCell(current.cell, current);
					m_cellGrid.AddGridObjectAndCoverCell(current.cell, m_gridObject, current);
					current = current.right;
				}
				currentRow = currentRow.bottom;
			}
		}
		
		/* ReleaseGridObject
		* removes an object from each grid cell of the cover
		*/
		public function ReleaseGridObject():void {
			// loop through all the cells
			var currentRow:Object = m_topLeft;
			while (currentRow) {
				var current:Object = currentRow;
				while (current) {
					m_cellGrid.RemoveGridObjectAndCoverCell(current.cell, m_gridObject, current);
					m_cellGrid.AddCoverCell(current.cell, current);
					current = current.right;
				}
				currentRow = currentRow.bottom;
			}
			
			m_gridObject = null;
		}
		
		/* GridObjectEnter
		* adds the grid object to the set
		*/
		public function GridObjectEnter(coverCell:Object, go:CellGridObject):void {
			if (m_gridObjectSet[go]) {
				m_gridObjectSet[go] += 1;
			} else {
				m_gridObjectSet[go] = int(1);
				m_isGridObjectListChanged = true;
			}
		}
		
		/* GridObjectLeave
		* removes the grid object from the set
		*/
		public function GridObjectLeave(coverCell:Object, go:CellGridObject):void {
			if (m_gridObjectSet[go]) {
				m_gridObjectSet[go] -= 1;
				if (m_gridObjectSet[go] <= 0) {
					delete m_gridObjectSet[go];
					m_isGridObjectListChanged = true;
				}
			}
		}
		
		/* GridObjects
		* returns the array of each grid object (not itself) under the cover
		*/
		public function GridObjects():Array {
			if (m_isGridObjectListChanged) {
				while (m_gridObjectList.length) {
					m_gridObjectList.pop();
				}
				for (var go:* in m_gridObjectSet) {
					m_gridObjectList.push(go);
				}
				m_isGridObjectListChanged = false;
			}
			
			return m_gridObjectList;
		}
		
		/* RemoveFromGrid
		* removes the entire cover and the grid object from the grid.
		*/
		public function RemoveFromGrid():void {
			LiftFromGrid();
			
			// remove our object
			m_gridObject = null;
		}
		
		public function LiftFromGrid():void {
			var tempArray:Array = new Array();
			
			var currentRow:Object = m_topLeft;
			while (currentRow) {
				var current:Object = currentRow;
				while (current) {
					tempArray.push(current);
					current = current.right;
				}
				currentRow = currentRow.bottom;
			}
			
			while(tempArray.length) {
				RemoveCoverCell( tempArray.pop() );
			}
			
			// empty our corner links
			m_topLeft = null;
			m_topRight = null;
			m_bottomLeft = null;
			m_bottomRight = null;
		}
		
		public function SetToGrid():void {
			var startCol:int = m_cellGrid.GetColFromWorld(m_worldCenter);
			var startRow:int = m_cellGrid.GetRowFromWorld(m_worldCenter);
			var gridCell:Object = m_cellGrid.GetGridCell(startCol, startRow);
			
			CoverInit(gridCell);
		}
		
		/* CalculateCenterWorld
		* returns a point at the center of the view cover,
		* used for placing focus on objects
		*/
		private function CalculateCenterWorld(p:Point):Point {
			p.x = m_startOffset.x + m_width/2 + m_topLeft.cell.col*m_cellWidth;
			p.y = m_startOffset.y + m_height/2 + m_topLeft.cell.row*m_cellHeight;
			
			return m_cellGrid.CalculateWorld(p);
		}
		
		/* GetWorldCenter
		* returns the cover center in world coordinates
		*/
		public function GetWorldCenter():Point {
			return m_worldCenter;
		}
		
		/* ResetWorldCenter
		* resets the world center of the cover
		*/
		private function ResetWorldCenter():void {
			m_worldCenter = CalculateCenterWorld(m_worldCenter);
		}
		
		/* SyncLocation
		* syncs the grid object's col and row according to the grid cover
		* also syncs the world center for the grid cover
		*/
		public function SyncLocation():void {
			ResetWorldCenter();
			if (m_gridObject) {
				m_gridObject.m_col = m_cellGrid.GetColFromWorld(m_worldCenter);
				m_gridObject.m_row = m_cellGrid.GetRowFromWorld(m_worldCenter);
				m_gridObject.m_localPoint.x = m_worldCenter.x;
				m_gridObject.m_localPoint.y = m_worldCenter.y;
				m_gridObject.m_localPoint = m_cellGrid.WorldToLocal(m_gridObject.m_localPoint, m_gridObject.m_col, m_gridObject.m_row);
			}
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
			str += "\ttopLeft: " + m_topLeft.cell.id + ": " + m_topLeft.x + ", " + m_topLeft.y + " (c,r): " + m_topLeft.cell.col + ", " + m_topLeft.cell.row + "\n";
			str += "\ttopRight: " + m_topRight.cell.id + ": " + m_topRight.x + ", " + m_topRight.y + " (c,r): " + m_topRight.cell.col + ", " + m_topRight.cell.row + "\n";
			str += "\tbottomLeft: " + m_bottomLeft.cell.id + ": " + m_bottomLeft.x + ", " + m_bottomLeft.y + " (c,r): " + m_bottomLeft.cell.col + ", " + m_bottomLeft.cell.row + "\n";
			str += "\tbottomRight: " + m_bottomRight.cell.id + ": " + m_bottomRight.x + ", " + m_bottomRight.y + " (c,r): " + m_bottomRight.cell.col + ", " + m_bottomRight.cell.row + "\n";
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
		
		public static function CreateGridCoverData_World(cellGrid:CellGridLocations,
		startWorld:Point,
		width:Number,
		height:Number):Object {
			var col:int = cellGrid.GetColFromWorld(startWorld);
			var row:int = cellGrid.GetRowFromWorld(startWorld);
			
			return CreateGridCoverDataFull(cellGrid,
			cellGrid.WorldToLocal(startWorld.clone(), col, row),
			col,
			row,
			width,
			height);
		}
		
		public static function CreateGridCoverData_GridObject(cellGrid:CellGridLocations, go:CellGridObject):Object {
			var p:Point = cellGrid.LocalToWorld(go.m_localPoint.clone(), go.m_col, go.m_row);
			p.x -= go.m_radius;
			if (p.x < 0) {
				p.x += cellGrid.GetGridWidth();
			}
			p.y -= go.m_radius;
			if (p.y < 0) {
				p.y += cellGrid.GetGridHeight();
			}
			
			var col:int = cellGrid.GetColFromWorld(p);
			var row:int = cellGrid.GetRowFromWorld(p);
			
			
			return CreateGridCoverDataFull(cellGrid,
			cellGrid.WorldToLocal(p, col, row),
			col,
			row,
			go.m_radius*2,
			go.m_radius*2);
			
		}
	}
	
}