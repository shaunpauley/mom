package {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	
	import flash.geom.Point;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	
	import CellStuff.*;
	
	public class CellViewerTest extends MovieClip {
		
		private var m_viewer:CellGridViewer;
		
		private var m_cellGrid:CellGridLocations;
		
		// keyboard handling
		private var isKeyDown:Boolean;
		private var isKeyUp:Boolean;
		private var isKeyRight:Boolean;
		private var isKeyLeft:Boolean;
		
		private var isKeyZoomIn:Boolean;
		private var isKeyZoomOut:Boolean;
		
		// keys
		public static const c_key_up:uint	= 38;
		public static const c_key_down:uint = 40;
		public static const c_key_left:uint = 37;
		public static const c_key_right:uint = 39;
		
		public static const c_key_w:uint	= 87;
		public static const c_key_s:uint	= 83;
		public static const c_key_a:uint	= 65;
		public static const c_key_d:uint	= 68;
		
		public static const c_key_j:uint		= 74;
		public static const c_key_k:uint		= 75;
		public static const c_key_n:uint		= 78;
		public static const c_key_m:uint		= 77;
		public static const c_key_comma:uint	= 188;
		public static const c_key_period:uint	= 190;
		public static const c_key_slash:uint	= 191;
		
		public static const c_key_1:uint = 49;
		public static const c_key_2:uint = 50;
		
		public function CellViewerTest():void {
			
			var worldSprite:Sprite = new Sprite();
			worldSprite.x = 275;
			worldSprite.y = 275;
			
			m_cellGrid = new CellGridLocations( CellGridLocations.CreateGridLocationsData() );
			
			var go:Object = {dv:new Point(0, 0), localPoint:new Point(20, 25), col:5, row:5, radius:3, registeredStack:new Array()};
			go.cover = new CellGridCover( CellGridCover.CreateGridCoverData_GridObject(m_cellGrid, go) );
			go.cover.SetGridObject(go);
			
			go = {dv:new Point(0, 0), localPoint:new Point(0, 25), col:5, row:6, radius:50, registeredStack:new Array()};
			go.cover = new CellGridCover( CellGridCover.CreateGridCoverData_GridObject(m_cellGrid, go) );
			go.cover.SetGridObject(go);
			
			go = {dv:new Point(0, 0), localPoint:new Point(75, 5), col:4, row:5, radius:30, registeredStack:new Array()};
			go.cover = new CellGridCover( CellGridCover.CreateGridCoverData_GridObject(m_cellGrid, go) );
			go.cover.SetGridObject(go);
			
			go = {dv:new Point(0, 0), localPoint:new Point(20, 45), col:18, row:19, radius:300, registeredStack:new Array()};
			go.cover = new CellGridCover( CellGridCover.CreateGridCoverData_GridObject(m_cellGrid, go) );
			go.cover.SetGridObject(go);
			
			var viewerData:Object = CellGridViewer.CreateViewerData(m_cellGrid);
			m_viewer = new CellGridViewer( viewerData );
			
			worldSprite.addChild(m_viewer);
			
			addChild(worldSprite);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			stage.addEventListener(Event.ENTER_FRAME, GameLoop, false, 0, true);
			
		}
		
		private function GameLoop(event:Event):void {
			
			if (isKeyZoomOut) {
				m_viewer.GrowViewer(5, 5);
			} else if (isKeyZoomIn) {
				m_viewer.ShrinkViewer(5, 5);
			}
			
			if (isKeyLeft) {
				m_viewer.MoveViewer(-5, 0);
			} else if (isKeyRight) {
				m_viewer.MoveViewer(5, 0);
			}
			
			if (isKeyUp) {
				m_viewer.MoveViewer(0, -5);
			} else if (isKeyDown) {
				m_viewer.MoveViewer(0, 5);
			}
		}
		
		public function keyDownHandler(event:KeyboardEvent):void {
			isKeyDown ||= (event.keyCode == c_key_down) || (event.keyCode == c_key_s);
			isKeyUp ||= (event.keyCode == c_key_up) || (event.keyCode == c_key_w);
			isKeyRight ||= (event.keyCode == c_key_right) || (event.keyCode == c_key_d);
			isKeyLeft ||= (event.keyCode == c_key_left) || (event.keyCode == c_key_a);
			isKeyZoomIn ||= (event.keyCode == c_key_n);
			isKeyZoomOut ||= (event.keyCode == c_key_m);
		}
		
		public function keyUpHandler(event:KeyboardEvent):void {
			isKeyDown &&= !(event.keyCode == c_key_down) && !(event.keyCode == c_key_s);
			isKeyUp &&= !(event.keyCode == c_key_up) && !(event.keyCode == c_key_w);
			isKeyRight &&= !(event.keyCode == c_key_right) && !(event.keyCode == c_key_d);
			isKeyLeft &&= !(event.keyCode == c_key_left) && !(event.keyCode == c_key_a);
			isKeyZoomIn &&= !(event.keyCode == c_key_n);
			isKeyZoomOut &&= !(event.keyCode == c_key_m);
			
		}
		
	}
}