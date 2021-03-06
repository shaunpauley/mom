﻿/*
 *
 * @author Shaun Pauley
 * @version 1.0
 */

package CellStuff {
	
	import flash.geom.Point;
	
	public class CellGridLocations extends CellGrid {
		
		private var m_cellWidth:Number;
		private var m_cellHeight:Number;
		
		private var m_gridWidth:Number;
		private var m_gridHeight:Number;
		
		private var m_gridWidthHalf:Number;
		private var m_gridHeightHalf:Number;
		
		// consts
		private static const c_defaultCellWidth:Number = 100.0;
		private static const c_defaultCellHeight:Number = 100.0;
		
		/* Constructor
		*/
		public function CellGridLocations(gridData:Object):void {
			super(gridData);
			
			// init
			m_cellWidth = gridData.cellWidth;
			m_cellHeight = gridData.cellHeight;
			
			m_gridWidth = m_cols*m_cellWidth;
			m_gridHeight = m_rows*m_cellHeight;
			
			m_gridWidthHalf = m_gridWidth/2;
			m_gridHeightHalf = m_gridHeight/2;
			
		}
		
		/* AddColumns
		* overrided to update the grid Width
		*/
		protected override function AddColumns(numColumns:int):void {
			super.AddColumns(numColumns);
			m_gridWidth = m_cols*m_cellWidth;
			m_gridWidthHalf = m_gridWidth/2;
		}
		
		/* AddRows
		* overrided to update the grid Height
		*/
		protected override function AddRows(numRows:int):void {
			super.AddRows(numRows);
			m_gridHeight = m_rows*m_cellHeight;
			m_gridHeightHalf = m_gridHeight/2;
		}
		
		/* RemoveColumn
		* overrided to update the grid Width
		*/
		protected override function RemoveColumn(c:int):void {
			super.RemoveColumn(c);
			m_gridWidth = m_cols*m_cellWidth;
			m_gridWidthHalf = m_gridWidth/2;
		}
		
		/* RemoveRow
		* overrided to update the grid Height
		*/
		protected override function RemoveRow(r:int):void {
			super.RemoveRow(r);
			m_gridHeight = m_rows*m_cellHeight;
			m_gridHeightHalf = m_gridHeight/2;
		}
		
		/* LocalToWorld
		* converts the point from local grid coordinates to world coordinates with respect
		* to the top left corner of the grid
		*/
		public function LocalToWorld(p:Point, col:int, row:int):Point {
			p.x += (col%m_cols)*m_cellWidth;
			p.y += (row%m_rows)*m_cellHeight;
			
			return p;
		}
		
		/* GetColFromWorld
		* returns the cell column position with respect to the world point,
		* even if the point is outside of the grid due to wrapping
		*/
		public function GetColFromWorld(p:Point):int {
			var col:int = Math.floor(p.x/m_cellWidth);
			while (col < 0) {
				col += m_cols;
			}
			
			return col%m_cols;
		}
		
		/* GetRowFromWorld
		* returns the cell row position from a world point
		*/
		public function GetRowFromWorld(p:Point):int {
			var row:int = Math.floor(p.y/m_cellHeight);
			while (row < 0) {
				row += m_rows;
			}
			
			return row%m_rows;
		}
		
		/* WorldToLocal
		* converts a world point to a local grid point, given the column and row
		*/
		public function WorldToLocal(p:Point, col:int, row:int):Point {
			p.x -= (col%m_cols)*m_cellWidth;
			p.y -= (row%m_rows)*m_cellHeight;
			
			return p;
		}
		
		/* CalculateDistanceVector
		* given the distance values, we can determine the shortest distance.
		* the result is a distance vector that must be entered into the method to preserve resuability
		*/
		public function CalculateDistanceVector(dv:Point, dx:Number, dy:Number):Point {
			var sign:int = dx<0?-1:1;
			
			if (dx*sign > m_gridWidthHalf) {
				dx = Math.min( (dx + m_gridWidth)*sign, (dx - m_gridWidth)*sign )*sign;
			}
			
			sign = dy<0?-1:1;
			
			if (dy*sign > m_gridHeightHalf) {
				dy = Math.min( (dy + m_gridHeight)*sign, (dy - m_gridHeight)*sign )*sign;
			}
			
			dv.x = dx;
			dv.y = dy;
			
			return dv;
		}
		
		/* CalculateDistanceVector_World
		* this method calculates the distance vector between worlds points point1 and point2.
		*/
		public function CalculateDistanceVector_World(dv:Point, p1:Point, p2:Point):Point {
			var dx:Number = p2.x - p1.x;
			var dy:Number = p2.y - p1.y;
			
			return CalculateDistanceVector(dv, dx, dy);
		}
		
		/* CalculateDistanceVector_Local
		* calculates the distance vector using local points
		*/
		public function CalculateDistanceVector_Local(dv:Point, p1:Point, col1:int, row1:int, p2:Point, col2:int, row2:int):Point {
			var dx:Number = p2.x - p1.x + (col2 - col1)*m_cellWidth;
			var dy:Number = p2.y - p1.y + (row2 - row1)*m_cellHeight;
			
			return CalculateDistanceVector(dv, dx, dy);
		}
		
		/* CalculateDistanceVector_CellToLocal
		* calculates the distance vector using a gridCell and local point
		*/
		public function CalculateDistanceVector_CellToLocal(dv:Point, cell:Object, p:Point, col:int, row:int):Point {
			var dx:Number = p.x + (col - cell.col)*m_cellWidth;
			var dy:Number = p.y + (row - cell.row)*m_cellHeight;
			
			return CalculateDistanceVector(dv, dx, dy);
		}
		
		/* CalculateDistancVector_WorldToGridObject
		* calculates the distance vector from a world point to a grid object
		*/
		public function CalculateDistancVector_WorldToGridObject(dv:Point, p:Point, go:CellGridObject):Point {
			var dx:Number = go.m_localPoint.x - p.x + go.m_col*m_cellWidth;
			var dy:Number = go.m_localPoint.y - p.y + go.m_row*m_cellHeight;
			
			return CalculateDistanceVector(dv, dx, dy);
		}
		
		public function CalculateDistanceVector_LocalToGridObject(dv:Point, p:Point, col:int, row:int, go:CellGridObject):Point {
			var dx:Number = go.m_localPoint.x - p.x + (go.m_col - col)*m_cellWidth;
			var dy:Number = go.m_localPoint.y - p.y + (go.m_row - row)*m_cellHeight;
			
			return CalculateDistanceVector(dv, dx, dy);
		}
		
		public function CalculateDistanceVector_GridObjects(dv:Point, go1:CellGridObject, go2:CellGridObject):Point {
			var dx:Number = go2.m_localPoint.x - go1.m_localPoint.x + (go2.m_col - go1.m_col)*m_cellWidth;
			var dy:Number = go2.m_localPoint.y - go1.m_localPoint.y + (go2.m_row - go1.m_row)*m_cellHeight;
			
			return CalculateDistanceVector(dv, dx, dy);
		}
		
		/* GetGridCellFromWorld
		* returns the grid cell from the world position
		*/
		public function GetGridCellFromWorld(p:Point):Object {
			var c:int = GetColFromWorld(p);
			var r:int = GetRowFromWorld(p);
			return GetGridCell(c, r);
		}
		
		/* GetGridWidth
		* returns the width of the entire grid
		*/
		public function GetGridWidth():Number {
			return m_gridWidth;
		}
		
		/* GetGridHeight
		* returns the height of the entire grid
		*/
		public function GetGridHeight():Number {
			return m_gridHeight;
		}
		
		/* GetGridWidthHalf
		* returns the half width length of the entire grid
		*/
		public function GetGridWidthHalf():Number {
			return m_gridWidthHalf;
		}
		
		/* GetGridHeightHalf
		* returns the half height length of the entire grid
		*/
		public function GetGridHeightHalf():Number {
			return m_gridHeightHalf;
		}
		
		/* GetCellWidth
		* returns the width of one cell
		*/
		public function GetCellWidth():Number {
			return m_cellWidth;
		}
		
		/* GetCellHeight
		* returns the height of one cell
		*/
		public function GetCellHeight():Number {
			return m_cellHeight;
		}
		
		/* CalculateWorld
		* prevents overflow
		*/
		public function CalculateWorld(p:Point):Point {
			if (p.x < 0) {
				p.x += m_gridWidth;
			} else if (p.x >= m_gridWidth) {
				p.x -= m_gridWidth;
			}
			
			if (p.y < 0) {
				p.y += m_gridWidth;
			} else if (p.y >= m_gridHeight) {
				p.y -= m_gridHeight;
			}
			
			return p;
		}
		
		public function CalculateGridObjectLocal(go:CellGridObject):void {
			MoveGridObject(go, 0, 0);
		}
		
		/* MoveGridObject
		* moves a grid object localy
		* I wonder if this is slower than a world conversion
		*/
		public function MoveGridObject(go:CellGridObject, dx:Number, dy:Number):void {
			go.m_localPoint.x += dx;
			while (go.m_localPoint.x < 0) {
				go.m_localPoint.x += m_cellWidth;
				go.m_col--;
				if (go.m_col < 0) {
					go.m_col += m_cols;
				}
			}
			while (go.m_localPoint.x > m_cellWidth) {
				go.m_localPoint.x -= m_cellWidth;
				go.m_col++;
				if (go.m_col >= m_cols) {
					go.m_col -= m_cols;
				}
			}
			
			go.m_localPoint.y += dy;
			while (go.m_localPoint.y < 0) {
				go.m_localPoint.y += m_cellHeight;
				go.m_row--;
				if (go.m_row < 0) {
					go.m_row += m_rows;
				}
			}
			while (go.m_localPoint.y > m_cellHeight) {
				go.m_localPoint.y -= m_cellHeight;
				go.m_row++;
				if (go.m_row >= m_rows) {
					go.m_row -= m_rows;
				}
			}
			
		}
		
		/* ShrinkGrid
		* shrinks the grid down to the startcell and the endcell.
		* this override updates the grid dimensions
		*/
		public override function ShrinkGrid(startCell:Object, endCell:Object):void {
			super.ShrinkGrid(startCell, endCell);
			
			m_gridWidth = m_cols*m_cellWidth;
			m_gridHeight = m_rows*m_cellHeight;
			
			m_gridWidthHalf = m_gridWidth/2;
			m_gridHeightHalf = m_gridHeight/2;
			
		}
		
		
		/*
		* GridDataObject
		*/
		public static function UpdateGridLocationsDataFull(gridData:Object, cellWidth:Number, cellHeight:Number):Object {
			gridData.cellWidth = cellWidth;
			gridData.cellHeight = cellHeight;
			return gridData;
		}
		
		public static function GenerateGridLocationsDataDefaults(gridData:Object):Object {
			gridData.cellWidth = c_defaultCellWidth;
			gridData.cellHeight = c_defaultCellHeight;
			return gridData;
		}
		
		public static function CreateGridLocationsData():Object {
			return UpdateGridLocationsDataFull( CellGrid.CreateGridData(), c_defaultCellWidth, c_defaultCellWidth );
		}
		
		/* UpdatePerformanceStatistics
		*/
		public override function UpdatePerformanceStatistics(pStats:CellPerformanceStatistics):CellPerformanceStatistics {
			pStats.m_gridCellWidth = m_cellWidth;
			pStats.m_gridCellHeight = m_cellHeight;
			
			pStats.m_gridWidth = m_gridWidth;
			pStats.m_gridHeight = m_gridHeight;
			
			return super.UpdatePerformanceStatistics(pStats);
		}
		
		// debug
		public override function ToString():String {
			var str:String = "CellGridLocations: " + m_cellWidth + ", " + m_cellHeight + "\n";
			str += "\t" + m_gridWidth + ", " + m_gridHeight + "\n";
			str += "\t" + m_gridWidthHalf + ", " + m_gridHeightHalf + "\n";
			
			return str + super.ToString();
		}
		
		// unit tests
		public static function UnitTest():void {
			trace("***BEGIN CellGridLocations UNIT TEST***");
			var testGrid:CellGridLocations = new CellGridLocations( CreateGridLocationsData() );
			trace("TEST 1) INIT");
			trace(testGrid.ToString());
			
			trace("TEST 2) LOCALTOWORLD TEST: (20, 20), 3, 3");
			var p:Point = new Point(20, 20);
			var c:int = 3;
			var r:int = 3;
			testGrid.LocalToWorld(p, c, r);
			trace("\tp: " + p.x + ", " + p.y);
			
			trace("TEST 3) GETCOL/ROWFROMWORLD, should be the same as in 2");
			c = testGrid.GetColFromWorld(p);
			r = testGrid.GetRowFromWorld(p);
			trace("\tc: " + c + ", r: " + r);
			
			trace("TEST 4) WORLDTOLOCAL, should be the same as in 2");
			testGrid.WorldToLocal(p, c, r);
			trace("\tp: " + p.x + ", " + p.y);
			
			trace("TEST 5) CALCULATE DISTANCE VECTOR: P1(5, 5), 3, 3 -> P2(5, 5), 4, 5");
			var p1:Point = new Point(5, 5);
			var c1:int = 3;
			var r1:int = 3;
			
			var p2:Point = new Point(5, 5);
			var c2:int = 4;
			var r2:int = 5;
			
			var dv:Point = new Point();
			testGrid.CalculateDistanceVector_Local(dv, p1, c1, r1, p2, c2, r2);
			trace("\t: " + dv.x + ", " + dv.y);
			
			trace("TEST 6) CALCULATE DISTANCE VECTOR: P1(0, 0), 0, 0 -> P2(width, height), endcol, endrow");
			p1 = new Point(0, 0);
			c1 = 0;
			r1 = 0;
			
			p2 = new Point(testGrid.m_cellWidth-1, testGrid.m_cellHeight-1);
			c2 = testGrid.m_cols-1;
			r2 = testGrid.m_rows-1;
			
			dv = new Point();
			testGrid.CalculateDistanceVector_Local(dv, p1, c1, r1, p2, c2, r2);
			trace("\t: " + dv.x + ", " + dv.y);
			
			trace("TEST 7) CALCULATE DISTANCE VECTOR: P1(20, 20), 2, 3 -> P2(40, 40), 7, 8");
			p1 = new Point(20, 20);
			c1 = 2;
			r1 = 3;
			
			p2 = new Point(40, 40);
			c2 = 7;
			r2 = 8;
			
			dv = new Point();
			testGrid.CalculateDistanceVector_Local(dv, p1, c1, r1, p2, c2, r2);
			trace("\t: " + dv.x + ", " + dv.y);
			
			trace("TEST 8) GET COL/ROW FROM WORLD: P(5, 5)");
			p = new Point(5, 5);
			c = testGrid.GetColFromWorld(p);
			r = testGrid.GetRowFromWorld(p);
			trace("\t: " + c + ", " + r);
			
			trace("***END CellGrid UNIT TEST***");
		}
		
	}	
}
