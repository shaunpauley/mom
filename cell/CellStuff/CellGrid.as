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
		
		private var m_cells:Array;
		
		private var m_idcount:int;
		
		// consts
		private static const c_defaultCols:Number = 20;
		private static const c_defaultRows:Number = 20;
		
		/* Constructor 
		*/
		public function CellGrid(gridData:Object):void {
			// init
			m_stockCells = new Array();
			
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
				newCell = {col:c, row:r, id:++m_idcount, objects:new Array()};
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
			gridCell.top = GetGridCell(gridCell.col, gridCell.row-1);
			gridCell.bottom = GetGridCell(gridCell.col, gridCell.row+1);
			gridCell.left = GetGridCell(gridCell.col-1, gridCell.row);
			gridCell.right = GetGridCell(gridCell.col+1, gridCell.row);
			
			while(gridCell.objects.length) {
				gridCell.objects.pop();
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
		
		/* AddObject
		* adds any object to the list of objects in a grid cell
		*/
		public function AddObject(gridCell:Object, object:*):void {
			gridCell.objects.push(object);
		}
		
		/* RemoveObject
		* removes the object if exists from the grid cell
		*/
		public function RemoveObject(gridCell:Object, object:*):void {
			var i:int = gridCell.objects.indexOf(object);
			if (i > 0) {
				gridCell.objects.splice(i, 1);
			}
		}
		
		/* RemoveGridCell
		* removes the grid cell's adjacent links
		* and places the grid cell on the stock.
		* Note, that this does not actually remove the cell from the array of cells.
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
			
			m_stockCells.push(gridCell);
		}
		
		/* FlushStock
		* flushes the stock for garbage collection 
		*/
		private function FlushStock():void {
			while(m_stockCells.length) {
				m_stockCells.pop();
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
		
		// use this to display debug info for individual gridcell objects
		public static function GridCellToString(gridCell:Object):String {
			var str:String = "\t";
			str += gridCell.id;
			str += (gridCell.top?"T":"");
			str += (gridCell.bottom?"B":"");
			str += (gridCell.left?"L":"");
			str += (gridCell.right?"R":"");
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
			trace( GridCellToString(testGrid.GetGridCell(testGrid.m_cols-1, testGrid.m_rows-1)) );
			
			trace("TEST 7) GET CELL, 100, 100");
			trace( GridCellToString(testGrid.GetGridCell(100, 100)) );
			
			trace("TEST 8) GET CELL, 134, 63");
			trace( GridCellToString(testGrid.GetGridCell(134, 63)) );
			
			trace("***END CellGrid UNIT TEST***");
		}
	}
	
}
