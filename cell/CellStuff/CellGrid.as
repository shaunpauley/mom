/*
 *
 * @author Shaun Pauley
 * @version 1.0
 */

package CellStuff {
	
	public class CellGrid {
		
		private var m_gridData:Object;
		
		protected var m_cols:int;
		protected var m_rows:int;
		
		private var m_stockCells:Array;
		private var m_stockCovers:Array;
		private var m_stockCoverCells:Array;
		
		private var m_cells:Array;
		
		private var m_idcount:int;
		
		private var m_numOccupiedByObjects:int;
		private var m_numOccupiedByCovers:int;
		
		private var m_numActiveCoverCells:int;
		
		// consts
		private static const c_defaultCols:Number = 20;
		private static const c_defaultRows:Number = 20;
		
		/* Constructor 
		*/
		public function CellGrid(gridData:Object):void {
			// init
			m_stockCells = new Array();
			m_stockCovers = new Array();
			m_stockCoverCells = new Array();
			
			m_cells = new Array();
			
			m_idcount = 0;
			
			ResetGrid(gridData);
		}
		
		/* ResetGrid
		* Resets the entire grid.
		* We can use this for reuse or reseting a grid
		*/
		private function ResetGrid(gridData:Object):void {
			// assign
			m_gridData = gridData;
			
			m_cols = gridData.cols;
			m_rows = gridData.rows;
			
			// init
			while(m_cells.length) {
				RemoveGridCell(m_cells.pop());
			}
			
			m_numOccupiedByObjects = 0;
			m_numOccupiedByCovers = 0;
			
			m_numActiveCoverCells = 0;
			
			for (var r:int = 0; r < m_rows; ++r) {
				for (var c:int = 0; c < m_cols; ++c) {
					m_cells[c+r*m_cols] = CreateGridCell(c, r);
				}
			}
			
			// we need to reset all grid cells again to complete linking
			for (r = 0; r < m_rows; ++r) {
				for (c = 0; c < m_cols; ++c) {
					ResetGridCell(m_cells[c+r*m_cols]);
				}
			}
		}
		
		/* CreateGridCell 
		* Creates a new GridCell.
		* For resuability and to save space we use implement this to pull from the stock, or create
		* one if there isn't any in the stock.
		*/
		private function CreateGridCell(c:int, r:int):Object {
			if (m_stockCells.length > 0) {
				var newCell:Object = m_stockCells.pop();
			} else {
				newCell = {col:c, row:r, id:++m_idcount, objects:new Array(), coverCells:new Array()};
			}
			
			return ResetGridCell(newCell);
		}
		
		/* ResetGridCell
		* Resets a grid cell for creation.
		* This resets the locations on a grid cell.
		*/
		private function ResetGridCell(gridCell:Object):Object {
			gridCell.col %= m_cols;
			gridCell.row %= m_rows;
			gridCell.top = GetGridCell(gridCell.col, (gridCell.row-1)<0?(gridCell.row-1+m_rows):(gridCell.row-1));
			gridCell.bottom = GetGridCell(gridCell.col, gridCell.row+1);
			gridCell.left = GetGridCell((gridCell.col-1)<0?(gridCell.col-1+m_cols):(gridCell.col-1), gridCell.row);
			gridCell.right = GetGridCell(gridCell.col+1, gridCell.row);
			
			while(gridCell.objects.length) {
				gridCell.objects.pop();
			}
			
			while(gridCell.coverCells.length) {
				gridCell.coverCells.pop();
			}
			
			if (gridCell.top) {
				gridCell.top.bottom = gridCell;
			}
			if (gridCell.bottom) {
				gridCell.bottom.top = gridCell;
			}
			if (gridCell.left) {
				gridCell.left.right = gridCell;
			}
			if (gridCell.right) {
				gridCell.right.left = gridCell;
			}
			
			return gridCell;
		}
		
		/* GetGridCell
		* Returns a grid cell.
		* Even if the grid cell is off the grid, it preserves wrapping around.
		* NOTE: Only takes positive integer values, for some reason flash does not preserve negative moduli
		*/
		public function GetGridCell(c:int, r:int):Object {
			return m_cells[c%m_cols + (r%m_rows)*m_cols];
		}
		
		/* PushGridObject
		* pushes the gridobject in the list of gridCells
		*/
		private function PushGridObject(gridCell:Object, go:CellGridObject):void {
			/*
			var i:int = gridCell.objects.indexOf(go);
			if (i < 0) {
				gridCell.objects.push(go);
			} else {
				throw( new Error("AddGridObject: Cannot add gridobject because gridobject already exists") );
			}
			*/
			gridCell.objects.push(go);
		}
		
		/* SpliceGridObject
		* removes the gridobject from the list of gridCells
		*/
		private function SpliceGridObject(gridCell:Object, go:CellGridObject):void {
			var i:int = gridCell.objects.indexOf(go);
			if (i > -1) {
				gridCell.objects.splice(i, 1);
			} else {
				throw( new Error("SpliceGridObject: Cannot remove object because object does not exit") );
			}
		}
		
		/* PushCoverCell
		* pushes the covercell in the list of coverCells
		*/
		private function PushCoverCell(gridCell:Object, coverCell:Object):void {
			/*
			var i:int = gridCell.objects.indexOf(go);
			if (i < 0) {
				gridCell.objects.push(go);
			} else {
				throw( new Error("AddGridObject: Cannot add gridobject because gridobject already exists") );
			}
			*/
			gridCell.coverCells.push(coverCell);
		}
		
		/* SpliceCoverCell
		* removes the covercell from the list of coverCells
		*/
		private function SpliceCoverCell(gridCell:Object, coverCell:Object):void {
			var i:int = gridCell.coverCells.indexOf(coverCell);
			if (i > -1) {
				gridCell.coverCells.splice(i, 1);
			} else {
				throw( new Error("SpliceCoverCell: Cannot remove object because object does not exit") );
			}
		}
		
		/* AddGridObject
		* adds any object to the list of objects in a grid cell
		* also, notifies all covers in the cell that the object has entered.
		* Note, that this method should only be used by objects that don't need a cell cover,
		* which may be very rare.
		*/
		public function AddGridObject(gridCell:Object, go:CellGridObject):void {
			for each (var coverCell2:Object in gridCell.coverCells) {
				coverCell2.cover.GridObjectEnter(coverCell2, go);
			}
			
			PushGridObject(gridCell, go);
			
			m_numOccupiedByObjects++;
		}
		
		/* RemoveGridObject
		* removes the object if exists from the grid cell.
		* also, notifies all covers in the cell that the object has left
		* Note, that this method should only be used by objects that don't need a cell cover,
		* which may be very rare.
		*/
		public function RemoveGridObject(gridCell:Object, go:CellGridObject):void {
			SpliceGridObject(gridCell, go);
			
			m_numOccupiedByObjects--;
			
			for each (var coverCell2:Object in gridCell.coverCells) {
				coverCell2.cover.GridObjectLeave(coverCell2, go);
			}
		}
		
		/* AddCoverCell
		* adds a covercell to the list of covercells in a grid cell
		* also notifies the new covercell of all gridobjects in the grid cell,
		* Note, that this method should only be used by covers that don't have gridobjects,
		* ie. viewcover, and any sightcovers
		*/
		public function AddCoverCell(gridCell:Object, coverCell:Object):void {
			for each (var go2:CellGridObject in gridCell.objects) {
				coverCell.cover.GridObjectEnter(coverCell, go2);
			}
			
			PushCoverCell(gridCell, coverCell);
			
			m_numOccupiedByCovers++;
			
		}
		
		/* RemoveCoverCell
		* removes a covercell from the list of covercells in a grid cell
		* also notifies of leaving the new covercell of all gridobjects in the grid cell,
		* Note, that this method should only be used by covers that don't have gridobjects,
		* ie. viewcover, and any sightcovers
		*/
		public function RemoveCoverCell(gridCell:Object, coverCell:Object):void {
			SpliceCoverCell(gridCell, coverCell);
			
			m_numOccupiedByCovers--;
			
			for each (var go2:CellGridObject in gridCell.objects) {
				coverCell.cover.GridObjectLeave(coverCell, go2);
			}
			
		}
		
		/* AddGridObjectAndCoverCell
		* adds a gridobject and a covercell to the grid cell, while preserving that the
		* covercell and gridobject do not notify each other, this is useful for all grid objects
		* and collision detection.
		* use this method when adding grid objects.
		*/
		public function AddGridObjectAndCoverCell(gridCell:Object, go:CellGridObject, coverCell:Object):void {
			for each (var coverCell2:Object in gridCell.coverCells) {
				coverCell2.cover.GridObjectEnter(coverCell2, go);
			}
			
			for each (var go2:CellGridObject in gridCell.objects) {
				coverCell.cover.GridObjectEnter(coverCell, go2);
			}
			
			PushGridObject(gridCell, go);
			m_numOccupiedByObjects++;
			
			PushCoverCell(gridCell, coverCell);
			m_numOccupiedByCovers++;
			
		}
		
		/* RemoveGridObjectAndCoverCell
		* adds a gridobject and a covercell to the grid cell, while preserving that the
		* covercell and gridobject do not notify each other, this is useful for all grid objects
		* and collision detection.
		* use this method when adding grid objects.
		*/
		public function RemoveGridObjectAndCoverCell(gridCell:Object, go:CellGridObject, coverCell:Object):void {
			SpliceGridObject(gridCell, go);
			m_numOccupiedByObjects--;
			
			SpliceCoverCell(gridCell, coverCell);
			m_numOccupiedByCovers--;
			
			for each (var coverCell2:Object in gridCell.coverCells) {
				coverCell2.cover.GridObjectLeave(coverCell2, go);
			}
			
			for each (var go2:CellGridObject in gridCell.objects) {
				coverCell.cover.GridObjectLeave(coverCell, go2);
			}
			
		}
		
		/* RemoveGridCell
		* removes the grid cell's adjacent links
		* and places the grid cell on the stock.
		* Note, that this does not actually remove the cell from the array of cells,
		* and doesn't notify anything
		*/
		private function RemoveGridCell(gridCell:Object):void {
			if (gridCell.top) {
				gridCell.top.bottom = null;
				gridCell.top = null;
			}
			if (gridCell.bottom) {
				gridCell.bottom.top = null;
				gridCell.bottom = null;
			}
			if (gridCell.left) {
				gridCell.left.right = null;
				gridCell.left = null;
			}
			if (gridCell.right) {
				gridCell.right.left = null;
				gridCell.right = null;
			}
			
			while(gridCell.objects.length) {
				gridCell.objects.pop();
			}
			
			while(gridCell.cellCovers.length) {
				gridCell.cellCovers.pop();
			}
			
			m_stockCells.push(gridCell);
		}
		
		/* NewCoverCell
		* grabs a new covercelll from the stock, if none, then creates a new object
		*/
		public function NewCoverCell():Object {
			m_numActiveCoverCells++;
			if (m_stockCoverCells.length) {
				return m_stockCoverCells.pop();
			}
			return new Object();
		}
		
		/* StockCoverCell
		* pushes the existing covercell on the stock
		*/
		public function StockCoverCell(coverCell:Object):void {
			m_stockCoverCells.push(coverCell);
			m_numActiveCoverCells--;
		}
		
		/* FlushStock
		* flushes the stock for garbage collection 
		*/
		private function FlushStock():void {
			while(m_stockCells.length) {
				m_stockCells.pop();
			}
			
			while(m_stockCoverCells.length) {
				m_stockCoverCells.pop();
			}
			
		}
		
		
		/*
		* GridDataObject
		*/
		public static function CreateGridDataFull(cols:int, rows:int):Object {
			return {cols:cols, rows:rows};
		}
		
		public static function CreateGridData():Object {
			return CreateGridDataFull(c_defaultCols, c_defaultRows);
		}
		
		// debug
		public function ToString():String {
			var str:String = "CellGrid: " + m_cols + ", " + m_rows + "\n";
			var count:int = 0;
			
			for (var r:int = 0; r < m_rows; ++r) {
				for (var c:int = 0; c < m_cols; ++c) {
					str += GridCellToString( GetGridCell(c, r) );
					if (count++ > 500) {
						str += "...";
						break;
					}
				}
				str += "\n";
				
				if (count > 500) {
					break;
				}
			}
			
			return str;
		}
		
		/* UpdatePerformanceStatistics
		*/
		public function UpdatePerformanceStatistics(pStats:CellPerformanceStatistics):CellPerformanceStatistics {
			pStats.m_numGridCells = m_cells.length;
			pStats.m_numGridCellsOccupiedByObjects = m_numOccupiedByObjects;
			pStats.m_numGridCellsOccupiedByCovers = m_numOccupiedByCovers;
			pStats.m_numGridColumns = m_cols;
			pStats.m_numGridRows = m_rows;
			pStats.m_numActiveCoverCells = m_numActiveCoverCells;
			pStats.m_numStockGridCells = m_stockCells.length;
			pStats.m_numStockCoverCells = m_stockCoverCells.length;
			
			return pStats;
		}
		
		// use this to display debug info for individual gridcell objects
		public static function GridCellToString(gridCell:Object):String {
			var str:String = "\t";
			str += gridCell.id;
			str += (gridCell.top?"T"+gridCell.top.id:"");
			str += (gridCell.bottom?"B"+gridCell.bottom.id:"");
			str += (gridCell.left?"L"+gridCell.left.id:"");
			str += (gridCell.right?"R"+gridCell.right.id:"");
			str += (gridCell.viewCell?"V":"");
			return str;
		}
		
		// unit test
		public static function UnitTest():void {
			trace("***BEGIN CellGrid UNIT TEST***");
			var testGrid:CellGrid = new CellGrid( CreateGridDataFull(10, 10) );
			trace("TEST 1) INIT");
			trace(testGrid.ToString());
			
			trace("TEST 2) GET CELL, 5, 5");
			trace( GridCellToString(testGrid.GetGridCell(5, 5)) );
			
			trace("TEST 3) GET CELL, 0, 0");
			trace( GridCellToString(testGrid.GetGridCell(0, 0)) );
			
			trace("TEST 4) GET CELL, 0, endr");
			trace( GridCellToString(testGrid.GetGridCell(0, testGrid.m_rows-1)) );
			
			trace("TEST 5) GET CELL, endc, 0");
			trace( GridCellToString(testGrid.GetGridCell(testGrid.m_cols-1, 0)) );
			
			trace("TEST 6) GET CELL, endc, endr");
			var cell:Object = testGrid.GetGridCell(testGrid.m_cols-1, testGrid.m_rows-1);
			trace( GridCellToString(cell) );
			
			trace("TEST 7) GET END CELL.RIGHT");
			cell = cell.right;
			trace( GridCellToString(cell) );
			
			trace("TEST 8) GET PREVIOUS CELL.BOTTOM");
			cell = cell.bottom;
			trace( GridCellToString(cell) );
			
			trace("TEST 9) GET END CELL.BOTTOM");
			cell = testGrid.GetGridCell(testGrid.m_cols-1, testGrid.m_rows-1);
			cell = cell.bottom;
			trace( GridCellToString(cell) );
			
			trace("TEST 10) GET PREVIOUS CELL.RIGHT");
			cell = cell.right;
			trace( GridCellToString(cell) );
			
			trace("TEST 11) GET CELL, 100, 100");
			trace( GridCellToString(testGrid.GetGridCell(100, 100)) );
			
			trace("TEST 12) GET CELL, 134, 63");
			trace( GridCellToString(testGrid.GetGridCell(134, 63)) );
			
			trace("***END CellGrid UNIT TEST***");
		}
	}
	
}
