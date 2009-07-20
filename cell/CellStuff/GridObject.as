package CellStuff {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import flash.geom.Point;

	public class GridObject {
		
		public var myGridHandler:Object
		public var myGridBoxes:Array;
		
		public var myTimedEvent:Object;
		
		public var world_map_level:int;
		
		public var local_point:Point;
		
		public var sprite:Sprite;
		
		public var boundingRadius:Number;
		
		public var type:uint;
		
		public var absorbed:Array;
		public var areas_attached:Array;
		public var areas_in:Array;
		public var attached:Array;
		
		public var is_attached:Boolean;
		public var attach_source:GridObject;
		public var attach_socket:Sprite;
		public var attached_point:Point;
		public var attached_target_distance:Number;
		
		public var is_moving:Boolean;
		public var is_moved:Boolean;
		public var is_outside_attach_target_distance:Boolean;
		
		public var in_area_cooldown:int;
		
		public var prit:CellPrit;
		public var prot:CellProt;
		public var cell:CellSingle;
		public var area:CellArea;
		
		public var is_removed:Boolean;
		
		public var move_speed:Point;
		public var move_accel:Number;
		public var move_max_speed:Number;
		public var move_is_entry:Boolean;
		
		public var rotate_speed:Number;
		public var rotate_accel:Number;
		public var rotate_max_speed:Number;
		public var rotate_target:Number;
		public var rotate_has_target:Boolean;
		
		public var mass:Number;
		
		public var is_absorbed:Boolean;
		
		public var rollups:Array;
		
		public var text_object:Object;
		
		public var temp_grid_box_selected:Boolean;
		
		public static const c_type_prit:uint = 0x000001;
		public static const c_type_prot:uint = 0x000002;
		public static const c_type_cell:uint = 0x000003;
		public static const c_type_area:uint = 0x000004;
		public static const c_type_other:uint = 0x000005;
		
		public static const c_default_friction:Number = -0.5;
		public static const c_default_max_move_speed:Number = 12.0;
		public static const c_default_max_rotate_speed:Number = 10.0;
		
		public static const c_max_mass:Number = 10000;
		public static const c_min_mass:Number = 0;
		
		public static const c_energy_increase_rollup:int 	= 0;
		public static const c_energy_decrease_rollup:int 	= 1;
		public static const c_levelup_rollup:int 			= 2;
		
		public static const c_report_type_enter:uint 	= 0x000001;
		public static const c_report_type_update:uint 	= 0x000002;
		public static const c_report_type_leave:uint 	= 0x000003;
		
		public static const c_area_cooldown:int = int(CellWorld.c_fps/2);  // half a second
		
		public function GridObject(go_type:uint, bR:Number, gmass:Number, max_speed:Number, wm_level:int = -1)
		{
			myGridHandler = null;
			myGridBoxes = new Array();
			
			// set blank defaults
			myTimedEvent = null;
			
			local_point = new Point(-1, -1);
			
			sprite = null;
			
			// set attributes
			world_map_level = wm_level;
			
			boundingRadius = bR;
			type = go_type;
			absorbed = new Array();
			
			areas_attached = new Array();
			areas_in = new Array();
			
			attached = new Array();
			is_attached = false;
			attach_source = null;
			attach_socket = null;
			attached_point = new Point(0, 0);
			attached_target_distance = 0;
			
			is_moving = false;
			is_moved = false;
			is_outside_attach_target_distance = false;
			
			in_area_cooldown = 0;
			
			prit = null;
			prot = null;
			cell = null;
			area = null;
			
			is_removed = false;
			
			move_speed = new Point(0, 0);
			move_accel = c_default_friction;
			move_max_speed = max_speed;
			move_is_entry = false;
			
			rotate_speed = 0;
			rotate_accel = c_default_friction;
			rotate_max_speed = c_default_max_rotate_speed;
			rotate_target = 0;
			rotate_has_target = false;
			
			mass = gmass;
			
			is_absorbed = false;
			
			rollups = new Array(null, null, null);
			
			text_object = null;
			
			temp_grid_box_selected = false;
			
			initSprite();
		}
		
		// draw our debug sprite
		public function initSprite():void {
			// make our sprite
			sprite = new Sprite();
			
			if (CellWorld.c_debug) {
				// draw bounding circle
				var circle:Sprite = new Sprite();
				circle.graphics.lineStyle(1.5, 0xFF6699);
				circle.graphics.drawCircle(0, 0, boundingRadius);
				sprite.addChild(circle);
			}
			
		}
		
		// todo: do we need this!?
		public function initLocationLocal(lp:Point):void {
			setLocalPoint(lp);
			sprite.x = local_point.x;
			sprite.y = local_point.y;
		}
		
		public function initLocationFromObject(go:GridObject):void {
			// copy location
			setLocalPoint( go.local_point.clone() );
		}
		
		public function getLocalPoint():Point {
			return local_point;
		}
		
		public function setLocalPoint(lp:Point):void {
			local_point = lp;
		}
		
		public function getGridCol():int {
			return myGridHandler.col;
		}
		
		public function getGridRow():int {
			return myGridHandler.row;
		}
		
		public function getSecondaryType():uint {
			var second_type:uint = 0x000000;
			switch(type) {
				case c_type_area:
					second_type = area.m_type;
					break;
				case c_type_prit:
					second_type = prit.m_type;
					break;
				case c_type_prot:
					second_type = prot.m_type;
					break;
			}
			return second_type;
		}
		
		public function setTargetDistance(atl:Number = -1):void {
			if (atl > -1) {
				attached_target_distance = atl;
			} else {
				attached_target_distance = attached_point.length;
			}
		}
		
		public function addToGridBox(gb:Array):void {
			if (gb != null) {
				var i:int = myGridBoxes.indexOf(gb);
				if (i < 0) {
					myGridBoxes.push(gb);
					gb.push(this);
				}
			}
		}
		
		public function removeFromGridBoxes():void {
			while (myGridBoxes.length > 0) {
				var gb:Array = myGridBoxes.pop();
				gb.splice( gb.indexOf(this), 1);
			}
		}
		
		public function canAbsorbObject(go:GridObject):Boolean {
			return canAbsorb() && !go.is_absorbed && (mass >= go.mass) && go.canBeAbsorbed() && go.canBeAbsorbedBy(this);
		}
		
		public function canAbsorb():Boolean {
			if ( ((type == c_type_prot) && (prot.canHoldPrit(absorbed.length+1))) || 
			((type == c_type_cell) && (cell.Nucleus.canAbsorbPrit())) ) {
				return true;
			}
			return false;
		}
		
		public function canBeAbsorbed():Boolean {
			if (type == c_type_prit) {
				return prit.canBeAbsorbed();
			}
			
			return false;
		}
		
		public function canBeAbsorbedBy(go:GridObject):Boolean {
			if (type == c_type_prit) {
				return prit.canBeAbsorbedBy(go);
			}
			
			return false;
		}
		
		public function canBeAttacked():Boolean {
			if (type == c_type_prit) {
				return prit.canBeAttacked();
			} else if (type == c_type_prot) {
				return prot.canBeAttacked();
			}
			
			return true;
		}
		
		public function removeObject():void {
			is_removed = true;
			if (type == c_type_prit) {
				prit.removed();
			}
			
			if (type == c_type_prot) {
				prot.removed();
			}
			
			if (type == c_type_cell) {
				cell.removed();
			}
			
			if (type == c_type_area) {
				area.removed();
			}
			
			trimObject();
			
			// todo: remove more stuff?
			CellWorld.removeObjectMove(this);
		}
		
		public function getGridObjectsSet():Array {
			var grid_objects:Array = new Array();
			for (var i:int = 0; i < myGridBoxes.length; i++) {
				var grid_box:Array = myGridBoxes[i];
				var this_found:Boolean = false;
				for (var j:int = 0; j < grid_box.length; j++) {
					var go:GridObject = grid_box[j];
					// we use a flag to determine if we already added the object to the list
					// this is much faster than checking the list for the object each time
					if ( (this_found || (go != this)) && (!go.is_removed) && (!go.temp_grid_box_selected) ) {
						go.temp_grid_box_selected = true;
						grid_objects.push(go);
					} else if (!this_found && (go == this) ) {
						this_found = true;
					}
				}
			}
			
			// reset selected
			for (i = 0; i < grid_objects.length; i++) {
				grid_objects[i].temp_grid_box_selected = false;
			}
			return grid_objects;
		}
		
		// used for adding to CellWorldMap as an entry
		public function trimObject():void {
			// remove myGridHandler
			myGridHandler = null;
			
			// remove from GridBoxes
			removeFromGridBoxes();
			
			// remove and delete sprite
			sprite = null;
			
			cell = null;
			prit = null;
			prot = null;
			area = null;
		}
		
		public function absorb(go:GridObject):void {
			absorbed.push(go);
			go.beingAbsorbed(this);
			CellWorld.addAbsorbingObject(this);
		}
		
		public function beingAbsorbed(go:GridObject):void {
			is_absorbed = true;
			if (type == c_type_prit) {
				prit.absorbed(go);
			}
			// stop moving
			moveStop();
		}
		
		public function attacked(a:int):void {
			if (type == c_type_cell) {
				cell.attacked(a);
			} else if (type == c_type_prit) {
				prit.attacked(a);
			}
		}
		
		public function upgraded(a:int):void {
			if (type == c_type_prot) {
				prot.upgraded(a);
			}
		}
		
		// todo: do we need to check removed?
		public function increaseEnergy(a:int):int {
			if (is_removed) {
				return 0;
			}
			
			var de:int = a;
			if (type == c_type_cell) {
				de = cell.increaseEnergy(a);
			} else if (type == c_type_prit) {
				de = prit.increaseEnergy(a);
			}
			
			if (de > 0) {
				CellWorld.changeEnergy(CellWorld.c_rollup_energy_increase, c_energy_increase_rollup, this, de);
			} else if ( getEnergy() == getMaxEnergy() ) {
				CellWorld.changeEnergy(CellWorld.c_rollup_energy_full, c_energy_increase_rollup, this, de);
			}
			
			return de;
		}
		
		// todo: do we need to check removed?
		public function decreaseEnergy(a:int):int {
			if (is_removed) {
				return 0;
			}
			
			var de:int = a;
			if (type == c_type_cell) {
				de = cell.decreaseEnergy(a);
			} else if (type == c_type_prit) {
				de = prit.decreaseEnergy(a);
			}
			
			if (de > 0) {
				CellWorld.changeEnergy(CellWorld.c_rollup_energy_decrease, c_energy_decrease_rollup, this, de);
			} else if (getEnergy() == 0) {
				CellWorld.changeEnergy(CellWorld.c_rollup_energy_empty, c_energy_decrease_rollup, this, de);
			} else if (getEnergy() < 0) {
				CellWorld.changeEnergy(CellWorld.c_rollup_energy_dead, c_energy_decrease_rollup, this, de);
			}
			
			return de;
		}
		
		public function addArea(area:CellArea):void {
			var i:int = areas_in.indexOf(area);
			if (i < 0) {
				areas_in.push(area);
			}
		}
		
		public function removeArea(area:CellArea):void {
			var i:int = areas_in.indexOf(area);
			if (i > -1) {
				areas_in.splice(i, 1);
			}
		}
		
		public function isAlreadyInArea(area:CellArea):Boolean {
			return (areas_in.indexOf(area) > -1);
		}
		
		public function checkAreaEnabled():Boolean {
			return (type != c_type_area) || (area.m_is_enabled);
		}
		
		public function updateAreaCooldown():void {
			in_area_cooldown = c_area_cooldown;
		}
		
		/* TODO: DO THIS
		public function moved(dv:Point):void {
			if (type == c_type_cell) {
				cell.moved();
			}
		}
		*/
		
		public function checkGridUnder(grid_handler:Object):void {
			if ( (type == c_type_cell) && (cell.m_is_player) ) {
				cell.checkGridUnder(grid_handler);
			}
		}
		
		// todo: do we need to check removed?
		public function getEnergy():int {
			var energy:int = 0;
			if (!is_removed) {
				if (type == c_type_cell) {
					energy = cell.getEnergy();
				} else if (type == c_type_prit) {
					energy = prit.m_energy;
				}
			}
			
			return energy;
		}
		
		public function getMaxEnergy():int {
			var max_energy:int = 0;
			if (!is_removed) {
				if (type == c_type_cell) {
					max_energy = cell.getMaxEnergy();
				} else if (type == c_type_prit) {
					max_energy = prit.m_max_energy;
				}
			}
			return max_energy;
		}
		
		/* Movement */
		public function getMovement():Point {
			return move_speed;
		}
		
		public function move(speed:Point):void {
			move_speed.x = speed.x;
			move_speed.y = speed.y
			if (move_speed.length > move_max_speed) {
				move_speed.normalize(move_max_speed);
			}
			checkMoveEntry();
		}
		
		public function moveAdd(speed:Point):void {
			move_speed.x += speed.x;
			move_speed.y += speed.y;
			if (move_speed.length > move_max_speed) {
				move_speed.normalize(move_max_speed);
			}
			checkMoveEntry();
		}
		
		public function isMovementStop():Boolean {
			return (move_speed.length == 0);
		}
		
		public function getRotation():Number {
			return attach_socket.rotation;
		}
		
		public function rotate(rs:Number, has_target:Boolean = false, t:Number = 0):void {
			rotate_speed = rs;
			if (Math.abs(rotate_speed) > rotate_max_speed) {
				rotate_speed = rotate_max_speed*(rotate_speed<0?-1:1);
			}
			rotate_has_target = has_target;
			rotate_target = t;
			checkMoveEntry();
		}
		
		public function rotateAdd(rs:Number):void {
			rotate_speed += rs;
			if (Math.abs(rotate_speed) > rotate_max_speed) {
				rotate_speed = rotate_max_speed*(rotate_speed<0?-1:1);
			}
			checkMoveEntry();
		}
		
		public function isRotationStop():Boolean {
			return (rotate_speed == 0);
		}
		
		public function moveStop():void {
			move_speed.x = 0;
			move_speed.y = 0;
			move_accel = c_default_friction;
			
			rotate_speed = 0;
			rotate_accel = c_default_friction;
			rotate_target = 0;
			rotate_has_target = false;
			CellWorld.removeObjectMove(this);
		}
		
		public function moveStop_Slow():void {
			move_accel = -(move_speed.length/2.3);
			checkMoveEntry();
		}
		
		public function checkMoveEntry():void {
			if (!move_is_entry) {
				move_is_entry = true;
				CellWorld.addObjectMove(this);
			}
		}
		
		public function checkMoved():void {
			if (is_attached && !is_moved) {
				CellWorld.myMovedAttachedObjects.push(this);
				is_moved = true;
			}
		}
		
		/* Reporting */
		public function report(report_type:uint, args:Object):void {
			if (type == c_type_prit) {
				prit.report(report_type, args);
			} else if (type == c_type_prot) {
				prot.report(report_type, args);
			} else if (type == c_type_cell) {
				cell.report(report_type, args);
			}
		}
		
		/* Text */
		public function addText(texts:Array, is_replace:Boolean = false):void {
			
		}
		
		/* Timed Events */		
		public function newTimedEvent(callback:Function, t:uint, recurring:Boolean = false):void {
			if (myTimedEvent) {
				removeTimedEvent();
			}
			CellWorld.newTimedEvent(this, callback, t, recurring);
		}
		
		public function removeTimedEvent():void {
			if (myTimedEvent) {
				CellWorld.removeFromTimedEvents(this);
			}
		}
		
		/*Map Entry*/
		public function makeMapEntry():Object {
			var map_entry:Object = updateMapEntry(new Object());
			
			switch(type) {
				case c_type_cell:
					map_entry = cell.updateMapEntry(map_entry);
					break;
				case c_type_prit:
					map_entry = prit.updateMapEntry(map_entry);
					break;
				case c_type_prot:
					map_entry = prot.updateMapEntry(map_entry);
					break;
				case c_type_area:
					map_entry = area.updateMapEntry(map_entry);
					break;
				default:
					break;
			}
			
			// handle attached
			map_entry.attached = new Array();
			for each (var go:GridObject in attached) {
				map_entry.attached.push( go.makeMapEntry() );
			}
			
			return map_entry;
		}
		
		public function updateMapEntry(map_entry:Object):Object {
			map_entry.local_point = getLocalPoint();
			map_entry.type = type;
			map_entry.radius = boundingRadius;
			map_entry.mass = mass;
			
			if (text_object) {
				map_entry.text_object = text_object;
				text_object.map_entry = map_entry;
				map_entry.grid_object = null;
			}
			
			if (attach_socket) {
				map_entry.angle = attach_socket.rotation;
			}
			
			return map_entry;
		}
		
		public function isWorldMapLevel(world_map:CellWorldMap):Boolean {
			return (world_map_level < 0) || (world_map_level == world_map.level);
		}
		
		public function toString():String {
			var str:String = new String();
			str += "go:";
			str += "\n\tmyGridHandler==null: " + (myGridHandler==null);
			str += "\n\tmyGridBoxes.length: " + myGridBoxes.length;
			str += "\n\tworld_map_level: " + world_map_level;
			str += "\n\tsprite==null: " + (sprite==null);
			str += "\n\tlocal_point: " + local_point;
			str += "\n\tboundingRadius: " + boundingRadius;
			str += "\n\ttype: " + type;
			str += "\n\tabsorbed: " + absorbed;
			str += "\n\tareas_attached.length: " + areas_attached.length;
			str += "\n\tareas_in.length: " + areas_in.length;
			str += "\n\tattached==null: " + (attached==null);
			str += "\n\tis_attached: " + is_attached;
			str += "\n\tis_absorbed: " + is_absorbed;
			str += "\n\tattach_source==null: " + (attach_source==null);
			str += "\n\tattach_socket==null: " + (attach_socket==null);
			str += "\n\tis_moving: " + is_moving;
			str += "\n\tprit==null: " + (prit==null);
			str += "\n\tprot==null: " + (prot==null);
			str += "\n\tcell==null: " + (cell==null);
			str += "\n\tarea==null: " + (area==null);
			str += "\n\tis_removed: " + is_removed;
			str += "\n\tmove_speed: " + move_speed;
			str += "\n\tmove_accel: " + move_accel;
			return str;
		}
	}
}