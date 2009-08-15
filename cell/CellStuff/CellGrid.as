/*
 *
 * @author Shaun Pauley
 * @version 1.0
 */

package CellStuff {
	
	import flash.utils.Dictionary;
	
	public class CellGrid {
		
		private var m_levelData:Object;
		
		protected var m_cols:int;
		protected var m_rows:int;
		
		private var m_stockCells:Array;
		private var m_stockCovers:Array;
		private var m_stockCoverCells:Array;
		
		private var m_cellColumns:Array;
		
		private var m_idcount:int;
		private var m_level:int;
		private var m_levelCellCount:int;
		
		private var m_numOccupiedByObjects:int;
		private var m_numOccupiedByCovers:int;
		
		private var m_numActiveCoverCells:int;
		
		private var m_gcDefaultData:Object;
		
		private var m_tempDictionary:Dictionary;
		private var m_tempArray:Array;
		
		// consts
		private static const c_defaultCols:Number = 20;
		private static const c_defaultRows:Number = 20;
		
		public static const c_drawTypeDefault:uint = 0x000000;
		public static const c_drawTypeRandom:uint = 0x000001;
		public static const c_drawTypeFlat:uint = 0x000002;
		public static const c_drawTypeBitmap:uint = 0x000003;
		
		/* Constructor 
		*/
		public function CellGrid(gridData:Object):void {
			
			m_levelData = null;
			
			// init
			m_stockCells = new Array();
			m_stockCovers = new Array();
			m_stockCoverCells = new Array();
			
			m_cellColumns = new Array();
			
			m_idcount = 0;
			
			m_gcDefaultData = new Object();
			
			m_tempDictionary = new Dictionary();
			m_tempArray = new Array();
			
			ResetGrid(gridData);
		}
		
		/* ResetGrid
		* Resets the entire grid.
		* We can use this for reuse or reseting a grid
		*/
		private function ResetGrid(gridData:Object):void {
			
			m_cols = gridData.cols?gridData.cols:c_defaultCols;
			m_rows = gridData.rows?gridData.rows:c_defaultRows;
			
			m_level = gridData.level?gridData.level:1;
			m_levelCellCount = gridData.levelCellCount?gridData.levelCellCount:0;
			
			m_gcDefaultData.drawType = gridData.defaultDrawType?gridData.defaultDrawType:c_drawTypeDefault;
			m_gcDefaultData.colorHigh = gridData.defaultColorHigh?gridData.defaultColorHigh:0xFFFFFF;
			m_gcDefaultData.colorLow = gridData.defaultColorLow?gridData.defaultColorLow:0x000000;
			m_gcDefaultData.libraryName = gridData.defaultLibraryName?gridData.defaultLibraryName:"PhysTilePattern";
			
			// init
			
			while(m_cellColumns.length) {
				var cellColumn:Array = m_cellColumns.pop();
				while(cellColumn.length) {
					cellColumn.pop();
				}
			}
			
			m_numOccupiedByObjects = 0;
			m_numOccupiedByCovers = 0;
			
			m_numActiveCoverCells = 0;
			
			for (var c:int = 0; c < m_cols; ++c) {
				m_cellColumns[c] = new Array();
				for (var r:int = 0; r < m_rows; ++r) {
					m_cellColumns[c][r] = NewGridCell(c, r);
				}
			}
			
			// we need to reset all grid cells again to complete linking
			for (r = 0; r < m_rows; ++r) {
				for (c = 0; c < m_cols; ++c) {
					var newCell:Object = GetGridCell(c, r);
					ResetGridCell(newCell);
				}
			}
		}
		
		/* NewGridCell 
		* grabs a new gridcell from the stock or creates a new one.
		* For resuability and to save space we use implement this to pull from the stock, or create
		* one if there isn't any in the stock.
		*/
		private function NewGridCell(c:int, r:int):Object {
			if (m_stockCells.length > 0) {
				var newCell:Object = m_stockCells.pop();
				newCell.col = c;
				newCell.row = r;
				newCell.level = m_level;
				while(newCell.objects.length) {
					newCell.objects.pop();
				}
				while(newCell.coverCells.length) {
					newCell.coverCells.pop();
				}
			} else {
				newCell = {col:c, row:r, id:++m_idcount, level:m_level, objects:new Array(), coverCells:new Array()};
			}
			
			return ResetGridCellData(newCell, m_gcDefaultData);
		}
		
		/* ResetGridCell
		* Resets a grid cell for creation.
		* This resets the locations on a grid cell.
		*/
		private function ResetGridCell(gridCell:Object):Object {
			
			while(gridCell.objects.length) {
				gridCell.objects.pop();
			}
			
			while(gridCell.coverCells.length) {
				gridCell.coverCells.pop();
			}
			
			return ResetGridCellLocations(gridCell);
		}
		
		/* ResetGridCellLocations
		* resets the gridcells col, row, and links
		*/
		private function ResetGridCellLocations(gridCell:Object):Object {
			gridCell.col %= m_cols;
			gridCell.row %= m_rows;
			gridCell.top = GetGridCell(gridCell.col, (gridCell.row-1)<0?(gridCell.row-1+m_rows):(gridCell.row-1));
			gridCell.bottom = GetGridCell(gridCell.col, gridCell.row+1);
			gridCell.left = GetGridCell((gridCell.col-1)<0?(gridCell.col-1+m_cols):(gridCell.col-1), gridCell.row);
			gridCell.right = GetGridCell(gridCell.col+1, gridCell.row);
			
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
			
			for each (var coverCell:Object in gridCell.coverCells) {
				
			}
			
			return gridCell;
		}
		
		/* ResetGridCellData
		* resets the grid cell data
		*/
		public function ResetGridCellData(gridCell:Object, gcData:Object):Object {
			
			gridCell.drawType = gcData.drawType?gcData.drawType:c_drawTypeDefault;
			
			gridCell.colorHigh = gcData.colorHigh?gcData.colorHigh:0xFFFFFF;
			gridCell.colorLow = gcData.colorLow?gcData.colorLow:0x000000;
			
			gridCell.libraryName = gcData.libraryName?gcData.libraryName:"PhysTilePattern";
			
			return gridCell;
		}
		
		/* GetGridCell
		* Returns a grid cell.
		* Even if the grid cell is off the grid, it preserves wrapping around.
		* NOTE: Only takes positive integer values, for some reason flash does not preserve negative moduli
		*/
		public function GetGridCell(c:int, r:int):Object {
			return m_cellColumns[c%m_cols][r%m_rows];
		}
		
		/* PushGridObject
		* pushes the gridobject in the list of gridCells
		*/
		private function PushGridObject(gridCell:Object, go:CellGridObject):void {
			var i:int = gridCell.objects.indexOf(go);
			if (i < 0) {
				gridCell.objects.push(go);
			} else {
				throw( new Error("AddGridObject: Cannot add gridobject because gridobject already exists") );
			}
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
			var i:int = gridCell.coverCells.indexOf(coverCell);
			if (i < 0) {
				gridCell.coverCells.push(coverCell);
			} else {
				throw( new Error("PushCoverCell: Cannot add covercell because covercell already exists") );
			}
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
			
			if (go.m_isMarkedForDeletion) {
				go.ReleaseGridCover();
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
			
			for each (go2 in gridCell.objects) {
				if (go2.m_isMarkedForDeletion) {
					go2.ReleaseGridCover();
				}
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
		
		/* AddColumns
		* adds a new column to the right of the grid,
		* updates covers
		*/
		protected function AddColumns(numColumns:int):void {
			// first check if we are adding a column inside a cover
			// all objects that are under the insert must be removed and readded
			
			for each (var gridCell:Object in m_cellColumns[m_cols-1]) {
				for each (var coverCell:Object in gridCell.coverCells) {
					if (coverCell.right) {
						m_tempDictionary[coverCell.cover] = true;
					}
				}
			}
			
			for (var cellCover:* in m_tempDictionary) {
				cellCover.LiftFromGrid();
			}
			
			for (var c:int = 0; c < numColumns; ++c) {
				var newColumn:Array = new Array();
				for (var r:int = 0; r < m_rows; ++r) {
					newColumn[r] = NewGridCell(m_cols, r);
				}
				m_cellColumns.push(newColumn);
				m_cols++;
				for (r = 0; r < m_rows; ++r) {
					ResetGridCellLocations(newColumn[r]);
				}
				
			}
			
			for (cellCover in m_tempDictionary) {
				cellCover.SetToGrid();
				m_tempArray.push(cellCover);
			}
			
			while(m_tempArray.length) {
				delete m_tempDictionary[ m_tempArray.pop() ];
			}
			
		}
		
		/* AddRows
		* Adds a new row to the bottom of the grid,
		* updates covers
		*/
		protected function AddRows(numRows:int):void {
			
			for each (var cellColumn:Array in m_cellColumns) {
				for each (var coverCell:Object in cellColumn[m_rows-1].coverCells) {
					if (coverCell.bottom) {
						m_tempDictionary[coverCell.cover] = true;
					}
				}
			}
			
			for (var cellCover:* in m_tempDictionary) {
				cellCover.LiftFromGrid();
			}
			
			for (var c:int = 0; c < m_cols; ++c) {
				for (var r:int = 0; r < numRows; ++r) {
					m_cellColumns[c].push( NewGridCell(c, m_rows + r) );
				}
			}
			m_rows += numRows;
			for (c = 0; c < m_cols; ++c) {
				for (r = 0; r < numRows; ++r) {
					ResetGridCellLocations( m_cellColumns[c][m_rows-numRows + r] );
				}
			}
			
			
			for (cellCover in m_tempDictionary) {
				cellCover.SetToGrid();
				m_tempArray.push(cellCover);
			}
			
			while(m_tempArray.length) {
				delete m_tempDictionary[ m_tempArray.pop() ];
			}
		}
		
		/* RemoveColumn
		* removes an entire column
		* note, it will remove all objects, and shouldn't be used on any lone covers,
		* preserve gridcell locations
		*/
		protected function RemoveColumn(c:int):void {
			
			while(m_cellColumns[c].length) {
				RemoveGridCell( m_cellColumns[c].pop() );
			}
			
			m_cellColumns.splice(c, 1);
			m_cols--;
			
			SyncLocations(c, 0);
		}
		
		/* RemoveRow
		* removes the entire row,
		* note, it will remove all objects, and shouldn't be used on any lone covers,
		* preserve gridcell locations
		*/
		protected function RemoveRow(r:int):void {
			
			for each (var cellColumn:Array in m_cellColumns) {
				RemoveGridCell(cellColumn[r]);
				cellColumn.splice(r, 1);
			}
			
			if (!m_cellColumns[0].length) {
				while(m_cellColumns.length) {
					m_cellColumns.pop();
					m_cols--;
				}
			}
			
			m_rows--;
			
			SyncLocations(0, r);
		}
		
		
		/* ShiftColumns
		* shifts the columns of this grid columnsLeft to the left,
		* updates the objects in the gridcell, and the gridcell information
		*/
		private function ShiftColumns(columnsLeft:int):void {
			if (columnsLeft > 0) {
				for (var i:int = 0; i < columnsLeft; ++i) {
					m_cellColumns.push( m_cellColumns.shift() );
				}
			} else {
				for (i = 0; i < columnsLeft; ++i) {
					m_cellColumns.unshift( m_cellColumns.pop() );
				}
			}
			
			SyncLocations(0, 0);
		}
		
		/* ShiftRows
		* shifts the rows of this grid rowsUp up,
		* updates the objects in the gridcell, and the gridcell information
		*/
		private function ShiftRows(rowsUp:int):void {
			if (rowsUp > 0) {
				for (var i:int = 0; i < rowsUp; ++i) {
					for each (var cellColumn:Array in m_cellColumns) {
						cellColumn.push( cellColumn.shift() );
					}
				}
			} else {
				for (i = 0; i < rowsUp; ++i) {
					for each (cellColumn in m_cellColumns) {
						cellColumn.unshift( cellColumn.pop() );
					}
				}
			}
			
			SyncLocations(0, 0);
		}
		
		/* SyncLocations
		* syncronizes the gridcell and objects to the gridcell locations
		*/
		private function SyncLocations(cStart:int, rStart:int):void {
			
			for (var c:int = cStart; c < m_cols; ++c) {
				for (var r:int = rStart; r < m_rows; ++r) {
					var gridCell:Object = m_cellColumns[c][r];
					gridCell.col = c;
					gridCell.row = r;
					
					for each (var coverCell:Object in gridCell.coverCells) {
						m_tempDictionary[coverCell.cover] = true;
					}
				}
			}
			
			for (var cellCover:* in m_tempDictionary) {
				cellCover.SyncLocation();
				m_tempArray.push(cellCover);
			}
			
			while(m_tempArray.length) {
				delete m_tempDictionary[ m_tempArray.pop() ];
			}
		}
		
		/* ShrinkGrid
		* shrinks the grid down to the startcell and the endcell wide and high,
		* updates cell cols and rows and the total number of cols and rows
		*/
		public function ShrinkGrid(startCell:Object, endCell:Object):void {
			// remove all after, starting with columns, it will be easier to update
			// then remove before, and update each gridcell in toCols and toRows with the correct gridcell
			var startCol:int = startCell.col-1;
			var startRow:int = startCell.row-1;
			var endCol:int = endCell.col+1;
			var endRow:int = endCell.row+1; 
			
			if (endCol < startCol) {
				// work backwards so we dont get stuck
				for (var c:int = startCol; c > endCol; --c) {
					RemoveColumn(c);
				}
			} else {
				for (c = m_cols-1; c > endCol; --c) {
					RemoveColumn(c);
				}
				// now do the top and left, backwards as well
				for (c = startCol; c > -1; --c) {
					RemoveColumn(c);
				}
			}
			
			if (endRow < startRow) {
				for (var r:int = startRow; r > endRow; --r) {
					RemoveRow(r);
				}
				
			} else {
				for (r = m_rows-1; r > endRow ; --r) {
					RemoveRow(r);
				}
				
				for (r = startRow; r > -1; --r) {
					RemoveRow(r);
				}
				
			}			
			
		}
		
		/* ShiftGrid
		* shifts the grid so that the startCell is at the topLeft of the grid
		*/
		public function ShiftGrid(startCell:Object):void {
			ShiftColumns(startCell.col);
			ShiftRows(startCell.row);
		}
		
		/* GrowGrid
		* grows the grid by adding cols and rows to the ends of the grid,
		* used in the process of a new level,
		*/
		public function GrowGrid(numCols:int, numRows:int):void {
			// add rows first, because adding rows are slower when there are many columns
			AddRows(numRows);
			AddColumns(numCols);
		}
		
		/* RemoveGridCell
		* removes the grid cell's adjacent links
		* and places the grid cell on the stock.
		* Note, that this does not actually remove the cell from the array of cells,
		* and doesn't notify anything
		*/
		private function RemoveGridCell(gridCell:Object):void {
			
			while(gridCell.objects.length) {
				gridCell.objects[0].ReleaseGridCover();
			}
			
			if (gridCell.coverCells.length) {
				throw new Error("we still have a covercell that exists in the grid cell: " + gridCell.col + ", " + gridCell.row);
			}
			while(gridCell.coverCells.length) {
				gridCell.coverCells.pop();
			}
			
			var top:Object = gridCell.top;
			var bottom:Object = gridCell.bottom;
			var left:Object = gridCell.left;
			var right:Object = gridCell.right;
			
			if (gridCell.top) {
				gridCell.top.bottom = bottom;
			}
			if (gridCell.bottom) {
				gridCell.bottom.top = top;
			}
			if (gridCell.left) {
				gridCell.left.right = right;
			}
			if (gridCell.right) {
				gridCell.right.left = left;
			}
			
			gridCell.top = null;
			gridCell.bottom = null;
			gridCell.left = null;
			gridCell.right = null;
			
			if (!top || !bottom || !left || !right) {
				throw new Error("How can there exist a cell that doesn't have an end point!" + gridCell.col + ", " + gridCell.row);
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
		
		
		/* ClearGrid
		* Clears the grid of all grid objects only
		*/
		public function ClearGrid():void {
			var tempArray:Array = new Array();
			var columnLength:int = m_cellColumns.length;
			for (var c:int = 0; c < columnLength; ++c) {
				var rowLength:int = m_cellColumns[c].length;
				for (var r:int = 0; r < rowLength; ++r) {
					var gridCell:Object = m_cellColumns[c][r];
					
					var numObjects:int = gridCell.objects.length;
					for (var i:int = 0; i < numObjects; ++i) {
						tempArray[i] = gridCell.objects[i];
					}
					
					while(tempArray.length) {
						var go:CellGridObject = tempArray.pop();
						go.ReleaseGridCover();
					}
				}
			}
		}
		
		/* ChangeLevelStart
		* initiates the change level process for counting new tiles
		*/
		public function ChangeLevelStart(levelData:Object):void {
			m_levelData = levelData;
			m_level = m_levelData.level;
			m_levelCellCount = 0;
		}
		
		/* ChangeLevelFinish
		* completes the change level process by growing the grid and setting the defaults
		*/
		public function ChangeLevelFinish():void {
			
			var gridData:Object = m_levelData.gridData;
			
			m_gcDefaultData.drawType = gridData.defaultDrawType?gridData.defaultDrawType:c_drawTypeDefault;
			m_gcDefaultData.colorHigh = gridData.defaultColorHigh?gridData.defaultColorHigh:0xFFFFFF;
			m_gcDefaultData.colorLow = gridData.defaultColorLow?gridData.defaultColorLow:0x000000;
			m_gcDefaultData.libraryName = gridData.defaultLibraryName?gridData.defaultLibraryName:"PhysTilePattern";
			
			var cols:int = gridData.cols?gridData.cols:20;
			var rows:int = gridData.rows?gridData.rows:20;
			
			GrowGrid(cols - m_cols, rows - m_rows);
			
		}
		
		/* UpdateGridCell
		* updates a grid cell based on the new level
		*/
		public function UpdateGridCell(gridCell:Object):Boolean {
			if (Math.random()*10 < 1) {
				return true;
			}
			
			if (m_level && gridCell.level && (m_level != gridCell.level) ) {
				
				var gridData:Object = m_levelData.gridData;
				
				gridCell.drawType = gridData.defaultDrawType?gridData.defaultDrawType:c_drawTypeDefault;
				gridCell.colorHigh = gridData.defaultColorHigh?gridData.defaultColorHigh:0xFFFFFF;
				gridCell.colorLow = gridData.defaultColorLow?gridData.defaultColorLow:0x000000;
				gridCell.libraryName = gridData.defaultLibraryName?gridData.defaultLibraryName:"PhysTilePattern";
				
				gridCell.level = m_level;
				
				m_levelCellCount++;
				
				if (m_levelCellCount >= m_cols*m_rows) {
					return false;
				}
			}
			
			return true;
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
		public static function CreateGridDataFull(cols:int, 
		rows:int, 
		defaultDrawType:uint = c_drawTypeDefault,
		defaultColorHigh:uint = 0xFFFFFF,
		defaultColorLow:uint = 0x000000,
		defaultLibraryName:String = "PhysTilePattern"):Object {
			return {cols:cols, 
			rows:rows, 
			defaultDrawType:defaultDrawType,
			defaultColorHigh:defaultColorHigh,
			defaultColorLow:defaultColorLow,
			defaultLibraryName:defaultLibraryName};
		}
		
		public static function CreateGridData():Object {
			return {cols:c_defaultCols, rows:c_defaultRows};
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
			pStats.m_numGridCells = m_cols*m_rows;
			//pStats.m_numGridCells = m_cells.length;
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
			var testGrid:CellGrid = new CellGrid( CreateGridData() );
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
