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
		public var m_cellThickness:Number;
		public var m_mass:Number;
		
		public var m_registered:Object;
		public var m_registeredStack:Array;
		
		public var m_cover:CellGridCover;
		
		public var m_sprite:Sprite;
		public var m_isDrawn:Boolean;
		public var m_libraryName:String;
		public var m_isBitmapCached:Boolean;
		public var m_display:DisplayObject;
		public var m_movieClip:CellMovieClip;
		
		public var m_isWorking:Boolean;
		
		public var m_speed:Point;
		public var m_maxSpeed:Number;
		public var m_isMoving:Boolean;
		public var m_hasMoved:Boolean;
		
		public var m_attachedTo:CellGridObject;
		public var m_attachedOffset:Point;
		public var m_attachedLength:Number;
		public var m_attachedRotationSpeed:Number;
		public var m_attachedList:Array;
		
		public var m_isArea:Boolean;
		public var m_areasIn:Array;
		public var m_objectsInArea:Array;
		public var m_areaCooldown:Number;
		
		public var m_isAbsorbing:Boolean;
		public var m_absorbedIn:CellGridObject;
		public var m_absorbedList:Array;
		public var m_absorbSprite:Sprite;
		public var m_absorbAreaLeft:Number;
		public var m_isFull:Boolean;
		
		// consts
		
		public static const c_maxMass:Number = 10000.0;
		public static const c_minMass:Number = 0.0;
		
		public static const c_punchFactor:Number = 20.0;
		public static const c_areaCooldownTime:int = 10;
		
		/* Constructor
		*/
		public function CellGridObject(radius:Number = 5, mass:Number = 1, maxSpeed:Number = 10):void {
			
			m_dv = new Point(0, 0);
			
			m_localPoint = new Point(0, 0);
			m_col = 0;
			m_row = 0;
			
			m_radius = radius;
			m_cellThickness = 4.0;
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
			m_hasMoved = false;
			
			m_attachedTo = null;
			m_attachedOffset = new Point(0, 0);
			m_attachedLength = 0;
			m_attachedRotationSpeed = 0;
			m_attachedList = new Array();
			
			m_isArea = false;
			m_areasIn = new Array();
			m_objectsInArea = new Array();
			m_areaCooldown = 0;
			
			m_isAbsorbing = false;
			m_absorbedIn = null;
			m_absorbedList = new Array();
			m_absorbSprite = null;
			m_absorbAreaLeft = (m_radius-m_cellThickness)*(m_radius-m_cellThickness);
			m_isFull = false;
		}
		
		/* SetLocal
		* sets the local position
		*/
		public function SetLocal(localPoint:Point, col:int, row:int):void {
			m_localPoint.x = localPoint.x;
			m_localPoint.y = localPoint.y;
			m_col = col;
			m_row = row;
		}
		
		/* SetGridCover
		* sets the grid cover
		*/
		public function SetGridCover(cover:CellGridCover):void {
			m_cover = cover;
			m_cover.SetGridObject(this);
		}
		
		/* ReleaseGridCover
		* removes the object from the grid and the cover
		* this method preserves grid locations
		*/
		public function ReleaseGridCover():void {
			m_cover.RemoveFromGrid();
			m_cover = null;
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
		public function Move(cellGrid:CellGridLocations, dx:Number, dy:Number):void {
			cellGrid.MoveGridObject(this, dx, dy);
			
			if (m_cover) {
				m_cover.MoveCover(dx, dy);
			}
			
			m_hasMoved = true;
			
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
		* to attach an object at a length from the this object
		*/
		public function AttachGridObject(go:CellGridObject, attachedLength:Number):void {
			go.m_attachedTo = this;
			go.m_attachedLength = attachedLength;
			
			m_attachedList.push(go);
			
		}
		
		/* DetachGridObject
		* detaches an object
		*/
		public function DetachGridObject(go:CellGridObject):void {
			go.m_attachedTo = null;
			go.m_attachedLength = 0;
			var i:int = m_attachedList.indexOf(go);
			if (i > -1) {
				m_attachedList.splice(i, 1);
			} else {
				throw( new Error("DetachGridObject: Attempted to detached an object that doesn't exist") );
			}
		}
		
		/* DetachAllGridObjects
		* detaches all the grid objects that are attached
		*/
		public function DetachAllGridObjects():void {
			while(m_attachedList.length) {
				var go:CellGridObject = m_attachedList.pop();
				go.m_attachedTo = null;
			}
		}
		
		/* AreaEnter
		* called when an object enters this object as an area
		*/
		public function AreaEnter(go:CellGridObject):void {
			m_objectsInArea.push(go);
			go.m_areasIn.push(this);
		}
		
		/* IsInArea
		* returns whether the object is in the given area object
		*/
		public function IsInArea(goArea:CellGridObject):Boolean {
			return (m_areasIn.indexOf(goArea)+1);
		}
		
		/* ObjectsInArea
		* returns whether the object is in this area
		*/
		public function ObjectsInArea(go:CellGridObject):Boolean {
			return (m_objectsInArea.indexOf(go)+1);
		}
		
		/* AreaLeave
		* called when an object leaves an area
		*/
		public function AreaLeave(go:CellGridObject):void {
			var i:int = m_objectsInArea.indexOf(go);
			if (i > -1) {
				m_objectsInArea.splice(i, 1);
			}
			i = go.m_areasIn.indexOf(this);
			if (i > -1) {
				go.m_areasIn.splice(i, 1);
			}
			
		}
		
		/* AreaUpdate
		* updates the gridobject in this area using the dv points
		*/
		public function AreaUpdate(go:CellGridObject, dv:Point):void {
			if (!go.m_areaCooldown) {
				dv.normalize(c_punchFactor + m_radius);
				go.Accelerate(dv.x + m_speed.x*2, dv.y + m_speed.y*2);
				go.m_areaCooldown = c_areaCooldownTime;
			} else {
				go.m_areaCooldown--;
			}
		}
		
		/* Absorb
		* absorbs a gridobject
		*/
		public function Absorb(go:CellGridObject):void {
			m_absorbedList.push(go);
			go.m_absorbedIn = this;
			
			// redraw
			if (m_registered) {
				m_registered.cover.RedrawGridObject(this);
			}
			
			var squared:Number = go.m_radius*go.m_radius;
			m_absorbAreaLeft -= (squared + squared/(m_radius*m_radius));
			m_isFull = (m_absorbAreaLeft <= 1);
			
		}
		
		/* CanAbsorbRadius
		* determines if a radius can fit
		*/
		public function CanAbsorbRadius(radius:Number):Boolean {
			return (m_absorbAreaLeft - (radius*radius + (radius*radius)*2/(m_radius*m_radius)) > 1);
		}
		
		/* GridObjects
		* gets all the grid objects (excluding this one) under the cover
		*/
		public function GridObjects():Array {
			if (m_absorbedIn) {
				return m_absorbedIn.m_absorbedList;
			} 
			
			return m_cover.GridObjects();
		}
		
	}
	
}