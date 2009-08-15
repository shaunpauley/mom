package CellStuff {
	
	import flash.geom.Point;
	
	public class CellPhysics {
		
		private var m_cellGrid:CellGridLocations;
		
		private var m_contactStack:Array;
		private var m_pointStack:Array;
		
		private var m_stockCovers:Array;
		
		private var m_numActiveCovers:int;
		
		// consts
		public static const c_maxRecursions:int = 5;
		
		/* Constructor
		*/
		public function CellPhysics(cellGrid:CellGridLocations):void {
			m_cellGrid = cellGrid;
			
			m_contactStack = new Array();
			m_pointStack = new Array();
			
			m_stockCovers = new Array();
			
			m_numActiveCovers = 0;
		}
		
		/* NewContact
		* creates a new contact object or pulls one from the stack.
		* this is to have a little control over the GC as we may need to rapidly create new contacts
		*/
		private function NewContact():Object { 
			
			if (m_contactStack.length) {
				var contact:Object = m_contactStack.pop();
			} else {
				contact = new Object();
			}
			
			if (!contact.overlap) {
				contact.overlap = new Point(0, 0);
			}
			contact.overlap.x = 0;
			contact.overlap.y = 0;
			
			contact.object1 = null;
			contact.object2 = null;
			
			if (!contact.dv) {
				contact.dv = new Point(0, 0);
			}
			contact.dv.x = 0;
			contact.dv.y = 0;
			
			contact.index = -1;
			
			return contact;
		}
		
		/* RemoveContact
		* places a contact object on the stack
		*/
		private function RemoveContact(c:Object):void {
			m_contactStack.push(c);
		}
		
		/* NewPoint
		* creates a new point or pulls one from the stack.
		* this is to have a little control over the GC as we may need to rapidly create new points
		*/
		private function NewPoint(x:Number = 0.0, y:Number = 0.0):Point {
			
			if (m_pointStack.length) {
				var p:Point = m_pointStack.pop();
				p.x = x;
				p.y = y;
			} else {
				p = new Point(x, y);
			}
			
			return p;
		}
		
		/* RemovePoint
		* places a point on the stack
		*/
		private function RemovePoint(p:Point):void {
			m_pointStack.push(p);
		}
		
		/* NewCover
		* grabs a new cover from the stock, if none, then creates a new cover
		*/
		public function NewCover(coverData:Object):CellGridCover {
			if (m_stockCovers.length) {
				var newCover:CellGridCover = m_stockCovers.pop();
				newCover.ResetCover(coverData);
			} else {
				newCover = new CellGridCover(m_cellGrid, coverData);
			}
			m_numActiveCovers++;
			return newCover;
		}
		
		/* StockCover
		* pushes the existing cover on the stock
		*/
		public function StockCover(gridCover:CellGridCover):void {
			m_stockCovers.push(gridCover);
			m_numActiveCovers--;
		}
		
		/* FlushStacks
		* flushes the stack (in case of too much memory)
		*/
		public function FlushStacks():void {
			while (m_pointStack.length) {
				m_pointStack.pop();
			}
			
			while (m_contactStack.length) {
				m_contactStack.pop();
			}
			
			while(m_stockCovers.length) {
				m_stockCovers.pop();
			}
			
		}
		
		/* CreateCoverAndAddToGrid
		* adds an object to the grid, but also handles physics at the same time.
		* this is useful to make sure objects don't overlap at the start
		*/
		public function CreateCoverAndAddToGrid(go:CellGridObject, localPoint:Point, col:int, row:int):void {
			go.SetLocal(localPoint, col, row);
			m_cellGrid.CalculateGridObjectLocal(go);
			
			var cover:CellGridCover = NewCover( CellGridCover.CreateGridCoverData_GridObject(m_cellGrid, go) );
			go.SetGridCover(cover);
			
			cover.SetGridObject(go);
			
			MoveGridObject(go, 0.0, 0.0);
		}
		
		/* AddLevelObjects
		* adds all the objects for a level based on the level data given
		*/
		public function AddLevelObjects(objectData:Object):void {
			for each (var goDefaultData:Object in objectData.defaultObjects) {
				for (var i:int = 0; i < goDefaultData.numCopies; i++) {
					var goData:Object = CellGridObject.CreateGridObjectRandomData(goDefaultData);
					var go:CellGridObject = new CellGridObject(goData);
					CreateCoverAndAddToGrid(go, go.m_localPoint, go.m_col, go.m_row);
				}
			}
		}
		
		/* RemoveCoverFromGridObject
		* removes the gridobject's cover from the grid (and the grid object)
		* and removes the cover from the gridobject
		*/
		public function RemoveCoverFromGridObject(go:CellGridObject):void {
			// detach if necessary
			if (go.m_attachedTo) {
				go.m_attachedTo.DetachGridObject(go);
			}
			
			if (go.m_attachedList.length) {
				go.DetachAllGridObjects();
			}
			
			StockCover(go.m_cover);
			go.ReleaseGridCover();
		}
		
		/* MoveGridObject
		* used to move an object through the physical world, calculating contacts, etc.
		*/
		public function MoveGridObject(go:CellGridObject, dx:Number, dy:Number):void {
			var dv:Point = NewPoint(dx, dy);
			dv = CalculateCollisionResult_Circle(dv, go);
			RemovePoint(dv);
			
		}
		
		/* CalculateCollisionResult_Circle
		* currently, our main collision detection and result function.  Note, that this method
		* also moves the object or any objects it hits.
		*/
		private function CalculateCollisionResult_Circle(dv:Point, go:CellGridObject, amass:Number = 0, rcount:int = 0):Point {
			go.m_isMoving = true; // used to prevent crazy situations
			
			// get our grid objects around the object
			var gobjects:Array = go.GridObjects();
			
			var contact:Object = NewContact();
			while( NextContact(contact, gobjects, go, dv, contact.index+1) ) {
				var dist:Point = CalculateDistribution(NewPoint(), contact, amass, rcount);
				dv.x += dist.x;
				dv.y += dist.y;
				RemovePoint(dist);
			}
			RemoveContact(contact);
			
			
			if (dv.length > Number.MIN_VALUE) {
				
				go.Move(m_cellGrid, dv.x, dv.y);
				
				for each (var goAbsorbed:CellGridObject in go.m_absorbedList) {
					var dvAbsorbed:Point = CalculateCollisionResult_Circle(NewPoint(), goAbsorbed, go.m_mass);
					RemovePoint(dvAbsorbed);
				}
				
			}
			
			if (go.m_absorbedIn) {
				var dvTemp:Point = CalculateCollisionResult_InnerCircle(NewPoint(0, 0), go, go.m_absorbedIn);
				RemovePoint(dvTemp);
			}
			
			go.m_isMoving = false; // reset our flag
			
			return dv;
		}
		
		/* CalculateCollisionResult_InnerCircle
		* calculates collision and moves the object so that the object is always
		* in the outer object.  this is useful for absorbing objects into another
		*/
		private function CalculateCollisionResult_InnerCircle(dv:Point, go:CellGridObject, goOuter:CellGridObject):Point {
			var localPoint:Point = NewPoint(go.m_localPoint.x + dv.x - goOuter.m_speed.x, go.m_localPoint.y + dv.y - goOuter.m_speed.y);
			localPoint = m_cellGrid.CalculateDistanceVector_Local(localPoint, 
			localPoint, 
			go.m_col, 
			go.m_row, 
			goOuter.m_localPoint, 
			goOuter.m_col, 
			goOuter.m_row);
			
			var d:Number = goOuter.m_radius - go.m_radius - go.m_cellThickness;
			if (localPoint.length > d) {
				dv.x = localPoint.x;
				dv.y = localPoint.y;
				d = dv.length - d;
				dv.normalize(d);
				go.Move(m_cellGrid, dv.x, dv.y);
			}
			RemovePoint(localPoint);
			
			return dv;
		}
		
		/* CalculateDistribution
		* determines how much the object should move when hitting another object, and process
		* the collision on the other objects as well.
		*/
		private function CalculateDistribution(dist:Point, contact:Object, amass:Number, rcount:int):Point {
			dist.x = contact.overlap.x;
			dist.y = contact.overlap.y;
			
			var go:CellGridObject = contact.object1;
			var go2:CellGridObject = contact.object2;
			
			if ( (go2.m_mass < CellGridObject.c_maxMass) && 
			(!go.m_absorbedIn) &&
			(rcount <= c_maxRecursions) ) {
				
				// distribute weight
				if (go2.m_mass <= CellGridObject.c_minMass) {
					dist.x = 0;
					dist.y = 0;
				} else {
					dist = CalculateDistributeCollisionWeight(dist, contact, amass);
				}
				
				// apply to object2 and get actual value
				dist.x -= contact.overlap.x;
				dist.y -= contact.overlap.y;
				
				if (dist.length > Number.MIN_VALUE) {
					dist = CalculateCollisionResult_Circle(dist, go2, amass + go.m_mass, rcount+1);
					dist.x += contact.overlap.x; 
					dist.y += contact.overlap.y;
				} else {
					dist.x = contact.overlap.x;
					dist.y = contact.overlap.y;
				}
				
			}
			
			return dist;
		}
		
		/* CalculateDistributeCollisionWeight
		* determines the movement based on the weights of the objects colliding
		*/
		public function CalculateDistributeCollisionWeight(dist:Point, contact:Object, amass:Number):Point {
			var w1:Number = contact.object1.m_mass + amass;
			var w2:Number = contact.object2.m_mass;
			
			var r:Number = 1.0;
			if ( (w1 + w2) > Number.MIN_VALUE ) {
				r = w1/(w1+w2);
			}
			
			dist.x = contact.overlap.x * (1-r);
			dist.y = contact.overlap.y * (1-r);
			return dist;
		}
		
		/* NextContact
		* gets the next contact from a list of contacts
		*/
		private function NextContact(contact:Object, gobjects:Array, go:CellGridObject, dv:Point, startIndex:int = 0):Object {
			if (gobjects == null) {
				return null;
			}
			
			var localPoint:Point = NewPoint(go.m_localPoint.x + dv.x, go.m_localPoint.y + dv.y);
			
			for (var i:int = startIndex; i < gobjects.length; ++i) {
				var go2:CellGridObject = gobjects[i];
				if (!go2.m_isMoving) {
					if ( CalculateContact(contact, go, localPoint, go2, i) ) {
						if (HandleAreas(go, go2) && HandleAbsorb(go2, go)) {
							return contact;
						}
					}
				}
			}
			
			RemovePoint(localPoint);
			
			return null;
		}
		
		/* CalculateContact
		* calculates and generates the contact between two objects
		*/
		private function CalculateContact(contact:Object, go:CellGridObject, localPoint:Point, go2:CellGridObject, index:int = -1):Object {
			var dv:Point = m_cellGrid.CalculateDistanceVector_Local(contact.dv, localPoint, go.m_col, go.m_row, go2.m_localPoint, go2.m_col, go2.m_row);
			var ds:Number = dv.x * dv.x + dv.y * dv.y;
			var sr:Number = go.m_radius + go2.m_radius;
			
			if ( (ds > Number.MIN_VALUE) && (ds <= sr * sr) ) {
				// we hit!
				var dist:Number = Math.sqrt(ds);
				
				var a:Number = 1.0 / dist;
				var s:Number = dist - sr;
				
				// make sure it's not a weak hit (too small to care)
				if (s <= -Number.MIN_VALUE) {
					contact.overlap.x = s * a * dv.x;
					contact.overlap.y = s * a * dv.y;
					contact.object1 = go;
					contact.object2 = go2;
					contact.dv.x = dv.x;
					contact.dv.y = dv.y;
					contact.index = index;
					
					return contact;
				}
			}
			
			return null;
		}
		
		/* HandleAreas
		* handles when the objects collide and one is an area
		*/
		private function HandleAreas(go1:CellGridObject, go2:CellGridObject, secondPass:Boolean = false):Boolean {
			if (go1.m_isArea && !go2.m_isArea && !go2.IsInArea(go1)) {
				go1.AreaEnter(go2);
				return false;
			}
			
			return (secondPass || HandleAreas(go2, go1, true)) && !go1.m_isArea;
		}
		
		/* HandleAbsorb
		* handles when the objects collide and one is absorbing the other
		*/
		private function HandleAbsorb(go1:CellGridObject, go2:CellGridObject, secondPass:Boolean = false):Boolean {
			if (go1.m_isAbsorbing && !go1.m_isFull && go1.CanAbsorbRadius(go2.m_radius)) {
				// remove from grid
				
				if (go2.m_cover) {
					RemoveCoverFromGridObject(go2);
				} else if (go2.m_absorbedIn) {
					
					
					if (go2.m_registered) {
						go2.m_registered.cover.UnregisterGridObject(go2.m_registered, go2);
					}
					
					var absorbedIn:CellGridObject = go2.m_absorbedIn;
					
					var i:int = absorbedIn.m_absorbedList.indexOf(go2);
					if (i > -1) {
						absorbedIn.m_absorbedList.splice(i, 1);
					} else {
						throw( new Error("cannot remove from absorbed list because it doesn't exist") );
					}
					
				}
				
				// absorb
				go1.Absorb(go2);
				
				// do collision detection right away
				MoveGridObject(go2, 0, 0);
				
				return false;
			}
			return (secondPass || HandleAbsorb(go2, go1, true));
		}
		
		/* UpdatePerformanceStatistics
		*/
		public function UpdatePerformanceStatistics(pStats:CellPerformanceStatistics):CellPerformanceStatistics {
			pStats.m_numStackContacts = m_contactStack.length;
			pStats.m_numStackPoints = m_pointStack.length;
			
			pStats.m_numActiveCovers = m_numActiveCovers;
			pStats.m_numStockCovers = m_stockCovers.length;
			
			pStats = m_cellGrid.UpdatePerformanceStatistics(pStats);
			
			return pStats;
		}
		
		
	}
}