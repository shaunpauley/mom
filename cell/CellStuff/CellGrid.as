/*
 *
 * @author Shaun Pauley
 * @version 1.0
 */

package CellStuff {
	
	public class CellGrid extends Sprite {
		
		private m_gridData:Object;
		
		private m_cols:int;
		private m_rows:int;
		
		private m_minCols:int;
		private m_minRows:int;
		
		private m_maxCols:int;
		private m_maxRows:int;
		
		private m_topLeftCell:Object;
		private m_topRightCell:Object;
		private m_bottomLeftCell:Object;
		private m_bottomRightCell:Object;
		
		// consts
		private static const c_defaultCols:Number = 10;
		private static const c_defaultRows:Number = 10;
		
		private static const c_defaultMinCols:Number = 5;
		private static const c_defaultMinRows:Number = 5;
		
		private static const c_defaultMaxCols:Number = 20;
		private static const c_defaultMaxRows:Number = 20;
		
		/* 
		* Constructor 
		*/
		public function CellGrid(gridData:Object):void {
			// assign
			m_gridData = gridData;
			
			m_cols = gridData.cols;
			m_rows = gridData.rows;
			
			m_minCols = gridData.minCols;
			m_minRows = gridData.minRows;
			
			m_maxCols = gridData.maxCols;
			m_maxRows = gridData.maxRows;
			
			// init
			m_topLeftCell = CreateGridCell();
			m_topRightCell = m_topLeftCell;
			m_bottomLeftCell = m_topLeftCell;
			m_bottomRightCell = m_topLeftCell;
			
		}
		
		private function CreateGridCell(top:Object = null,
		bottom:Object = null,
		left:Object = null,
		right:Object = null):Object {
			
			var gridCell:Object = {top:top, bottom:bottom, left:left, right:right};
			
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
		
		private function GrowGrid(numBottom:int, numRight:int):void {
			var currentCell:Object = m_bottomLeft;
			// travel right creating bottom cells;
			if (numBottom > 0) {
				for (var i:int = 0; i < numBottom; ++i) {
					while (currentCell) {
						// create bottom cells
						currentCell.bottom = CreateGridCell(currentCell);
						currentCell = currentCell.right;
					}
					m_bottomLeft = m_bottomLeft.bottom;
					currentCell = m_bottomLeft;
				}
			}
		}
		
		// public functions
		public function GetGrid(c:int, r:int):Object {
			if ( (c < 0) || (c >= m_maxCols) ||
				 (r < 0) || (r >= m_maxRows) ) {
				return null;
			}
			
			var index:int = c+r*m_maxCols;
			if (m_gridCells[index]) {
				throw( new Error("m_gridCells[" + c + "+" + r + "*" + m_maxCols + "]" +  m_gridCells[index] + " is null") );
			}
			return Object(m_gridCells[index]);
		}
		
		public function ShiftGridsLeft():void {
			
		}
		
		/*
		* GridDataObject
		*/
		public static function CreateGridDataFull(cols:int, 
		rows:int, 
		minCols:int,
		minRows:int,
		maxCols:int,
		maxRows:int
		):Object {
			return {cols:cols, 
			rows:rows, 
			minCols:minCols, 
			minRows:minRows, 
			maxCols:maxCols, 
			maxRows:maxRows};
		}
		
		public static function CreateGridData():Object {
			return CreateGridDataFull(c_defaultCols, 
			c_defaultRows, 
			c_defaultMinCols, 
			c_defaultMinRows, 
			c_defaultMaxCols, 
			c_defaultMaxRows);
		}
		
	}
	
}
