/*
 *
 * @author Shaun Pauley
 * @version 1.0
 */
package CellStuff {
	
	import flash.display.Sprite;
	
	import flash.geom.Point;
	
	import flash.events.Event;
	
	public class CellGridViewer extends Sprite {
		
		private var m_focusGridObject:CellGridObject;
		
		private var m_bottomLayer:Sprite;
		private var m_gridLayer:Sprite;
		private var m_objectLayer:Sprite;
		private var m_topLayer:Sprite;
		
		private var m_bitmapManager:CellBitmapManager;
		
		private var m_viewCover:CellViewCover;
		
		/* Constructor
		*/
		public function CellGridViewer(viewerData:Object):void {
			
			m_focusGridObject =  viewerData.focus;
			
			x = 0;
			y = 0;
			
			m_bottomLayer = CreateAndAddLayer();
			m_gridLayer = CreateAndAddLayer();
			m_objectLayer = CreateAndAddLayer();
			m_topLayer = CreateAndAddLayer();
			
			viewerData.coverData.viewer = this;
			
			m_bitmapManager = new CellBitmapManager();
			
			m_viewCover = new CellViewCover(viewerData.coverData, m_bitmapManager);
			
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
			
		}
		
		/* Update
		* called on ENTER_FRAME,
		*/
		private function Update(event:Event):void {
			if (m_focusGridObject) {
				var dv:Point = m_viewCover.GetDistanceToGridObject(m_focusGridObject);
				var dx:Number = Math.abs(dv.x);
				var dy:Number = Math.abs(dv.y);
				var halfWidth:Number = m_viewCover.GetWidth()/2;
				var halfHeight:Number = m_viewCover.GetHeight()/2;
				
				if ( (dx > halfWidth*0.1) || (dy > halfHeight*0.1) ) {
					var lengthInverse:Number = 1/dv.length;
					var moveX:Number = dv.x*lengthInverse*m_focusGridObject.m_maxSpeed*(dx*3/halfWidth);
					var moveY:Number = dv.y*lengthInverse*m_focusGridObject.m_maxSpeed*(dy*3/halfHeight);
					MoveViewer(moveX, moveY);
				}
				
			}
		}
		
		/* CreateAndAddLayer
		* createsa a layer and adds it to the viewer
		*/
		private function CreateAndAddLayer():Sprite {
			var layer:Sprite = new Sprite();
			layer.x = 0;
			layer.y = 0;
			addChild(layer);
			
			return layer;
		}
		
		/* GrowViewer
		* wrapper for grow cover
		*/
		public function GrowViewer(dx:Number, dy:Number):void {
			m_viewCover.GrowCover(dx, dy);
		}
		
		/* ShrinkViewer
		* wrapper for shrink cover
		*/
		public function ShrinkViewer(dx:Number, dy:Number):void {
			m_viewCover.ShrinkCover(dx, dy);
		}
		
		/* MoveViewer
		* wrapper for move viewer
		*/
		public function MoveViewer(dx:Number, dy:Number):void {
			m_viewCover.MoveCover(dx, dy);
		}
		
		/* AddGridTile
		* adds a sprite tile to the grid layer
		*/
		public function AddGridTile(sprite:Sprite):void {
			m_gridLayer.addChild(sprite);
		}
		
		/* RemoveGridTile
		* removes a sprite tile from the grid layer
		*/
		public function RemoveGridTile(sprite:Sprite):void {
			m_gridLayer.removeChild(sprite);
		}
		
		/* AddObjectTile
		* adds a sprite tile to the object layer
		*/
		public function AddObjectTile(sprite:Sprite):void {
			m_objectLayer.addChild(sprite);
		}
		
		/* RemoveObjectTile
		* removes a sprite tile from the object layer
		*/
		public function RemoveObjectTile(sprite:Sprite):void {
			m_objectLayer.removeChild(sprite);
		}
		
		/* TopLayer
		* access to the top layer
		*/
		public function TopLayer():Sprite {
			return m_topLayer;
		}
		
		/* BottomLayer
		* access to the bottom layer
		*/
		public function BottomLayer():Sprite {
			return m_bottomLayer;
		}
		
		/* SetFocusGridObject
		* sets so that the focus of the viewer should be on a grid object
		*/
		public function SetFocusGridObject(go:CellGridObject):void {
			m_focusGridObject = go;
		}
		
		/* GetWidth
		* returns the viewer width
		*/
		public function GetWidth():Number {
			return m_viewCover.GetWidth();
		}
		
		/* GetHeight
		* returns the viewer height
		*/
		public function GetHeight():Number {
			return m_viewCover.GetHeight();
		}
		
		/* UpdatePerformanceStatistics
		*/
		public function UpdatePerformanceStatistics(pStats:CellPerformanceStatistics):CellPerformanceStatistics {
			pStats = m_bitmapManager.UpdatePerformanceStatistics(pStats);
			
			return m_viewCover.UpdatePerformanceStatistics(pStats);
		}
		
		// debug
		public function ToString():String {
			return m_viewCover.ToString();
		}
		
		/* CreateViewerDataObject
		*/
		public static function CreateViewerData(cellGrid:CellGridLocations):Object {
			
			return {coverData:CellViewCover.CreateViewCoverData(cellGrid), focus:null};
		}
		
		// unit tests
		public static function UnitTest(sprite:Sprite):void {
			trace("***BEGIN CellGridViewer UNIT TEST***");
			var testViewer:CellGridViewer = new CellGridViewer( CreateViewerData( new CellGridLocations(CellGridLocations.CreateGridLocationsData()) ) );
			sprite.addChild(testViewer);
			trace("TEST 1) INIT");
			trace(testViewer.ToString());
			trace("***END CellGridViewer UNIT TEST***");
		}
	}
}