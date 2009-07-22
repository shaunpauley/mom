/*
 *
 * @author Shaun Pauley
 * @version 1.0
 */

package CellStuff {
	
	public class CellGrid {
		
		private var m_gridData:Object;
		
		private var m_cols:int;
		private var m_rows:int;
		
		private var m_stockCells:Array;
		
		private var m_topLeft:Object;
		private var m_topRight:Object;
		private var m_bottomLeft:Object;
		private var m_bottomRight:Object;
		
		// consts
		private static const c_defaultCols:Number = 10;
		private static const c_defaultRows:Number = 10;
		
		/* 
		* Constructor 
		*/
		public function CellGrid(gridData:Object):void {
			// assign
			m_gridData = gridData;
			
			m_cols = gridData.cols;
			m_rows = gridData.rows;
			
			// init
			m_stockCells = new Array();
			
			m_topLeft = CreateGridCell();
			m_topRight = m_topLeft;
			m_bottomLeft = m_topLeft;
			m_bottomRight = m_topLeft;
			
			
		}
		
		/* CreateGridCell 
		* using a stock array we can preserve deleted grid cells in the case where we need
		* to grow and shrink the grid cells rapidly
		*/
		private function CreateGridCell(top:Object = null,
		bottom:Object = null,
		left:Object = null,
		right:Object = null):Object {
			
			var gridCell:Object = null;
			
			if (m_stockCells.length > 0) {
				gridCell = m_stockCells.pop();
				gridCell.top = top;
				gridCell.bottom = bottom;
				gridCell.left = left;
				gridCell.right = right;
				
			} else {
				gridCell = {top:top, bottom:bottom, left:left, right:right};
				
			}
			
			if (top) {
				top.bottom = gridCell;
			}
			if (bottom) {
				bottom.top = gridCell;
			}
			if (left) {
				left.right = gridCell;
			}
			if (right) {
				right.left = gridCell;
			}
			
			return gridCell;
		}
		
		/* GrowGrid
		* grow our grid, only takes positive integers
		**/
		private function GrowGrid(numTop:int, numBottom:int, numLeft:int, numRight:int):void {
			
			// travel right creating top cells;
			while (numTop) {
				var currentCell:Object = m_topLeft;
				var previousCell:Object = null;
				while (currentCell) {
					// create top cells
					currentCell.top = CreateGridCell(null, currentCell, previousCell);
					previousCell = currentCell.top;
					currentCell = currentCell.right;
				}
				m_topLeft = m_topLeft.top;
				m_topRight = m_topRight.top;
				--numTop;
			}
			
			// travel right create bottom cells;
			while (numBottom) {
				currentCell = m_bottomLeft;
				previousCell = null;
				while (currentCell) {
					// create bottom cells
					currentCell.bottom = CreateGridCell(currentCell, null, previousCell);
					previousCell = currentCell.bottom;
					currentCell = currentCell.right;
				}
				m_bottomLeft = m_bottomLeft.bottom;
				m_bottomRight = m_bottomRight.bottom;
				--numBottom;
			}
			
			// travel down creating left cells;
			while (numLeft) {
				currentCell = m_topLeft;
				previousCell = null;
				while (currentCell) {
					// create left cells
					currentCell.left = CreateGridCell(previousCell, null, null, currentCell);
					previousCell = currentCell.left;
					currentCell = currentCell.bottom;
				}
				m_topLeft = m_topLeft.left;
				m_bottomLeft = m_bottomLeft.left;
				--numLeft;
			}
			
			// travel down creating right cells;
			while (numRight) {
				currentCell = m_topRight;
				previousCell = null;
				while (currentCell) {
					// create right cells
					currentCell.right = CreateGridCell(previousCell, null, currentCell, null);
					previousCell = currentCell.right;
					currentCell = currentCell.bottom;
				}
				m_topRight = m_topRight.right;
				m_bottomRight = m_bottomRight.right;
				--numRight;
			}
		}
		
		/* ShrinkGrid
		* shrinks our grid.  It will not shrink past 1x1 grid.  Only takes positive integers
		*/
		private function ShrinkGrid(numTop:int, numBottom:int, numLeft:int, numRight:int):void {
			
			while(numTop) {
				if (!m_topRight.bottom || !m_topLeft.bottom) {
					break;
				}
				var currentCell:Object = m_topRight;
				m_topRight = m_topRight.bottom;
				m_topLeft = m_topLeft.bottom;
				
				while(currentCell) {
					var nextCell:Object = currentCell.left;
					RemoveGridCell(currentCell);
					currentCell = nextCell;
				}
				--numTop;
			}
			
			while(numBottom) {
				if (!m_bottomRight.top || !m_bottomLeft.top) {
					break;
				}
				currentCell = m_bottomRight;
				m_bottomRight = m_bottomRight.top;
				m_bottomLeft = m_bottomLeft.top;
				
				while(currentCell) {
					nextCell = currentCell.left;
					RemoveGridCell(currentCell);
					currentCell = nextCell;
				}
				--numBottom;
			}
			
			while(numLeft) {
				if (!m_topLeft.right|| !m_bottomLeft.right) {
					break;
				}
				currentCell = m_topLeft;
				
				m_topLeft = m_topLeft.right;
				m_bottomLeft = m_bottomLeft.right;
				
				while(currentCell) {
					nextCell = currentCell.bottom;
					RemoveGridCell(currentCell);
					currentCell = nextCell;
				}
				--numLeft;
			}
			
			while(numRight) {
				if (!m_topRight.left|| !m_bottomRight.left) {
					break;
				}
				currentCell = m_topRight;
				
				m_topRight = m_topRight.left;
				m_bottomRight = m_bottomRight.left;
				
				while(currentCell) {
					nextCell = currentCell.bottom;
					RemoveGridCell(currentCell);
					currentCell = nextCell;
				}
				--numRight;
			}
			
			if (!m_topLeft && !m_topRight && !m_bottomLeft && !m_bottomRight) {
				m_topLeft = CreateGridCell();
				m_topRight = m_topLeft;
				m_bottomLeft = m_topLeft;
				m_bottomRight = m_topLeft;
			} else if (!m_topLeft || !m_topRight || !m_bottomLeft && !m_bottomRight) {
				throw(new Error("ShrinkGrid error: missing reference for grid corner (not possible)"));
			}
		}
		
		/* RemoveGridCell
		* frees a grid cell and puts it into the stock so it can be flushed later.
		* (This is sort of a a way to control Garbage Collecting, and may be useful later)
		*/
		private function RemoveGridCell(gridCell:Object):void {
			if (gridCell.top) {
				gridCell.top.bottom = null;
			}
			gridCell.top = null;
			
			if (gridCell.bottom) {
				gridCell.bottom.top = null;
			}
			gridCell.bottom = null;
			
			if (gridCell.left) {
				gridCell.left.right = null;
			}
			gridCell.left = null;
			
			if (gridCell.right) {
				gridCell.right.left = null;
			}
			gridCell.right = null;
			
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
			var str:String = "";
			var count:int = 1;
			var currentCell:Object = m_topLeft;
			while(currentCell) {
				var currentRowCell:Object = currentCell;
				while (currentRowCell) {
					str += "\t" + count;
					str += (currentRowCell.top?"T":"");
					str += (currentRowCell.bottom?"B":"");
					str += (currentRowCell.left?"L":"");
					str += (currentRowCell.right?"R":"");
					
					currentRowCell = currentRowCell.right;
					++count;
				}
				str += "\n";
				currentCell = currentCell.bottom;
			}
			
			return str;
		}
		
		// unit test
		public static function UnitTest():void {
			trace("***BEGIN CellGrid UNIT TEST***");
			var testGrid:CellGrid = new CellGrid( CreateGridDataFull(1, 1) );
			trace("TEST 1) INIT");
			trace(testGrid.ToString());
			
			trace("TEST 2) GROW SIMPLE");
			testGrid.GrowGrid(0, 1, 0, 1);
			trace(testGrid.ToString());
			
			trace("TEST 3) GROW SIMPLE MORE");
			testGrid.GrowGrid(1, 0, 1, 0);
			trace(testGrid.ToString());
			
			trace("TEST 4) GROW COMPLEX");
			testGrid.GrowGrid(2, 3, 4, 5);
			trace(testGrid.ToString());
			
			trace("TEST 5) SHRINK COMPLEX (ANSWER IS 3)");
			testGrid.ShrinkGrid(2, 3, 4, 5);
			trace(testGrid.ToString());
			
			trace("TEST 6) SHRINK SIMPLE MORE (ANSWER IS 2)");
			testGrid.ShrinkGrid(1, 0, 1, 0);
			trace(testGrid.ToString());
			
			trace("TEST 7) SHRINK ALL");
			testGrid.ShrinkGrid(0, 1, 0, 1);
			trace(testGrid.ToString());
			
			trace("TEST 8) SHRINK PAST ALL");
			testGrid.ShrinkGrid(10, 10, 10, 10);
			trace(testGrid.ToString());
			
			trace("TEST 9) GROW AFTER SHRINK");
			testGrid.GrowGrid(5, 0, 0, 5);
			trace(testGrid.ToString());
			
			trace("TEST 10) STOCK SIZE");
			trace(testGrid.m_stockCells.length);
			
			trace("TEST 11) STOCK FLUSH");
			testGrid.FlushStock();
			trace("num in stock: " + testGrid.m_stockCells.length);
			
			trace("TEST 12) GROW AFTER STOCK FLUSH");
			testGrid.GrowGrid(0, 3, 3, 0);
			trace(testGrid.ToString());
			trace("num in stock: " + testGrid.m_stockCells.length);
			
			trace("***END CellGrid UNIT TEST***");
		}
	}
	
}
