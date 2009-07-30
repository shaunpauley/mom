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
		
		private var m_physics:CellPhysics;
		
		private var m_moveObject:CellGridObject;
		
		private var m_pStats:CellPerformanceStatistics;
		
		private var m_moveDirection:Point;
		
		private var m_bitmapData:CellCachedBitmapData;
		
		private var m_worldSprite:Sprite;
		
		// keyboard handling
		private var isKeyDown:Boolean;
		private var isKeyUp:Boolean;
		private var isKeyRight:Boolean;
		private var isKeyLeft:Boolean;
		
		private var isKeyT:Boolean;
		private var isKeyG:Boolean;
		private var isKeyF:Boolean;
		private var isKeyH:Boolean;
		
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
		
		public static const c_key_t:uint 	= 84;
		public static const c_key_g:uint	= 71;
		public static const c_key_f:uint 	= 70;
		public static const c_key_h:uint 	= 72;
		
		public static const c_key_j:uint		= 74;
		public static const c_key_k:uint		= 75;
		public static const c_key_n:uint		= 78;
		public static const c_key_m:uint		= 77;
		public static const c_key_comma:uint	= 188;
		public static const c_key_period:uint	= 190;
		public static const c_key_slash:uint	= 191;
		public static const c_key_spacebar:uint	= 32;
		
		public static const c_key_1:uint = 49;
		public static const c_key_2:uint = 50;
		
		public function CellViewerTest():void {
			
			m_worldSprite = new Sprite();
			m_worldSprite.x = 275;
			m_worldSprite.y = 275;
			
			m_cellGrid = new CellGridLocations( CellGridLocations.CreateGridLocationsData() );
			m_physics = new CellPhysics(m_cellGrid);
			
			var go:CellGridObject = new CellGridObject(3, 0);
			go.AddToGrid(m_cellGrid, new Point(20, 25), 5, 5);
			go.m_isDrawn = true;
			
			go = new CellGridObject(50);
			go.AddToGrid(m_cellGrid, new Point(0, 25), 5, 6);
			go.m_isDrawn = true;
			
			go = new CellGridObject(30);
			go.AddToGrid(m_cellGrid, new Point(75, 5), 4, 5);
			go.m_isDrawn = true
			m_moveObject = go;
			
			go = new CellGridObject(300, 100);
			go.AddToGrid(m_cellGrid, new Point(20, 45), 18, 19);
			go.m_isBitmapCached = false;
			
			go = new CellGridObject(2);
			go.AddToGrid(m_cellGrid, new Point(20, 45), 18, 19);
			go.m_isDrawn = true
			
			for (var i:int = 0; i < 500; ++i) {
				go = new CellGridObject(Math.random()*30 + 2, CellGridObject.c_maxMass-1);
				m_physics.AddToGrid(go, new Point(100*Math.random(), 100*Math.random()), int(Math.random()*20), int(Math.random()*20) );
			}
			
			m_bitmapData = new CellCachedBitmapData( new PhysFlower() );
			
			var viewerData:Object = CellGridViewer.CreateViewerData(m_cellGrid);
			m_viewer = new CellGridViewer( viewerData );
			m_viewer.SetFocusGridObject(m_moveObject);
			
			m_worldSprite.addChild(m_viewer);
			
			addChild(m_worldSprite);
			
			m_pStats = new CellPerformanceStatistics(m_physics, m_viewer);
			addChild(m_pStats);
			
			m_moveDirection = new Point(0, 0);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			stage.addEventListener(Event.ENTER_FRAME, GameLoop, false, 0, true);
			
		}
		
		private function GameLoop(event:Event):void {
			
			if (isKeyZoomOut) {
				m_viewer.GrowViewer(5, 5);
				m_worldSprite.scaleX = 550/m_viewer.GetWidth();
				m_worldSprite.scaleY = 550/m_viewer.GetHeight();
			} else if (isKeyZoomIn) {
				m_viewer.ShrinkViewer(5, 5);
				m_worldSprite.scaleX = 550/m_viewer.GetWidth();
				m_worldSprite.scaleY = 550/m_viewer.GetHeight();
			}
			
			if (isKeyLeft) {
				m_moveDirection.x = -1;
			} else if (isKeyRight) {
				m_moveDirection.x = 1;
			} else {
				m_moveDirection.x = 0;
			}
			
			if (isKeyUp) {
				m_moveDirection.y = -1;
			} else if (isKeyDown) {
				m_moveDirection.y = 1;
			} else {
				m_moveDirection.y = 0;
			}
			
			if (m_moveDirection.length) {
				m_moveDirection.normalize(1);
				m_physics.MoveGridObject(m_moveObject, m_moveDirection.x*m_moveObject.m_maxSpeed, m_moveDirection.y*m_moveObject.m_maxSpeed);
			}
			
			/*
			if (isKeyT) {
				//m_moveObject.Move(0, -1);
			}
			if (isKeyG) {
				//m_moveObject.Move(0, 1);
				m_physics.MoveGridObject(m_moveObject, 0, 3);
			}
			if (isKeyF) {
				//m_moveObject.Move(-1, 0);
				m_physics.MoveGridObject(m_moveObject, -3, 0);
			}
			if (isKeyH) {
				//m_moveObject.Move(1, 0);
				m_physics.MoveGridObject(m_moveObject, 3, 0);
			}
			*/
		}
		
		public function keyDownHandler(event:KeyboardEvent):void {
			isKeyDown ||= (event.keyCode == c_key_down) || (event.keyCode == c_key_s);
			isKeyUp ||= (event.keyCode == c_key_up) || (event.keyCode == c_key_w);
			isKeyRight ||= (event.keyCode == c_key_right) || (event.keyCode == c_key_d);
			isKeyLeft ||= (event.keyCode == c_key_left) || (event.keyCode == c_key_a);
			isKeyZoomIn ||= (event.keyCode == c_key_n);
			isKeyZoomOut ||= (event.keyCode == c_key_m);
			
			isKeyT ||= (event.keyCode == c_key_t);
			isKeyG ||= (event.keyCode == c_key_g);
			isKeyF ||= (event.keyCode == c_key_f);
			isKeyH ||= (event.keyCode == c_key_h);
		}
		
		public function keyUpHandler(event:KeyboardEvent):void {
			isKeyDown &&= !(event.keyCode == c_key_down) && !(event.keyCode == c_key_s);
			isKeyUp &&= !(event.keyCode == c_key_up) && !(event.keyCode == c_key_w);
			isKeyRight &&= !(event.keyCode == c_key_right) && !(event.keyCode == c_key_d);
			isKeyLeft &&= !(event.keyCode == c_key_left) && !(event.keyCode == c_key_a);
			isKeyZoomIn &&= !(event.keyCode == c_key_n);
			isKeyZoomOut &&= !(event.keyCode == c_key_m);
			
			isKeyT &&= !(event.keyCode == c_key_t);
			isKeyG &&= !(event.keyCode == c_key_g);
			isKeyF &&= !(event.keyCode == c_key_f);
			isKeyH &&= !(event.keyCode == c_key_h);
			
			if (event.keyCode == c_key_spacebar) {
				trace(m_moveObject.m_cover.ToString());
			}
		}
		
	}
}