package CellStuff {
	
	import flash.geom.Point;
	
	public class CellPhysics {
		
		private var m_cellGrid:CellGridLocations;
		
		private var m_contactStack:Object;
		private var m_pointStack:Array;
		
		// consts
		public static const c_maxRecursions:int = 5;
		
		/* Constructor
		*/
		public function CellPhysics(cellGrid:CellGridLocations):void {
			m_cellGrid = cellGrid;
			
			m_contactStack = new Array();
			m_pointStack = new Array();
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
		}
		
		/* AddToGrid
		* adds an object to the grid, but also handles physics at the same time.
		* this is useful to make sure objects don't overlap at the start
		*/
		public function AddToGrid(go:CellGridObject, localPoint:Point, col:int, row:int):void {
			go.AddToGrid(m_cellGrid, localPoint, col, row);
			MoveGridObject(go, 0.0, 0.0);
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
				go.Move(dv.x, dv.y);
			}
			
			go.m_isMoving = false; // reset our flag
			
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
					dist = CalculateCollisionResult_Circle(dist, go2, amass + go.m_mass, rcount+1); // ?????
					dist.x += contact.overlap.x; 
					dist.y += contact.overlap.y;
				} else {
					dist.x = 0;
					dist.y = 0;
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
			
			dist.x = contact.overlap.x * r;
			dist.y = contact.overlap.y * r;
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
						return contact;
					}
				}
			}
			
			RemovePoint(localPoint);
			
			return null;
		}
		
		/* CalculateContact
		* calculates and generates the contact between two objects
		*/
		public function CalculateContact(contact:Object, go:CellGridObject, localPoint:Point, go2:CellGridObject, index:int = -1):Object {
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
		
		/* UpdatePerformanceStatistics
		*/
		public function UpdatePerformanceStatistics(pStats:CellPerformanceStatistics):CellPerformanceStatistics {
			pStats.m_numStackContacts = m_contactStack.length;
			pStats.m_numStackPoints = m_pointStack.length;
			
			pStats = m_cellGrid.UpdatePerformanceStatistics(pStats);
			
			return pStats;
		}
		
		
	}
}