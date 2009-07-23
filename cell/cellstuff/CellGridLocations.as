/*
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
		private static const c_defaultCellWidth:Number = 50.0;
		private static const c_defaultCellHeight:Number = 50.0;
		
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
		
		/* localToWorld
		* converts the point from local grid coordinates to world coordinates with respect
		* to the top left corner of the grid
		*/
		public function localToWorld(p:Point, col:int, row:int):Point {
			p.x += (col%m_cols)*m_cellWidth;
			p.y += (row&m_rows)*m_cellHeight;
			
			return p;
		}
		
		/* GetColFromWorld
		* returns the cell column position with respect to the world point,
		* even if the point is outside of the grid due to wrapping
		*/
		public function GetColFromWorld(p:Point):int {
			return (p.x/m_cellWidth)%m_cols;
		}
		
		/* GetRowFromWorld
		* returns the cell row position from a world point
		*/
		public function GetRowFromWorld(p:Point):int {
			return (p.y/m_cellHeight)%m_rows;
		}
		
		/* worldToLocal
		* converts a world point to a local grid point, given the column and row
		*/
		public function worldToLocal(p:Point, col:int, row:int):Point {
			p.x -= (col%m_cols)*m_cellWidth;
			p.y -= (row%m_rows)*m_cellHeight;
			
			return p;
		}
		
		/* CalculateDistanceVector
		* this method calculates the distance vector between point1 and point2.
		* the result is a distance vector that must be entered into the method to preserve resuability
		*/
		public function CalculateDistanceVector(dv:Point, p1:Point, col1:int, row1:int, p2:Point, col2:int, row2:int):Point {
			var dx:Number = p2.x - p1.x + (col2 - col1)*m_cellWidth;
			var sign:int = dx<0?-1:1;
			
			if (dx*sign > m_gridWidthHalf) {
				dx = Math.min( (dx + m_gridWidth)*sign, (dx - m_gridWidth)*sign )*sign;
			}
			
			var dy:Number = p2.y - p1.y + (row2 - row1)*m_cellHeight;
			sign = dy<0?-1:1;
			
			if (dy*sign > m_gridHeightHalf) {
				dy = Math.min( (dy + m_gridHeight)*sign, (dy - m_gridHeight)*sign )*sign;
			}
			
			dv.x = dx;
			dv.y = dy;
			
			return dv;
		}
		
		/*
		* GridDataObject
		*/
		public static function UpdateGridLocationsDataFull(gridData:Object, cellWidth:Number, cellHeight:Number):Object {
			gridData.cellWidth = cellWidth;
			gridData.cellHeight = cellHeight;
			return gridData;
		}
		
		public static function CreateGridLocationsData():Object {
			return UpdateGridLocationsDataFull( CellGrid.CreateGridData(), c_defaultCellWidth, c_defaultCellWidth );
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
			testGrid.localToWorld(p, c, r);
			trace("\tp: " + p.x + ", " + p.y);
			
			trace("TEST 3) GETCOL/ROWFROMWORLD, should be the same as in 2");
			c = testGrid.GetColFromWorld(p);
			r = testGrid.GetRowFromWorld(p);
			trace("\tc: " + c + ", r: " + r);
			
			trace("TEST 4) WORLDTOLOCAL, should be the same as in 2");
			testGrid.worldToLocal(p, c, r);
			trace("\tp: " + p.x + ", " + p.y);
			
			trace("TEST 5) CALCULATE DISTANCE VECTOR: P1(20, 20), 3, 3 -> P2(5, 5), 6, 8");
			var p1:Point = new Point(20, 20);
			var c1:int = 3;
			var r1:int = 3;
			
			var p2:Point = new Point(40, 40);
			var c2:int = 6;
			var r2:int = 8;
			
			var dv:Point = new Point();
			testGrid.CalculateDistanceVector(dv, p1, c1, r1, p2, c2, r2);
			trace("\t: " + dv.x + ", " + dv.y);
			
			trace("TEST 6) CALCULATE DISTANCE VECTOR: P1(0, 0), 0, 0 -> P2(width, height), endcol, endrow");
			p1 = new Point(0, 0);
			c1 = 0;
			r1 = 0;
			
			p2 = new Point(testGrid.m_cellWidth-1, testGrid.m_cellHeight-1);
			c2 = 9;
			r2 = 9;
			
			dv = new Point();
			testGrid.CalculateDistanceVector(dv, p1, c1, r1, p2, c2, r2);
			trace("\t: " + dv.x + ", " + dv.y);
			
			trace("***END CellGrid UNIT TEST***");
		}
		
	}	
}
