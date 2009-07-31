package CellStuff {
	
	import flash.display.Sprite;
	
	import flash.geom.Point;
	
	import flash.events.Event;
	
	// we use sprite just for the event listener
	public class CellWorldWorker extends Sprite {
		
		private var m_cellGrid:CellGridLocations;
		private var m_physics:CellPhysics;
		private var m_workCover:CellGridCover;
		
		private var m_fullTimeWorkers:Array;
		
		private var m_numGridObjectsUnderCover:int;
		
		// consts
		
		public static const c_workCoverWidth:Number = 800;
		public static const c_workCoverHeight:Number = 800;
		
		public static const c_friction:Number = 0.6;
		
		/* Constructor
		*/
		public function CellWorldWorker(cellGrid:CellGridLocations, physics:CellPhysics, workCover:CellGridCover):void {
			m_cellGrid = cellGrid;
			m_physics = physics;
			m_workCover = workCover;
			
			m_fullTimeWorkers = new Array();
			
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
		}
		
		/* Update
		* called every ENTER_FRAME,
		* this causes an Update call to the list of gridobjects under the watch
		*/
		public function Update(event:Event):void {
			
			var objectList:Array = m_workCover.GridObjects();
			m_numGridObjectsUnderCover = objectList.length;
			
			for each (var go:CellGridObject in m_fullTimeWorkers) {
				go.m_isWorking = false;
			}
			
			for each (go in objectList) {
				go.Update();
				go.m_isWorking = true;
				
				PreMotion(go);
				MotionHandler(go);
			}
			
			for each (go in m_fullTimeWorkers) {
				if (!go.m_isWorking) {
					go.Update();
					go.m_isWorking = true;
					
					PreMotion(go);
					MotionHandler(go);
				}
			}
		}
		
		/* PreMotion
		* calculates any premotion values that are needed,
		* such as attached or animation values
		*/
		public function PreMotion(go:CellGridObject):void {
			if (go.m_attachedTo) {
				
				var dv:Point = m_cellGrid.CalculateDistanceVector_LocalToGridObject(go.m_attachedOffset, go.m_localPoint, go.m_col, go.m_row, go.m_attachedTo);
				var length:Number = Math.sqrt(dv.x*dv.x + dv.y*dv.y);
				
				if (length > go.m_attachedLength + 10) {
					dv.normalize(1);
					go.Accelerate(dv.x, dv.y);
				} else if (length < go.m_attachedLength - 10) {
					dv.normalize(1);
					go.Accelerate(-dv.x, -dv.y);
				}
				
				if (Math.abs(go.m_attachedRotationSpeed) > 0) {
					dv.normalize(go.m_attachedRotationSpeed);
					go.Accelerate(-dv.y, dv.x)
				}
				
			}
		}
		
		/* MotionHandler
		* handles any motions the objects might need to do
		*/
		public function MotionHandler(go:CellGridObject):void {
			
			var signX:int = go.m_speed.x<0?-1:1;
			var signY:int = go.m_speed.y<0?-1:1;
			var squared:Number = go.m_speed.x*go.m_speed.x + go.m_speed.y*go.m_speed.y;
			
			if (squared > go.m_maxSpeed*go.m_maxSpeed) {
				go.m_speed.normalize(go.m_maxSpeed);
			}
			
			if (squared > Number.MIN_VALUE) {
				m_physics.MoveGridObject(go, go.m_speed.x, go.m_speed.y);
				
				go.m_speed.x -= c_friction*signX;
				go.m_speed.y -= c_friction*signY;
				
				var newSignX:int = go.m_speed.x<0?-1:1;
				var newSignY:int = go.m_speed.y<0?-1:1;
				
				if (newSignX != signX) {
					go.m_speed.x = 0;
				}
				if (newSignY != signY) {
					go.m_speed.y = 0;
				}
			
			}
		}
		
		/* AddGridObjectAsFullTimer
		* makes sure that regardless if the object leaves the working area, the gridobject
		* does work
		*/
		public function AddGridObjectAsFullTimer(go:CellGridObject):void {
			m_fullTimeWorkers.push(go);
		}
		
		/* CreateWorkCoverData
		*/
		public static function CreateWorkCoverData(cellGrid:CellGridLocations, viewer:CellGridViewer):Object {
			var startWorld:Point = viewer.GetWorldCenter().clone();
			startWorld.x -= c_workCoverWidth/2;
			startWorld.y -= c_workCoverHeight/2;
			
			return CellGridCover.CreateGridCoverData_World(cellGrid,
			startWorld,
			c_workCoverWidth,
			c_workCoverHeight);
		}
		
		/* UpdatePerformanceStatistics
		*/
		public function UpdatePerformanceStatistics(pStats:CellPerformanceStatistics):CellPerformanceStatistics {
			pStats.m_numWorkingGridObjects = m_numGridObjectsUnderCover;
			pStats.m_numWorkingFullTimers = m_fullTimeWorkers.length;
			
			return pStats;
		}
		
	}
}