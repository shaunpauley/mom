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
		
		private var m_level:int;
		
		private var m_viewer:CellGridViewer;
		
		private var m_cellGrid:CellGridLocations;
		
		private var m_physics:CellPhysics;
		
		private var m_moveObject:CellGridObject;
		private var m_secondObject:CellGridObject;
		
		private var m_pStats:CellPerformanceStatistics;
		
		private var m_moveDirection:Point;
		
		private var m_worker:CellWorldWorker;
		
		private var m_levelCreator:CellLevelCreator;
		
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
			
			m_level = 1;
			
			var gridData:Object = CellGridLocations.CreateGridLocationsData();
			gridData.defaultDrawType = CellGrid.c_drawTypeRandom;
			gridData.defaultColorLow = 0xBBBBBB;
			gridData.defaultColorHigh = 0x444444 + gridData.defaultColorLow;
			//gridData.defaultDrawType = CellGrid.c_drawTypeBitmap;
			gridData.defaultDrawType = CellGrid.c_drawTypeFlat;
			gridData.defaultColorHigh = 0x987654;
			gridData.cols = 20;
			gridData.rows = 20;
			
			m_levelCreator = new CellLevelCreator();
			
			m_cellGrid = new CellGridLocations( gridData );
			m_physics = new CellPhysics(m_cellGrid);
			
			
			var goData:Object = CellGridObject.CreateGridObjectData(20);
			
			goData.radius = 30;
			goData.mass = 10;
			var go3:CellGridObject = new CellGridObject(goData);
			m_physics.CreateCoverAndAddToGrid(go3, new Point(100, 100), int(Math.random()*gridData.cols), int(Math.random()*gridData.rows));
			go3.m_isDrawn = true;
			m_moveObject = go3;
			//m_moveObject.AttachGridObject(go2, 120);
			//go2.m_attachedRotationSpeed = 1;
			//go3.m_isArea = true;
			//go3.m_isAbsorbing = true;
			
			goData.radius = 20;
			goData.mass = 1;
			goData.level = 1;
			var go2:CellGridObject = new CellGridObject(goData);
			m_physics.CreateCoverAndAddToGrid(go2, new Point(0, 25), int(Math.random()*gridData.cols), int(Math.random()*gridData.rows));
			go2.m_isDrawn = false;
			
			goData.radius = 200;
			goData.mass = 100;
			var go4:CellGridObject = new CellGridObject(goData);
			m_physics.CreateCoverAndAddToGrid(go4, new Point(20, 45), int(Math.random()*gridData.cols), int(Math.random()*gridData.rows));
			//go4.m_isBitmapCached = false;
			//m_moveObject = go4;
			//go4.m_isAbsorbing = true;
			go4.m_isDrawn = true;
			
			var goPre:CellGridObject = m_moveObject;
			for (var i:int = 0; i < gridData.cols*gridData.rows/5; ++i) {
				goData.radius = Math.random()*20+2;
				goData.mass = Math.random()*10;
				var go:CellGridObject = new CellGridObject(goData);
				m_physics.CreateCoverAndAddToGrid(go, new Point(100*Math.random(), 100*Math.random()), int(Math.random()*gridData.cols), int(Math.random()*gridData.rows) );
				
				//m_moveObject.AttachGridObject(go, Math.random()*300 + 30 + go.m_radius);
				//go.m_attachedRotationSpeed = Math.random()*-2+1;
				go.m_isDrawn = false;
			}
			
			goData.radius = 10;
			goData.mass = 0;
			var go5:CellGridObject = new CellGridObject(goData);
			m_physics.CreateCoverAndAddToGrid(go5, new Point(0, 0), 0, 0);
			go5.m_isDrawn = true;
			m_secondObject = go5;
			/*
			go2.AttachGridObject(go5, 30);
			go5.m_attachedRotationSpeed = -0.7;
			go3.AttachGridObject(go2, 100);
			go2.m_attachedRotationSpeed = 0.5;
			*/
			//go3.m_isAbsorbing = true;
			
			var viewerData:Object = CellGridViewer.CreateViewerData(m_cellGrid);
			m_viewer = new CellGridViewer(m_cellGrid, viewerData);
			m_viewer.SetFocusGridObject(m_moveObject);
			
			m_worldSprite.addChild(m_viewer);
			
			var workCoverData:Object = CellWorldWorker.CreateWorkCoverData(m_cellGrid, m_viewer);
			var workCover:CellGridWorkingCover = new CellGridWorkingCover(m_cellGrid, workCoverData);
			m_worker = new CellWorldWorker(m_cellGrid, m_physics, m_viewer, workCover);
			m_worker.AddGridObjectAsFullTimer(m_moveObject);
			m_worker.AddGridObjectAsFullTimer(go2);
			m_worker.AddGridObjectAsFullTimer(go4);
			m_viewer.SetWorkCover(workCover);
			
			addChild(m_worldSprite);
			
			m_pStats = new CellPerformanceStatistics(m_physics, m_viewer, m_worker);
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
				m_moveObject.Accelerate(m_moveDirection.x, m_moveDirection.y);
			}
			
		}
		
		public function keyDownHandler(event:KeyboardEvent):void {
			isKeyDown ||= (event.keyCode == c_key_down) || (event.keyCode == c_key_s);
			isKeyUp ||= (event.keyCode == c_key_up) || (event.keyCode == c_key_w);
			isKeyRight ||= (event.keyCode == c_key_right) || (event.keyCode == c_key_d);
			isKeyLeft ||= (event.keyCode == c_key_left) || (event.keyCode == c_key_a);
			isKeyZoomIn ||= (event.keyCode == c_key_n);
			isKeyZoomOut ||= (event.keyCode == c_key_m);
			
			/*
			isKeyT ||= (event.keyCode == c_key_t);
			isKeyG ||= (event.keyCode == c_key_g);
			isKeyF ||= (event.keyCode == c_key_f);
			isKeyH ||= (event.keyCode == c_key_h);
			*/
		}
		
		public function keyUpHandler(event:KeyboardEvent):void {
			isKeyDown &&= !(event.keyCode == c_key_down) && !(event.keyCode == c_key_s);
			isKeyUp &&= !(event.keyCode == c_key_up) && !(event.keyCode == c_key_w);
			isKeyRight &&= !(event.keyCode == c_key_right) && !(event.keyCode == c_key_d);
			isKeyLeft &&= !(event.keyCode == c_key_left) && !(event.keyCode == c_key_a);
			isKeyZoomIn &&= !(event.keyCode == c_key_n);
			isKeyZoomOut &&= !(event.keyCode == c_key_m);
			
			/*
			isKeyT &&= !(event.keyCode == c_key_t);
			isKeyG &&= !(event.keyCode == c_key_g);
			isKeyF &&= !(event.keyCode == c_key_f);
			isKeyH &&= !(event.keyCode == c_key_h);
			*/
			
			if (event.keyCode == c_key_spacebar) {
				if (m_moveObject.m_isAbsorbing) {
					m_moveObject.m_isAbsorbing = false;
					m_worker.GridObjectSpitOutAll(m_moveObject);
				} else {
					m_moveObject.m_isAbsorbing = true;
				}
			}
			
			if (event.keyCode == c_key_t) {
				m_worker.ChangeLevel( m_levelCreator.GetLevelData(m_level+1) );
			}
			
			if (event.keyCode == c_key_g) {
				trace("\n");
				trace("m_moveObject: " + m_moveObject.m_radius + " col,row,x,y: " + m_moveObject.m_col + ", " + m_moveObject.m_row + " :: " + m_moveObject.m_localPoint);
				var worldPoint:Point = m_moveObject.m_localPoint.clone();
				trace("\tworld: " + m_cellGrid.LocalToWorld(worldPoint, m_moveObject.m_col, m_moveObject.m_row) );
				trace("\tcoverWorld: " + m_moveObject.m_cover.GetWorldCenter());
				trace(m_moveObject.m_cover.ToString());
				trace("m_viewer: " + m_viewer.GetWorldCenter());
				trace(m_viewer.ToString());
			}
			
		}
		
	}
}