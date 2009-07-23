/*
 *
 * @author Shaun Pauley
 * @version 1.0
 */
package CellStuff {
	
	import flash.display.Sprite;
	
	import flash.geom.Point;
	
	public class CellGridViewer extends Sprite {
		
		private var m_cellGrid:CellGridLocations;
		
		private var m_startPoint:Point;
		private var m_viewerWidth:Number;
		private var m_viewerHeight:Number;
		
		private var m_startCell:Object;
		private var m_startOffset:Point;
		
		private var m_cols:int;
		private var m_rows:int;
		
		private var m_tiles:Array;
		private var m_stockTiles:Array;
		
		// consts
		private static const c_defaultWidth:Number = 550;
		private static const c_defaultHeight:Number = 550;
		
		/* Constructor
		*/
		public function CellGridViewer(viewerData:Object):void {
			m_cellGrid = viewerData.cellGrid;
			
			m_startPoint = m_cellGrid.CalculateWorld( viewerData.start );
			m_viewerWidth = viewerData.width;
			m_viewerHeight = viewerData.height;
			
			m_startCell = m_cellGrid.GetGridCellFromWorld(m_startPoint);
			
			m_startOffset = m_cellGrid.LocalToWorld(new Point(0, 0), m_startCell.col, m_startCell.row);
			m_startOffset = m_cellGrid.CalculateDistanceVector_World(m_startOffset, m_startPoint, m_startOffset);
			
			m_cols = Math.ceil( (m_viewerWidth - m_startOffset.x) / m_cellGrid.GetCellWidth() );
			m_rows = Math.ceil( (m_viewerHeight - m_startOffset.y) / m_cellGrid.GetCellHeight() );
			
			m_tiles = new Array();
			m_stockTiles = new Array();
			
			CreateTiles();
		}
		
		/* CreateTiles
		* creates all the tiles for initial startup
		*/
		private function CreateTiles():void {
			var currentRowCell:Object = m_startCell;
			
			for (var r:int = 0; r < m_rows; ++r) {
				var currentCell:Object = currentRowCell;
				for (var c:int = 0; c < m_cols; ++c) {
					CreateTile(currentCell, c, r);
					currentCell = currentCell.right;
				}
				currentRowCell = currentRowCell.bottom;
			}
		}
		
		/* CreateTile
		* creates a tile if there doesn't exit one already in the stock
		*/
		private function CreateTile(gridCell:Object, c:int, r:int):Object {
			if (m_stockTiles.length) {
				var tile:Object = m_stockTiles.pop();
			} else {
				tile = {cell:gridCell, sprite:new Sprite()};
			}
			
			tile.sprite.x = r * m_cellGrid.GetCellWidth() + m_startOffset.x;
			tile.sprite.y = c * m_cellGrid.GetCellHeight() + m_startOffset.y;
			
			if (CellWorld.c_debug) {
				DrawTileBorder(tile);
			}
			
			addChild(tile.sprite);
			
			m_tiles[c+r*m_cols] = tile;
			
			return tile;
		}
		
		// debug
		private function DrawTileBorder(tile:Object):void {
			tile.sprite.graphics.clear();
			tile.sprite.graphics.lineStyle(1, uint(Math.random()*0xFFFFFF));
			tile.sprite.graphics.moveTo(0, 0);
			tile.sprite.graphics.lineTo(m_cellGrid.GetCellWidth(), 0);
			tile.sprite.graphics.lineTo(m_cellGrid.GetCellWidth(), m_cellGrid.GetCellHeight());
			tile.sprite.graphics.lineTo(0, m_cellGrid.GetCellHeight());
			tile.sprite.graphics.lineTo(0, 0);
		}
		
		public function ToString():String {
			var str:String = "CellGridViewer:\n";
			str += "\tsp:" + m_startPoint.x + ", " + m_startPoint.y + "\n";
			str += "\twh:" + m_viewerWidth + ", " + m_viewerHeight + "\n";
			str += "\tcr:" + m_cols + ", " + m_rows + "\n";
			str += "\tso:" + m_startOffset.x + ", " + m_startOffset.y + "\n";
			return str;
		}
		
		/* CreateViewerDataObject
		*/
		public static function CreateViewerDataFull(cellGrid:CellGridLocations, start:Point, w:Number, h:Number):Object {
			return {cellGrid:cellGrid, start:start, width:w, height:h};
		}
		
		public static function CreateViewerData():Object {
			var cellGrid:CellGridLocations = new CellGridLocations( CellGridLocations.CreateGridLocationsData() );
			var widthHalf:Number = cellGrid.GetGridWidthHalf();
			var heightHalf:Number = cellGrid.GetGridHeightHalf();
			
			var start:Point = new Point(widthHalf - c_defaultWidth/2, heightHalf - c_defaultHeight/2);
			
			return CreateViewerDataFull(cellGrid, start, c_defaultWidth, c_defaultHeight);
		}
		
		// unit tests
		public static function UnitTest(sprite:Sprite):void {
			trace("***BEGIN CellGridViewer UNIT TEST***");
			var testViewer:CellGridViewer = new CellGridViewer( CreateViewerData() );
			sprite.addChild(testViewer);
			trace("TEST 1) INIT");
			trace(testViewer.ToString());
			trace("***END CellGridViewer UNIT TEST***");
		}
	}
}