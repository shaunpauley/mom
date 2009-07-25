/*
 *
 * @author Shaun Pauley
 * @version 1.0
 */
package CellStuff {
	
	import flash.display.Sprite;
	
	import flash.geom.Point;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class CellGridViewer extends Sprite {
		
		private var m_cellGrid:CellGridLocations;
		
		private var m_viewerWidth:Number;
		private var m_viewerHeight:Number;
		
		private var m_cellWidth:Number;
		private var m_cellHeight:Number;
		
		private var m_startOffset:Point;
		private var m_endOffset:Point;
		
		private var m_stockTiles:Array;
		
		private var m_topLeft:Object;
		private var m_topRight:Object;
		private var m_bottomLeft:Object;
		private var m_bottomRight:Object;
		
		// consts
		private static const c_defaultWidth:Number = 0;
		private static const c_defaultHeight:Number = 0;
		
		/* Constructor
		*/
		public function CellGridViewer(viewerData:Object):void {
			m_cellGrid = viewerData.cellGrid;
			
			m_viewerWidth = 0;
			m_viewerHeight = 0;
			
			m_cellWidth = m_cellGrid.GetCellWidth();
			m_cellHeight = m_cellGrid.GetCellHeight();
			
			var startPoint:Point = m_cellGrid.CalculateWorld( viewerData.start );
			var startCell:Object = m_cellGrid.GetGridCellFromWorld(startPoint);
			
			m_startOffset = m_cellGrid.WorldToLocal(startPoint, startCell.col, startCell.row);
			m_endOffset = m_startOffset.clone();
			
			m_stockTiles = new Array();
			
			x = 0;
			y = 0;
			
			CreateTiles(startCell, viewerData.width, viewerData.height);
		}
		
		/* CreateTiles
		* creates all the tiles for the viewer.
		* This is done by creating one tile and growing the viewer to the desired size
		*/
		private function CreateTiles(startCell:Object, W:Number, H:Number):void {
			m_topLeft = CreateTile(startCell, -m_startOffset.x, -m_startOffset.y);
			m_topRight = m_topLeft;
			m_bottomLeft = m_topLeft;
			m_bottomRight = m_topLeft;
			
			// grow
			GrowViewer(W/2, H/2);
			
		}
		
		/* CreateTile 
		* using a stock array we can preserve deleted grid cells in the case where we need
		* to grow and shrink the grid cells rapidly
		*/
		private function CreateTile(gridCell:Object, X:Number, Y:Number,
		top:Object = null,
		bottom:Object = null,
		left:Object = null,
		right:Object = null):Object {
			
			if (m_stockTiles.length) {
				var tile:Object = m_stockTiles.pop();
				tile.cell = gridCell;
				tile.x = X;
				tile.y = Y;
			} else {
				tile = {cell:gridCell, x:X, y:Y, sprite:new Sprite()};
			}
			
			tile.top = top;
			tile.bottom = bottom;
			tile.left = left;
			tile.right = right;
			
			if (top) {
				top.bottom = tile;
			}
			if (bottom) {
				bottom.top = tile;
			}
			if (left) {
				left.right = tile;
			}
			if (right) {
				right.left = tile;
			}
			
			tile.sprite.x = X;
			tile.sprite.y = Y;
			
			if (CellWorld.c_debug) {
				DrawTileBorder(tile);
			}
			
			addChild(tile.sprite);
			
			return tile;
		}
		
		/* MoveStartOffset
		* moves our start offset and determines what to add or remove from the edges of the grid.
		* This is ultimately used to grow, shrink, and shift the grid
		*/
		private function MoveStartOffset(dx:Number, dy:Number):void {
			m_startOffset.x += dx;
			while (m_startOffset.x < 0) {
				AddColumnTiles(m_topLeft);
				m_topLeft = m_topLeft.left;
				m_bottomLeft = m_bottomLeft.left;
				m_startOffset.x += m_cellWidth;
				
			}
			while (m_startOffset.x > m_cellWidth) {
				if (!m_topLeft.right || !m_bottomLeft.right) {
					break;
				}
				var tempTile1:Object = m_topLeft.right;
				var tempTile2:Object = m_bottomLeft.right;
				RemoveColumnTiles(m_topLeft);
				m_topLeft = tempTile1;
				m_bottomLeft = tempTile2;
				m_startOffset.x -= m_cellWidth;
			}
			
			m_startOffset.y += dy;
			while (m_startOffset.y < 0) {
				AddRowTiles(m_topLeft);
				m_topLeft = m_topLeft.top;
				m_topRight = m_topRight.top;
				m_startOffset.y += m_cellHeight;
				
			}
			while (m_startOffset.y > m_cellHeight) {
				if (!m_topRight.bottom || !m_topLeft.bottom) {
					break;
				}
				tempTile1 = m_topRight.bottom;
				tempTile2 = m_topLeft.bottom;
				RemoveRowTiles(m_topLeft);
				m_topRight = tempTile1;
				m_topLeft = tempTile2;
				m_startOffset.y -= m_cellHeight;
			}
			
		}
		
		/* MoveEndOffset
		* moving the end offset can grow, shrink, or shift the grid
		*/
		private function MoveEndOffset(dx:Number, dy:Number):void {
			m_endOffset.x += dx;
			while (m_endOffset.x > m_cellWidth) {
				AddColumnTiles(m_topRight, false);
				m_topRight = m_topRight.right;
				m_bottomRight = m_bottomRight.right;
				m_endOffset.x -= m_cellWidth;
				
			}
			while (m_endOffset.x < 0) {
				if (!m_topRight.left || !m_bottomRight.left) {
					break;
				}
				var tempTile1:Object = m_topRight.left;
				var tempTile2:Object = m_bottomRight.left;
				RemoveColumnTiles(m_topRight);
				m_topRight = tempTile1;
				m_bottomRight = tempTile2;
				m_endOffset.x += m_cellWidth;
			}
			
			m_endOffset.y += dy;
			while (m_endOffset.y > m_cellHeight) {
				AddRowTiles(m_bottomLeft, false);
				m_bottomLeft = m_bottomLeft.bottom;
				m_bottomRight = m_bottomRight.bottom;
				m_endOffset.y -= m_cellHeight;
				
			}
			while (m_endOffset.y < 0) {
				if (!m_bottomRight.top || !m_bottomLeft.top) {
					break;
				}
				tempTile1 = m_bottomRight.top;
				tempTile2 = m_bottomLeft.top;
				RemoveRowTiles(m_bottomLeft);
				m_bottomRight = tempTile1;
				m_bottomLeft = tempTile2;
				m_endOffset.y += m_cellHeight;
			}
			
		}
		
		/* AddColumnTiles
		* add a column of tiles starting at currentTile and to the left if not specified
		*/
		private function AddColumnTiles(currentTile:Object, isLeft:Boolean = true):void {
			var previousTile:Object = null;
			
			while (currentTile) {
				
				if (isLeft) {
					currentTile.left = CreateTile(currentTile.cell.left, currentTile.x - m_cellWidth, currentTile.y, 
					previousTile, null, null, currentTile);
					previousTile = currentTile.left;
				} else {
					currentTile.right = CreateTile(currentTile.cell.right, currentTile.x + m_cellWidth, currentTile.y, 
					previousTile, null, currentTile);
					previousTile = currentTile.right;
				}
				
				currentTile = currentTile.bottom;
			}
			
		}
		
		/* AddRowTiles
		* adds a row of tiles starting at the currentTile and to the top if not specified
		*/
		private function AddRowTiles(currentTile:Object, isTop:Boolean = true):void {
			var previousTile:Object = null;
			
			while (currentTile) {
				
				if (isTop) {
					currentTile.top = CreateTile(currentTile.cell.top, currentTile.x, currentTile.y - m_cellHeight, 
					null, currentTile, previousTile);
					previousTile = currentTile.top;
				} else {
					currentTile.bottom = CreateTile(currentTile.cell.bottom, currentTile.x, currentTile.y + m_cellHeight, 
					currentTile, null, previousTile);
					previousTile = currentTile.bottom;
				}					
				
				currentTile = currentTile.right;
			}
		}
		
		/* RemoveColumnTiles
		* remove a column of tiles, moving down
		*/
		private function RemoveColumnTiles(currentTile:Object):void {
			while(currentTile) {
				var nextTile:Object = currentTile.bottom;
				RemoveTile(currentTile);
				currentTile = nextTile;
			}
		}
		
		/* RemoveRowTiles
		* removes a row of tiles, moving right
		*/
		private function RemoveRowTiles(currentTile:Object):void {
			while(currentTile) {
				var nextTile:Object = currentTile.right;
				RemoveTile(currentTile);
				currentTile = nextTile
			}
		}
		
		/* GrowViewer
		* grows the viewer and adds new tiles if necessary
		*/
		public function GrowViewer(widthAmountHalf:Number, heightAmountHalf:Number):void {
			
			MoveStartOffset(-widthAmountHalf, -heightAmountHalf);
			MoveEndOffset(widthAmountHalf, heightAmountHalf);
			
			m_viewerWidth += widthAmountHalf*2;
			m_viewerHeight += heightAmountHalf*2;
			
			if (CellWorld.c_debug) {
				Draw();
			}
			
		}
		
		/* ShrinkViewer
		* shrinks the viewer, and removes cells if needed.
		*/
		public function ShrinkViewer(widthAmountHalf:Number, heightAmountHalf:Number):void {
			GrowViewer(-widthAmountHalf, -heightAmountHalf);
		}
		
		/* RemoveGridTile
		* frees a grid cell and puts it into the stock so it can be flushed later.
		* (This is sort of a a way to control Garbage Collecting, and may be useful later)
		*/
		private function RemoveTile(tile:Object):void {
			if (tile.top) {
				tile.top.bottom = tile.bottom;
			}
			
			if (tile.bottom) {
				tile.bottom.top = tile.top;
			}
			
			if (tile.left) {
				tile.left.right = tile.right;
			}
			
			if (tile.right) {
				tile.right.left = tile.left;
			}
			
			tile.top = null;
			tile.bottom = null;
			tile.left = null;
			tile.right = null;
			
			tile.sprite.graphics.clear();
			while(tile.sprite.numChildren) {
				tile.sprite.removeChild(tile.sprite.getChildAt(0));
			}
			removeChild(tile.sprite);
			
			m_stockTiles.push(tile);
		}
		
		/* ShiftTiles
		* shifts all the tiles by X and Y pixels
		*/
		private function ShiftTiles(dx:Number, dy:Number):void {
			var currentRowTile:Object = m_topLeft;
			
			while(currentRowTile) {
				var currentTile:Object = currentRowTile;
				while(currentTile) {
					currentTile.x += dx;
					currentTile.y += dy;
					
					currentTile.sprite.x = currentTile.x;
					currentTile.sprite.y = currentTile.y;
					
					currentTile = currentTile.right;
				}
				currentRowTile = currentRowTile.bottom;
			}
		}
		
		/* MoveViewer
		* moves the tiles under the viewer and maintains the view
		*/
		public function MoveViewer(dx:Number, dy:Number):void {
			ShiftTiles(-dx, -dy);
			
			MoveStartOffset(dx, dy);
			MoveEndOffset(dx, dy);
		}
		
		// debug
		private function DrawTileBorder(tile:Object):void {
			tile.sprite.graphics.clear();
			
			var randomColor:uint = uint(Math.random()*0xFFFFFF);
			
			//tile.sprite.graphics.beginFill(0x000000);
			tile.sprite.graphics.lineStyle(1, randomColor);
			tile.sprite.graphics.moveTo(0, 0);
			tile.sprite.graphics.lineTo(m_cellGrid.GetCellWidth(), 0);
			tile.sprite.graphics.lineTo(m_cellGrid.GetCellWidth(), m_cellGrid.GetCellHeight());
			tile.sprite.graphics.lineTo(0, m_cellGrid.GetCellHeight());
			tile.sprite.graphics.lineTo(0, 0);
			//tile.sprite.graphics.endFill();
			
			var tf:TextField = new TextField();
			tf.x = 0;
			tf.y = 0;
			tf.autoSize = TextFieldAutoSize.LEFT;
			var format:TextFormat = new TextFormat();
			format.font = "Courier New";
			format.color = randomColor;
			format.size = 10;
			tf.defaultTextFormat = format;
			tf.selectable = false;
			tf.text = String(tile.cell.id);
			
			tile.sprite.addChild(tf);
		}
		
		private function Draw():void {
			var startX:Number = m_topLeft.x + m_startOffset.x;
			var startY:Number = m_topLeft.y + m_startOffset.y;
			
			graphics.clear();
			graphics.lineStyle(2, 0xFFFFFF);
			graphics.moveTo(startX, startY);
			graphics.lineTo(startX + m_viewerWidth, startY);
			graphics.lineTo(startX + m_viewerWidth, startY + m_viewerHeight);
			graphics.lineTo(startX, startY + m_viewerHeight);
			graphics.lineTo(startX, startY);
			
		}
		
		public function ToString():String {
			var str:String = "CellGridViewer:\n";
			str += "\twh:" + m_viewerWidth + ", " + m_viewerHeight + "\n";
			str += "\tso:" + m_startOffset.x + ", " + m_startOffset.y + "\n";
			str += "\teo:" + m_endOffset.x + ", " + m_endOffset.y + "\n";
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
		
		/* CreateViewerDataObject
		*/
		public static function CreateViewerDataFull(cellGrid:CellGridLocations, start:Point, w:Number, h:Number):Object {
			return {cellGrid:cellGrid, start:start, width:w, height:h};
		}
		
		public static function CreateViewerData():Object {
			var cellGrid:CellGridLocations = new CellGridLocations( CellGridLocations.CreateGridLocationsData() );
			var widthHalf:Number = cellGrid.GetGridWidthHalf();
			var heightHalf:Number = cellGrid.GetGridHeightHalf();
			
			//var start:Point = new Point(widthHalf - c_defaultWidth/2, heightHalf - c_defaultHeight/2);
			var start:Point = new Point(widthHalf, heightHalf);
			
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