package CellStuff {
	import flash.display.MovieClip;
	import flash.display.Sprite;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;

	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	
	public class CellSingle extends MovieClip {
		
		protected var myGrid:CellGridDisplay;
		
		public var myFaces:Array;
		
		public var faceDirection:Point;
		public var faceState:uint;
		
		public var MyRings:Array;
		
		public var myGridObject:GridObject;
		
		public var Nucleus:CellNucleus;
		public var Selected:Boolean;
		
		public var absorbState:uint;
		
		public var myCellStatus:Object;
		
		// level stats
		public var stats_radius:Number;
		public var stats_mass:Number;
		public var stats_num_rings:int;
		public var stats_max_speed:Number;
		public var stats_max_view:Number;
		
		// current stats
		public var stats_level:int;
		public var m_face_level:int;
		
		// is player
		
		public var m_is_player:Boolean;
		
		// debug
		private var DebugText:TextField;
		
		// constants
		
		public static const c_face_dead:uint 	= 0x000000;
		public static const c_face_normal:uint 	= 0x000001;
		public static const c_face_scared:uint 	= 0x000002;
		public static const c_face_sad:uint 	= 0x000003;
		public static const c_face_squid:uint 	= 0x000004;
		public static const c_face_evil:uint 	= 0x000005;
		public static const c_face_happy:uint 	= 0x000006;
		
		public static const c_ring_friction = 0.5;
		public static const c_prot_friction = 0.5;
		public static const c_max_ring_speed = 5;
		public static const c_max_prot_speed = 5;
		public static const c_max_rings = 4;
		
		public static const c_frame_normal = 1;
		public static const c_frame_xprot = 2;
		
		public static const c_absorb:uint = 0x000001;
		public static const c_repel:uint = 0x000000;
		
		public static const c_prit_move_radius:Number = 50;
		
		public static const c_ring_radius_inc:Number = 40;  // real radius is up to half this
		
		public function CellSingle(grid:CellGridDisplay, map_entry:Object) {
			myGrid = grid;
			
			MyRings = new Array();
			
			// map entries
			stats_radius = map_entry.radius;
			stats_mass = map_entry.mass;
			stats_num_rings = map_entry.num_rings;
			stats_max_speed = map_entry.max_speed;
			stats_max_view = map_entry.max_view;
			
			stats_level = map_entry.level;
			
			m_face_level = map_entry.face_level;
			m_is_player = map_entry.is_player;
			
			faceDirection = new Point(map_entry.face_direction_x, map_entry.face_direction_y);
			faceState = map_entry.face_state;
			
			absorbState = map_entry.absorb_state;
			
			// nucleus
			Nucleus = new CellNucleus(myGrid, this, map_entry);
			addChild(Nucleus);
			
			// face
			myFaces = new Array();
			
			var face_object:Object = addNewFaceObject();
			addChild(face_object.eyes);
			addChild(face_object.face);
			
			updateFaces();
			
			mouseEnabled = false;
			mouseChildren = false;
			
			// update rings
			updateRings(stats_num_rings);
			
			// text
			DebugText = new TextField();
			DebugText.x = 0;
			DebugText.y = 0;
			DebugText.autoSize = TextFieldAutoSize.LEFT;
			var Format:TextFormat = new TextFormat();
			Format.font = "Courier New";
			Format.color = 0x441111;
			Format.size = 10;
			DebugText.defaultTextFormat = Format;
			DebugText.selectable = false;
			DebugText.text = "";
			if (CellWorld.c_debug) {
				addChild(DebugText);
			}
			
			
		}
		
		/* Face */
		public function addNewFaceObject(is_update_direction:Boolean = true):Object {
			var face:PhysFace = new PhysFace();
			face.gotoAndStop(1);
			
			var eyes:PhysEyes = new PhysEyes();
			eyes.gotoAndStop(1);
			
			var face_object:Object = {face:face, eyes:eyes, is_update_direction:is_update_direction}
			
			myFaces.push(face_object);
			
			return face_object;
		}
		
		public function updateFaces():void {
			for each (var face_object:Object in myFaces) {
				updateFace(face_object, faceDirection);
			}
		}
		
		public function updateFace(face_object:Object, direction:Point):void {
			var new_direction:Point = new Point(direction.x, direction.y);
			if ( face_object.is_update_direction && (direction.length > 3) ) {
				new_direction.normalize(3);
			}
			
			var face:PhysFace = face_object.face;
			var eyes:PhysEyes = face_object.eyes;
			
			switch(absorbState) {
				case c_absorb:
					eyes.visible = false;
					if (faceState == c_face_squid) {
						face.gotoAndStop("squid_eating_level" + m_face_level);	
					} else {
						face.gotoAndStop("eating_level" + m_face_level);
					}
					break;
				case c_repel:
					
					// eyes
					switch (faceState) {
						case c_face_evil:
						case c_face_squid:
							eyes.visible = false;
							break;
						case c_face_sad:
							eyes.visible = true;
							eyes.gotoAndStop("sad_level" + m_face_level);
							break;
						case c_face_dead:
							eyes.visible = false;
							break;
						case c_face_normal:
						default:
							eyes.visible = true;
							eyes.gotoAndStop("normal_level" + m_face_level);
							break;
					}
					
					// face
					switch (faceState) {
						case c_face_squid:
							face.gotoAndStop("squid_normal_level" + m_face_level);
							break;
						case c_face_scared:
							face.gotoAndStop("scared_level" + m_face_level);
							break;
						case c_face_happy:
							face.gotoAndStop("happy_level" + m_face_level);
							break;
						case c_face_sad:
							face.gotoAndStop("sad_level" + m_face_level);
							break;
						case c_face_dead:
							face.gotoAndStop("dead_level" + m_face_level);
							new_direction.x = 0;
							new_direction.y = 0;
							break;
						case c_face_normal:
						default:
							face.gotoAndStop("normal_level" + m_face_level);
							break;
					}
					
					break;
				default:
					face.gotoAndStop("normal_level" + m_face_level);
					break;
			}
			
			if (face_object.is_update_direction) {
				face.x = new_direction.x;
				face.y = new_direction.y;
			} else {
				face.x = 0;
				face.y = 0;
			}
		}
		
		public function updateFaceDirection(fx:Number, fy:Number):void {
			faceDirection.x = fx;
			faceDirection.y = fy;
			updateFaces();
		}
		
		// when we add a ring, we need to hold a sprite to handle rotating the ring
		// and we need to hold the array of prots on the ring
		public function addRing(draw_ring:Boolean = true):void {
			if (MyRings.length >= c_max_rings) {
				return;
			}
			
			var ring:Object = new Object();
			ring.prots = new Array();
			ring.ring_pos = new Sprite();
			
			// properties
			Nucleus.addChild(ring.ring_pos);
			MyRings.push(ring);
			
			// draw the ring
			if (draw_ring) {
				drawRing(MyRings.length - 1);
			}
			
		}
		
		public function drawRing(ring:int):void {
			var circle:Sprite = getRing(ring).ring_pos;
			circle.graphics.clear();
			circle.graphics.lineStyle(1.5, 0x9999FF);
			circle.graphics.drawCircle(0, 0, getRingLengthFromPosition(ring));
		}
		
		public function removeRing():void {
			if (MyRings.length == 0) {
				return;
			}
			
			var ring:Object = MyRings.pop();
			while(ring.prots.length > 0) {
				breakupProt(ring.prots[0]);
			}
			
			Nucleus.removeChild(ring.ring_pos);
		}
		
		public function updateRings(rings:int) {
			while(rings > MyRings.length) {
				addRing();
			}
			while(rings < MyRings.length) {
				removeRing();
			}
		}
		
		public function getRing(ring:int):Object {
			return MyRings[ring];
		}
		
		public function getRingPositionFromLength(l:Number):int {
			var mid:Number = stats_radius;
			if (l < mid) {
				return 0;
			}
			return int((l - mid) / c_ring_radius_inc) + 1;
		}
		
		public function getRingLengthFromPosition(r:int):Number {
			if (r <= 0) {
				return 0;
			}
			return stats_radius + c_ring_radius_inc*r - (c_ring_radius_inc/2);
		}
		
		public function getRingSize(ring:int):int {
			var ring_size:int = 0;
			
			if ( !isRingOutside(ring) ) {
				ring_size = MyRings[ring].prots.length;
			}
			
			return ring_size;
		}
		
		public function getProt(ring:int, prot:int):CellProt {
			return getRing(ring).prots[prot];
		}
		
		public function calculatePointOnRing(ring:int, angle:Number):Point {
			if (ring > 0) {
				var point1:Point = new Point(0, getRingLengthFromPosition(ring));
				
				var trans1:Matrix = new Matrix();
				trans1.rotate(angle * Math.PI/180);
				
				var trans2:Matrix = new Matrix();
				if (!isRingOutside(ring)) {
					trans2 = Matrix(getRing(ring).ring_pos.transform.matrix);
				}
				
				return trans2.transformPoint(trans1.transformPoint(point1));
			}
			
			return new Point(0, 0);
		}
		
		public function calculateNewBalancedAngleOnRing(ring:int):Number {
			if ( (ring == 0) || (isRingOutside(ring)) ) {
				return 0.0;
			}
			
			var ring_size:int = getRingSize(ring);
			
			if (ring_size <= 0) {
				return -90.0;
			} else if (ring_size == 1) {
				return getProt(ring, 0).myGridObject.getRotation() - 180.0;
			}
			
			var rotations:Array = new Array();
			for (var p:int = 0; p < ring_size; ++p) {
				var rot_entry:Object = new Object();
				rot_entry.object = getProt(ring, p);
				rot_entry.rotation = rot_entry.object.myGridObject.getRotation();
				
				rotations.push(rot_entry);
			}
			
			rotations.sortOn("rotation");
			
			var last_entry:Object = rotations.pop();
			
			var max_rotation:Number = last_entry.rotation;
			var max_length:Number = 0.0;
			
			var next_entry:Object = last_entry;
			while(rotations.length > 0) {
				rot_entry = rotations.pop();
				var dr:Number = rotationCWDistance(next_entry.rotation, rot_entry.rotation);
				if (dr > max_length) {
					max_length = dr;
					max_rotation = rot_entry.rotation;
				}
				next_entry = rot_entry;
			}
			
			dr = rotationCWDistance(last_entry.rotation, next_entry.rotation);
			if (dr > max_length) {
				max_length = dr;
				max_rotation = next_entry.rotation;
			}
			
			return (max_length / 2) + max_rotation;
		}
		
		// get large distance
		public function rotationCWDistance(a:Number, b:Number):Number {
			var v1:Number = b - a;
			if (v1 < 0) {
				return v1 + 360.0;
			}
			
			return v1;
		}
		
		
		// adds a prot to the ring using stage angle
		public function addProt(ring:int, angle:Number, prot:CellProt):void {
			if ( (ring == 0) && (getRingSize(0) != 0) ) {
				throw(new Error("what are you doing!!?") );
				return;
			}
			
			prot.myCell = this;
			prot.m_ring = ring;
			
			if ( isRingOutside(ring) ) {
				breakupProt(prot);
				return;
			}
			
			// if we don't have any room then push it out
			if (getRingSize(ring) + 1 > getMaxRingSize(ring)) {
				moveProt( ring, int(Math.random()*getRingSize(ring)), ring + 1, calculateNewBalancedAngleOnRing(ring + 1) );
			}
			
			
			// set position
			insertProt(ring, prot);
			
			// make sure we move our grid object
			var world_point:Point = calculatePointOnRing(ring, angle).add( myGrid.getWorldFromObject(myGridObject) );
			myGrid.moveObjectWorldTo(prot.myGridObject, world_point);
			
			// make sure to set the prots target distance
			prot.myGridObject.setTargetDistance(getRingLengthFromPosition(ring));
			
			// if our target ring is 0 then don't add our object
			if (ring == 0) {
				myGrid.removeFromGrid(prot.myGridObject);
			} else {
				myGrid.handleTooClose(prot.myGridObject);
			}
			
		}
		
		public function removeProt(prot:CellProt):void {
			// remove prot from ring
			
			// don't remove if it's not even on the cell
			if ( !isRingOutside(prot.m_ring) ) {
				var i:int = getRing(prot.m_ring).prots.indexOf(prot);
				if (i > -1) {
					getRing(prot.m_ring).prots.splice(i, 1);
					
					// update the rest of the prots
					var ring_size:int = getRingSize(prot.m_ring);
					for (i = prot.pos; i < ring_size; i++) {
						getProt(prot.m_ring, i).pos--;
					}
				}
			}
			
			// remove from grid
			myGrid.destroyGridObject(prot.myGridObject);
		}
		
		
		// angle should be local to target ring
		public function moveProt(source_ring:int, source_prot:int, target_ring:int, target_angle:Number):void {
			if (source_ring == target_ring) {
				return;
			}
			
			var prot:CellProt = getProt(source_ring, source_prot);
			
			if ( isRingOutside(target_ring) ) {
				breakupProt(prot);
				return;
			}
			
			// stop the prot from moving around
			prot.myGridObject.moveStop();
			
			// update prot positions
			prot.m_ring = target_ring;
			
			// remove previous prot
			getRing(source_ring).prots.splice(source_prot, 1);
			
			// update the rest of the prots
			var ring_size:int = getRing(source_ring).prots.length;
			for (var p:int = source_prot; p < ring_size; p++) {
				getRing(source_ring).prots[p].pos--;
			}
			
			// insert
			insertProt(target_ring, prot);
			
			
			
			// make sure we move our grid object
			var world_point:Point = calculatePointOnRing(target_ring, target_angle).add( myGrid.getWorldFromObject(myGridObject) );
			if (source_ring == 0) {
				myGrid.addToGrid(prot.myGridObject, world_point);
				myGrid.attachRotatingObject(prot.myGridObject, myGridObject);
			} else {
				myGrid.moveObjectWorldTo(prot.myGridObject, world_point);
			}
			
			// if we are entering the center maybe breakup and get out
			if (target_ring == 0) {
				myGrid.removeFromGrid(prot.myGridObject);
				
				if (absorbState == c_absorb) {
					Nucleus.breakupProt(prot);
					removeProt(prot);
				}
				return;
			}
			
			// make sure to set the prots target distance
			prot.myGridObject.setTargetDistance(getRingLengthFromPosition(target_ring));
			
			myGrid.handleTooClose(prot.myGridObject);
		}
		
		public function breakupProt(prot:CellProt) {
			var local_point:Point = prot.myGridObject.getLocalPoint();
			var grid_handler:Object = myGrid.getGridFromObject(prot.myGridObject);
			var prits:Array = prot.myConstructedPrits;
			var held_prits:Array = prot.releasePrits();
			
			// we need to remove prot first so that the prot does't touch our prits
			removeProt(prot);
			
			while(prot.myConstructedPrits.length > 0) {
				var prit_local_point:Point = local_point.add( new Point(Math.random()*2.0-1.0, Math.random()*2.0-1.0) );
				myGrid.myWorldMap.makeGridObjectFromEntry(myGrid, grid_handler, prit_local_point, prot.myConstructedPrits.pop() );
			}
			
			while(held_prits.length > 0) {
				// TODO: held prits must also be entries right? no?  i'm not sure... I don't think so.
				// hold prits must act like prits in the nucleus.
				//prit = held_prits.pop();
				//prit_local_point = local_point.add( new Point(Math.random()*2.0-1.0, Math.random()*2.0-1.0) );
				/*
				//CellCreator.CreateGridObjectLocal_CellPrit_New(myGrid, grid_handler, prit_local_point, prit);
				var go:GridObject = prit.makeGridObject(grid_handler, local_point);
				myGrid.handleTooClose(go);
				*/
				
				
			}
		}
		
		public function getAllProtObjects():Array {
			var prot_objects:Array =  new Array();
			var num_rings:int = MyRings.length;
			for (var ring:int = 0; ring < num_rings; ring++) {
				var ring_size:int = getRingSize(ring);
				for (var i:int = 0; i < ring_size; i++) {
					prot_objects.push( getProt(ring, i).myGridObject );
				}
			}
			return prot_objects;
		}
		
		public function insertProt(ring:int, prot:CellProt):void {
			prot.pos = getRing(ring).prots.push(prot) - 1;
		}
		
		public function isRingOutside(ring:int):Boolean {
			return (ring >= MyRings.length);
		}
		
		public function isRingInsideNucleus(ring:int):Boolean {
			return (ring <= 0);
		}
		
		public function updateEnable(enable:Boolean):void {
			if ( (enable && (absorbState == c_repel)) ||
			(!enable && (absorbState == c_absorb)) ) {
				return;
			}
			
			if (enable) {
				absorbState = c_repel;
				Nucleus.enable();
			} else {
				absorbState = c_absorb;
				Nucleus.disable();
				
				if (getRingSize(0) > 0) {
					var prot:CellProt = getProt(0, 0);
					Nucleus.breakupProt(prot);
					removeProt( prot );
				}
			}
			updateFaces();
		}
		
		public function getMaxRingSize(ring:int):int {
			switch(ring) {
				case 0:
					return 1;
					break;
				case 1:
					return 9;
					break;
				case 2:
				default:
					return 13;
					break;
			}
			
			return 0;
		}
		
		public function attacked(a:int):void {
			myGridObject.decreaseEnergy(a);
		}
		
		public function increaseEnergy(energy:int):int {
			return Nucleus.increaseEnergy(energy);
		}
		
		public function decreaseEnergy(energy:int):int {
			var de:int = Nucleus.decreaseEnergy(energy);
			
			if (Nucleus.m_is_dead) {
				faceState = c_face_dead;
				die();
			}
			
			return de;
		}
		
		public function die():void {
			// destroy
			myGrid.addExplosion( myGridObject.getGridCol(), myGridObject.getGridRow(), myGridObject.getLocalPoint(), stats_radius );
			myGrid.destroyGridObject(myGridObject);
		}
		
		public function getEnergy():int {
			return Nucleus.m_energy;
		}
		
		public function getMaxEnergy():int {
			return Nucleus.m_max_energy;
		}
		
		public virtual function levelUp():void {
			// first make sure to close mouth
			updateEnable(true);
			
			// level up
			levelChange(stats_level+1);
		}
		
		public virtual function absorbedPrit(prit:CellPrit):void {};
		
		public function addPrit(prit:CellPrit, pos:int = 0):void {};
		
		public function removePrit(i:int):void {};
		
		public virtual function removed():void {};
		
		public virtual function reset():void {};
		
		public virtual function checkGridUnder(grid_handler:Object):void {};
		
		public virtual function report(report_type:uint, args:Object):void {};
		
		/* Level */
		public function levelChange(new_level:int):void {
			var level_stats:Object = getLevelStats(new_level);
			stats_radius = level_stats.radius;
			stats_mass = level_stats.mass;
			stats_num_rings = level_stats.num_rings;
			stats_max_speed = level_stats.max_speed;
			stats_max_view = level_stats.max_view;
			
			if (stats_num_rings != MyRings.length) {
				updateRings(stats_num_rings);
			}
			
			if (myGridObject) {
				if (stats_mass != myGridObject.mass) {
					myGrid.updateMass(myGridObject, stats_mass);
				}
				if (stats_max_speed != myGridObject.move_max_speed) {
					myGrid.updateMoveMaxSpeed(myGridObject, stats_max_speed);
				}
				// radius is last because this can cause a hit
				if (stats_radius != myGridObject.boundingRadius) {
					myGrid.updateBoundingRadius(myGridObject, stats_radius);
				}
			}
			
			if (m_is_player) {
				CellWorld.newZoomTo(stats_max_view);
			}
			
			stats_level = new_level;
			Nucleus.updateLevel(stats_level);
		}
		
		public static function getLevelStats(level:int):Object {
			var level_stats:Object = new Object();
			switch(level) {
				case 0:
				default:
					level_stats.radius = 18.0;
					level_stats.mass = 1.0;
					level_stats.num_rings = 1;
					level_stats.max_speed = 6.0;
					level_stats.max_view = 1.35;
					level_stats.face_level = 0;
					break;
				case 1:
					level_stats.radius = 18.0;
					level_stats.mass = 2.0;
					level_stats.num_rings = 1;
					level_stats.max_speed = 6.3;
					level_stats.max_view = 1.25;
					level_stats.face_level = 0;
					break;
				case 2:
					level_stats.radius = 18.0;
					level_stats.mass = 2.5;
					level_stats.num_rings = 2;
					level_stats.max_speed = 7.0;
					level_stats.max_view = 1.15;
					level_stats.face_level = 0;
					break;
				case 3:
					level_stats.radius = 24.0;
					level_stats.mass = 3.0;
					level_stats.num_rings = 2;
					level_stats.max_speed = 9.0;
					level_stats.max_view = 1.0;
					level_stats.face_level = 1;
					break;
			}
			
			return level_stats;
		}
		
		/* WorldMap */
		public virtual function resetFromMapEntry(map_entry:Object):void {
			// map entries
			stats_radius = map_entry.radius;
			stats_mass = map_entry.mass;
			stats_num_rings = map_entry.num_rings;
			stats_max_speed = map_entry.max_speed;
			stats_max_view = map_entry.max_view;
			
			stats_level = map_entry.level;
			m_face_level = map_entry.face_level;
			
			faceDirection.x = map_entry.face_direction_x;
			faceDirection.y = map_entry.face_direction_y;
			faceState = map_entry.face_state;
			
			absorbState = map_entry.absorb_state;
			
			// updates
			if (stats_num_rings != MyRings.length) {
				updateRings(stats_num_rings);
			}
			
			if (m_is_player) {
				CellWorld.newZoomTo(stats_max_view);
			}
			
			// face
			updateFaces();
			
			// nucleus
			Nucleus.resetFromMapEntry(map_entry);
			
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		public virtual function updateMapEntry(map_entry:Object):Object {
			// nucleus
			map_entry = Nucleus.updateMapEntry(map_entry);
			
			// stats
			map_entry.radius = stats_radius;
			map_entry.mass = stats_mass;
			map_entry.num_rings = stats_num_rings;
			map_entry.max_speed = stats_max_speed;
			map_entry.max_view = stats_max_view;
			
			// current stats
			map_entry.level = stats_level;
			map_entry.face_level = m_face_level;
			
			map_entry.face_direction_x = faceDirection.x;
			map_entry.face_direction_y = faceDirection.y;
			
			map_entry.face_state = faceState;
			
			map_entry.absorb_state = absorbState;
			
			map_entry.is_player = m_is_player;
			
			return map_entry;
		}
		
		public static function updateMapEntry_NewLevel(map_entry:Object, level:int, energy:int = 0):Object {
			var level_stats:Object = getLevelStats(level);
			map_entry.radius = level_stats.radius;
			map_entry.mass = level_stats.mass;
			map_entry.num_rings = level_stats.num_rings;
			map_entry.max_speed = level_stats.max_speed;
			map_entry.max_view = level_stats.max_view;
			
			map_entry.level = level;
			
			map_entry.face_level = level_stats.face_level;
			map_entry.face_direction_x = 0;
			map_entry.face_direction_y = 0;
			
			map_entry.face_state = c_face_normal;
			
			map_entry.absorb_state = c_repel;
			
			map_entry.is_player = false;
			
			map_entry = CellNucleus.updateMapEntry_NewLevel(map_entry, level, energy);
			
			return map_entry;
		}
	}
	
}