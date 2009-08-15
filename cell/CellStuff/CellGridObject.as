package CellStuff {
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	
	import flash.geom.Point;
	
	public class CellGridObject {
		
		public var m_dv:Point;
		
		public var m_level:int;
		
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
		public var m_color:uint;
		public var m_libraryName:String;
		public var m_frame:int;
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
		
		public var m_isMarkedForDeletion:Boolean;
		
		// consts
		
		public static const c_maxMass:Number = 10000.0;
		public static const c_minMass:Number = 0.0;
		
		public static const c_punchFactor:Number = 20.0;
		public static const c_areaCooldownTime:int = 10;
		
		public static const c_defaultRadius:Number = 5.0;
		public static const c_defaultMass:Number = 1.0;
		public static const c_defaultMaxSpeed:Number = 10.0;
		
		public static const c_defaultCellThickness:Number = 4.0;
		public static const c_defaultLibraryName:String = "PhysFlower";
		
		/* Constructor
		*/
		public function CellGridObject(goData:Object):void {
			
			m_dv = new Point(0, 0);
			
			m_localPoint = new Point(0, 0);
			
			m_registered = null;
			m_registeredStack = new Array();
			
			m_cover = null;
			
			m_sprite = null;
			m_display = null;
			
			m_speed = new Point(0, 0);
			
			m_attachedTo = null;
			m_attachedOffset = new Point(0, 0);
			m_attachedList = new Array();
			
			m_areasIn = new Array();
			m_objectsInArea = new Array();
			
			m_absorbedIn = null;
			m_absorbedList = new Array();
			m_absorbSprite = null;
			
			ResetGridObject(goData);
		}
		
		/* ResetGridObject
		* resets the grid object given the data
		*/
		public function ResetGridObject(goData:Object):void {
			m_level = goData.level?goData.level:0;
			
			m_localPoint.x = goData.localX?goData.localX:0;
			m_localPoint.y = goData.localY?goData.localY:0;
			m_col = goData.col?goData.col:0;
			m_row = goData.row?goData.row:0;
			
			m_radius = goData.radius?goData.radius:c_defaultRadius;
			m_cellThickness = goData.cellThickness?goData.cellThickness:c_defaultCellThickness;
			m_mass = goData.mass?goData.mass:c_defaultMass;
			
			m_isDrawn = goData.isDrawn?goData.isDrawn:false;
			m_color = goData.color?goData.color:uint(Math.random()*0x666666 + 0x666666);
			m_libraryName = goData.libraryName?goData.libraryName:c_defaultLibraryName;
			m_frame = goData.frame?goData.frame:2;
			m_isBitmapCached = goData.isBitmapCached?goData.isBitmapCached:true;
			
			m_isWorking = goData.isWorking?goData.isWorking:false;
			
			m_speed.x = goData.speedX?goData.speedX:0;
			m_speed.y = goData.speedY?goData.speedY:0;
			m_maxSpeed = goData.maxSpeed?goData.maxSpeed:c_defaultMaxSpeed;
			m_isMoving = goData.isMoving?goData.isMoving:false;
			m_hasMoved = goData.hasMoved?goData.hasMoved:false;
			
			m_attachedOffset.x = goData.attachedOffsetX?goData.attachedOffsetX:0;
			m_attachedOffset.x = goData.attachedOffsetY?goData.attachedOffsetY:0;
			m_attachedLength = goData.attachedLength?goData.attachedLength:0;
			m_attachedRotationSpeed = goData.attachedRotationSpeed?goData.attachedRotationSpeed:0;
			
			m_isArea = goData.isArea?goData.isArea:false;
			m_areaCooldown = goData.areaCooldown?goData.areaCooldown:0;
			
			m_isAbsorbing = goData.isAbsorbing?goData.isAbsorbing:false;
			m_absorbAreaLeft = goData.absorbAreaLeft?goData.absorbAreaLeft:(m_radius-m_cellThickness)*(m_radius-m_cellThickness);
			m_isFull = goData.isFull?goData.isFull:false;
			
			m_isMarkedForDeletion = goData.isMarkedForDeletion?goData.isMarkedForDeletion:false;
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
				m_registered.cover.RegisterGridObject(m_registered, go);
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
		
		/* GenerateGridObjectData
		*/
		public function GenerateGridObjectData(goData:Object):Object {
			goData.level = m_level;
			
			goData.localX = m_localPoint.x;
			goData.localY = m_localPoint.y;
			goData.col = m_col;
			goData.row = m_row;
			
			goData.radius = m_radius;
			goData.cellThickness = m_cellThickness;
			goData.mass = m_mass;
			
			goData.isDrawn = m_isDrawn;
			goData.color = m_color;
			goData.libraryName = m_libraryName;
			goData.frame = m_frame;
			goData.isBitmapCached = m_isBitmapCached;
			
			goData.isWorking = m_isWorking;
			
			goData.speedX = m_speed.x;
			goData.speedY = m_speed.y;
			goData.maxSpeed = m_maxSpeed;
			goData.isMoving = m_isMoving;
			goData.hasMoved = m_hasMoved;
			
			goData.attachedOffsetX = m_attachedOffset.x;
			goData.attachedOffsetY = m_attachedOffset.x;
			goData.attachedLength = m_attachedLength;
			goData.attachedRotationSpeed = m_attachedRotationSpeed;
			
			goData.isArea = m_isArea;
			goData.areaCooldown = m_areaCooldown;
			
			goData.isAbsorbing = m_isAbsorbing;
			goData.absorbAreaLeft = m_absorbAreaLeft;
			goData.isFull = m_isFull;
			
			goData.isMarkedForDeletion = m_isMarkedForDeletion;
			
			return goData;
		}
		
		/* CreateGridObjectData
		*/
		public static function CreateGridObjectData(radius:Number = 5, mass:Number = 1, maxSpeed:Number = 10):Object {
			return {radius:radius, mass:mass, maxSpeed:maxSpeed};
		}
		
		public static function CreateGridObjectRandomData(goRandomData:Object,
		cellWidth:Number = 100,
		cellHeight:Number = 100):Object {
			var goData:Object = new Object();
			
			for (var item:* in goRandomData) {
				goData[item] = goRandomData[item];
			}
			
			if (goRandomData.randomRadius) {
				delete goData["randomRadius"];
				delete goData["radiusHigh"];
				delete goData["radiusLow"];
				goData.radius = Math.random()*(goRandomData.radiusHigh - goRandomData.radiusLow) + goRandomData.radiusLow;
			}
			
			if (goRandomData.randomMass) {
				delete goData["randomMass"];
				delete goData["massHigh"];
				delete goData["massLow"];
				goData.mass = Math.random()*(goRandomData.massHigh - goRandomData.massLow) + goRandomData.massLow;
			}
			
			if (goRandomData.randomLocation) {
				delete goData["randomLocation"];
				delete goData["colHigh"];
				delete goData["colLow"];
				delete goData["rowHigh"];
				delete goData["rowLow"];
				goData.col = int(Math.random()*(goRandomData.colHigh - goRandomData.colLow) + goRandomData.colLow);
				goData.row = int(Math.random()*(goRandomData.rowHigh - goRandomData.rowLow) + goRandomData.rowLow);
				goData.localX = Math.random()*cellWidth;
				goData.localY = Math.random()*cellHeight;
			}
			
			return goData;
		}
		
	}
	
}