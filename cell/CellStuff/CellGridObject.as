package CellStuff {
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	
	import flash.geom.Point;
	
	public class CellGridObject {
		
		public var m_dv:Point;
		
		public var m_localPoint:Point;
		
		public var m_col:int;
		public var m_row:int;
		
		public var m_radius:Number;
		public var m_mass:Number;
		
		public var m_registered:Object;
		public var m_registeredStack:Array;
		
		public var m_cover:CellGridCover;
		
		public var m_sprite:Sprite;
		public var m_isDrawn:Boolean;
		public var m_libraryName:String;
		public var m_isBitmapCached:Boolean;
		public var m_display:DisplayObject;
		
		public var m_isWorking:Boolean;
		
		public var m_speed:Point;
		public var m_maxSpeed:Number;
		public var m_isMoving:Boolean;
		
		public var m_attachedTo:CellGridObject;
		public var m_attachedOffset:Point;
		public var m_attachedLength:Number;
		public var m_attachedRotationSpeed:Number;
		public var m_attachedList:Array;
		
		// consts
		
		public static const c_maxMass:Number = 10000.0;
		public static const c_minMass:Number = 0.0;
		
		/* Constructor
		*/
		public function CellGridObject(radius:Number = 5, mass:Number = 1, maxSpeed:Number = 10):void {
			
			m_dv = new Point(0, 0);
			
			m_localPoint = null;
			m_col = 0;
			m_row = 0;
			
			m_radius = radius;
			m_mass = mass;
			
			m_registered = null;
			m_registeredStack = new Array();
			
			m_cover = null;
			
			m_sprite = null;
			m_isDrawn = false;
			m_libraryName = "PhysFlower";
			m_isBitmapCached = true;
			m_display = null;
			
			m_isWorking = false;
			
			m_speed = new Point(0, 0);
			m_maxSpeed = maxSpeed;
			m_isMoving = false;
			
			m_attachedTo = null;
			m_attachedOffset = new Point(0, 0);
			m_attachedLength = 0;
			m_attachedRotationSpeed = 0;
			m_attachedList = new Array();
			
		}
		
		/* AddToGrid
		* adds the object to the grid at a local location
		*/
		public function AddToGrid(cellGrid:CellGridLocations, localPoint:Point, col:int, row:int):void {
			m_localPoint = localPoint;
			m_col = col;
			m_row = row;
			
			m_cover = new CellGridCover( CellGridCover.CreateGridCoverData_GridObject(cellGrid, this) );
			
			m_cover.SetGridObject(this);
		}
		
		/* Update
		* updates the grid object,
		* used for polymorphism, and performing actions when working
		*/
		public function Update():void {
			// nothing yet
		}
		
		/* Move 
		* moves the object and the grid cover and updates the location (note: not physical move)
		*/
		public function Move(dx:Number, dy:Number):void {
			m_cover.MoveGridObject(dx, dy);
			
			if (m_registered) {
				m_registered.cover.UpdateGridObject(this);
			}
			
		}
		
		/* ChangeSpeedDirection
		* changes the speed direction (without adding acceleration
		*/
		public function ChangeSpeedDirection(dx:Number, dy:Number):void {
			m_speed.x = dx;
			m_speed.y = dy;
		}
		
		/* Accelerate
		* accelerates the grid object
		*/
		public function Accelerate(dx:Number, dy:Number):void {
			m_speed.x += dx;
			m_speed.y += dy;
		}
		
		/* AttachGridObject
		*/
		public function AttachGridObject(go:CellGridObject, attachedLength:Number):void {
			go.m_attachedTo = this;
			go.m_attachedLength = attachedLength;
			
			m_attachedList.push(go);
			
		}
		
		
		/* GridObjects
		* gets all the grid objects (excluding this one) under the cover
		*/
		public function GridObjects():Array {
			return m_cover.GridObjects();
		}
		
	}
	
}