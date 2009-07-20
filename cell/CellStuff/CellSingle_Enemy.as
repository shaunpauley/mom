package CellStuff {
	
	import flash.display.Stage;
	import flash.display.MovieClip;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.geom.Point;
	
	public class CellSingle_Enemy extends CellSingle {
		
		private var myCellPlayer:CellSingle_Player;
		
		public var m_enemy_state:uint;
		public var m_after_absorb_state:uint;
		
		public var m_sight_range:Number;
		public var m_absorb_range:Number;
		
		public var m_looking_object_type:uint;
		public var m_looking_second_type:uint;
		public var m_looking_direction:Point;
		
		public var m_is_move_looking:Boolean;
		
		public var m_chasing_object:GridObject;
		
		public var m_path_count:int;
		
		public static const c_default_sight_range:Number = 200;
		public static const c_default_absorb_range:Number = 70;
		
		public static const c_move_force_max:Number = 15.0;
		public static const c_move_force_min:Number = 5.0;
		public static const c_default_path_count:int = 15;
		public static const c_scared_path_count:int = 7;
		
		public static const c_enemy_state_none:uint			= 0x000000;
		public static const c_enemy_state_looking:uint		= 0x000001;
		public static const c_enemy_state_absorbing:uint	= 0x000002;
		public static const c_enemy_state_scared:uint		= 0x000003;
		
		public static const c_enemy_state_squid_looking:uint		= 0x000004;
		public static const c_enemy_state_sick_looking:uint			= 0x000006;
		
		
		public function CellSingle_Enemy(grid:CellGridDisplay, cell_player:CellSingle_Player, map_entry:Object) {
			myCellPlayer = cell_player;
			
			m_enemy_state = map_entry.enemy_state;
			m_after_absorb_state = map_entry.after_absorb_state;
			
			m_sight_range = map_entry.sight_range;
			m_absorb_range = map_entry.absorb_range;
			
			m_looking_object_type = map_entry.looking_object_type;
			m_looking_second_type = map_entry.looking_second_type;
			m_looking_direction = new Point(map_entry.looking_direction_x, map_entry.looking_direction_y);
			m_is_move_looking = map_entry.is_move_looking;
			
			m_path_count = map_entry.path_count;
			
			m_chasing_object = null;
			
			super(grid, map_entry);
			
			mouseEnabled = true;
			mouseChildren = true;
			
			addEventListener(MouseEvent.CLICK, testClick);
		}
		
		public function testClick(event:MouseEvent):void {
			throw( new Error("error") );
		}
		
		/* Callbacks */
		public function newPathCallback():void {
			handleState();
			newPath();
			myGridObject.newTimedEvent(newPathCallback, Math.random()*m_path_count+5);
		}
		
		/* Path */
		public function newPath():void {
			var dv:Point = new Point(0, 0);
			if (m_is_move_looking) {
				move_speed = Math.random()*(c_move_force_max-c_move_force_min)+c_move_force_min;
				dv.x = m_looking_direction.x*move_speed;
				dv.y = m_looking_direction.y*move_speed;
				
				updateFaceDirection(dv.x, dv.y);
				myGridObject.moveAdd(dv);
			} else if (m_enemy_state == c_enemy_state_scared) {
				move_speed = Math.random()*c_move_force_max+c_move_force_min;
				dv.x = m_looking_direction.x*move_speed;
				dv.y = m_looking_direction.y*move_speed;
				
				updateFaceDirection(-dv.x, -dv.y);
				myGridObject.moveAdd(dv);
			} else {
				dv.x = Math.random()*10-5;
				dv.y = Math.random()*10-5;
				dv.normalize(1);
				
				var move_speed:Number = Math.random()*(c_move_force_max-c_move_force_min)+c_move_force_min;
				dv.x *= move_speed;
				dv.y *= move_speed;
				
				updateFaceDirection(dv.x, dv.y);
				myGridObject.moveAdd(dv);
			}
		}
		
		/* State */
		public function handleState():void {
			var next_state:uint = m_enemy_state;
			switch(m_enemy_state) {
				case c_enemy_state_none:
					// do nothing
					break;
				case c_enemy_state_looking:
					next_state = handleStateLooking();
					break;
				case c_enemy_state_absorbing:
					next_state = handleStateAbsorbing();
					break;
				case c_enemy_state_scared:
					next_state = handleStateScared();
					break;
				case c_enemy_state_sick_looking:
					next_state = handleStateSickLooking();
				case c_enemy_state_squid_looking:
					next_state = handleStateSquidLooking();
				default:
					break;
			}
			
			m_enemy_state = next_state;
		}
		
		public function handleStateLooking():uint {
			var next_state:uint = c_enemy_state_looking;
			
			// check player
			m_is_move_looking = false;
			if (myCellPlayer && (myCellPlayer.stats_level > stats_level)) {
				m_looking_direction = myGrid.getDistance(myCellPlayer.myGridObject, myGridObject);
				if (m_looking_direction.length < m_sight_range) {
					next_state = c_enemy_state_scared;
					faceState = c_face_scared;
					m_path_count = c_scared_path_count;
					m_looking_direction.normalize(1);
					m_is_move_looking = true;
					return next_state;
				}
			}
			
			if (faceState == c_face_scared) {
				faceState = c_face_normal;
				m_path_count = c_default_path_count;
			}
			
			next_state = handleChasingObject(next_state, m_looking_object_type, m_looking_second_type);
			
			return next_state;
		}
		
		public function handleStateAbsorbing():uint {
			var next_state:uint = c_enemy_state_absorbing;
			
			if (absorbState == c_repel) {
				updateEnable(false);
			}
			
			if (m_chasing_object && !m_chasing_object.is_removed) {
				m_looking_direction = myGrid.getDistance(myGridObject, m_chasing_object);
				if (m_looking_direction.length >= m_absorb_range) {
					next_state = m_after_absorb_state;
					if (absorbState == c_absorb) {
						updateEnable(true);
					}
				}
				m_looking_direction.normalize(1);
				m_is_move_looking = true;
			} else {
				if (absorbState == c_absorb) {
					updateEnable(true);
				}
				next_state = m_after_absorb_state;
				m_is_move_looking = false;
			}
			
			return next_state;
		}
		
		public function handleStateScared():uint {
			var next_state:uint = c_enemy_state_scared;
			
			m_looking_direction = myGrid.getDistance(myCellPlayer.myGridObject, myGridObject);
			if ( (myCellPlayer.stats_level <= stats_level) || (m_looking_direction.length >= m_sight_range) ) {
				next_state = c_enemy_state_looking;
			}
			m_looking_direction.normalize(1);
			m_is_move_looking = true;
			
			return next_state;
		}
		
		public function handleStateSickLooking():uint {
			var next_state:uint = c_enemy_state_sick_looking;
			
			m_is_move_looking = false;
			
			next_state = handleChasingObject(next_state, m_looking_object_type, m_looking_second_type);
			
			if (!m_is_move_looking) {
				m_looking_direction = myGrid.getDistance(myCellPlayer.myGridObject, myGridObject);
				if ( (m_looking_direction.length < m_sight_range) && (m_looking_direction.length >= 100) ) {
					m_looking_direction.normalize(-1);
					m_is_move_looking = true;
				}
			}
			
			return next_state;
		}
		
		public function handleStateSquidLooking():uint {
			var next_state:uint = c_enemy_state_squid_looking;
			
			m_is_move_looking = false;
			
			next_state = handleChasingObject(next_state, GridObject.c_type_prot, CellProt.c_type_fish);
			
			if (next_state == c_enemy_state_squid_looking) {
				next_state = handleChasingObject(next_state, m_looking_object_type, m_looking_second_type);
			}
			
			return next_state;
		}
		
		public function handleChasingObject(next_state:uint, looking_object_type:uint, looking_object_second_type:uint):uint {
			if (!m_chasing_object || m_chasing_object.is_removed) {
				m_chasing_object = myGrid.getNearestObjectInRadius(myGridObject, m_sight_range, looking_object_type, looking_object_second_type);
			} 
			
			if (m_chasing_object && !m_chasing_object.is_removed) {
				m_looking_direction = myGrid.getDistance(myGridObject, m_chasing_object);
				if (m_looking_direction.length < m_sight_range) {
					if (m_looking_direction.length < m_absorb_range) {
						m_after_absorb_state = next_state;
						next_state = c_enemy_state_absorbing;
						if (absorbState == c_repel) {
							updateEnable(false);
						}
					}
					m_looking_direction.normalize(1);
					m_is_move_looking = true;
				} else {
					m_chasing_object = myGrid.getNearestObjectInRadius(myGridObject, m_sight_range, looking_object_type, looking_object_second_type);
					if (m_chasing_object && !m_chasing_object.is_removed) {
						m_looking_direction = myGrid.getDistance(myGridObject, m_chasing_object);
						m_looking_direction.normalize(1);
						m_is_move_looking = true;
					}
				}
			}
			
			return next_state;
		}
		
		/* Override Calls */
		
		public override function reset():void {
			newPathCallback();
		}
		
		public override function removed():void {
			// remove timed events
			myGridObject.removeTimedEvent();
		}
		
		/* Level */
		public override function levelChange(new_level:int):void {
			super.levelChange(new_level);
			var level_stats:Object = getLevelStats(new_level);
		}
		
		public static function getLevelStats(level:int):Object {
			var level_stats:Object = new Object();
			switch(level) {
				case 0:
				default:
					level_stats.enemy_state = c_enemy_state_looking;
					level_stats.sight_range = c_default_sight_range;
					level_stats.absorb_range = c_default_absorb_range;
					
					level_stats.looking_object_type = GridObject.c_type_prit;
					level_stats.looking_second_type = CellPrit.c_type_default;
					
					level_stats.path_count = c_default_path_count;
					
					level_stats.face_state = c_face_normal;
					break;
				case 1:
					level_stats.enemy_state = c_enemy_state_squid_looking;
					level_stats.sight_range = c_default_sight_range + 50;
					level_stats.absorb_range = c_default_absorb_range;
					
					level_stats.looking_object_type = GridObject.c_type_prit;
					level_stats.looking_second_type = CellPrit.c_type_fish;
					
					level_stats.path_count = c_default_path_count + 5;
					
					level_stats.face_state = c_face_squid;
					break;
			}
			
			return level_stats;
		}
		
		/* Map Entry */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			
			map_entry.enemy_state = m_enemy_state;
			map_entry.after_absorb_state = m_after_absorb_state;
			
			map_entry.sight_range = m_sight_range;
			map_entry.absorb_range = m_absorb_range;
			
			map_entry.looking_object_type = m_looking_object_type;
			map_entry.looking_second_type = m_looking_second_type;
			map_entry.looking_direction_x = m_looking_direction.x;
			map_entry.looking_direction_y = m_looking_direction.y;
			map_entry.is_move_looking = m_is_move_looking;
			
			map_entry.path_count = m_path_count;
			
			return map_entry;
		}
		
		public static function updateMapEntry_NewLevel(map_entry:Object, level:int, energy:int = 0):Object {
			map_entry = CellSingle.updateMapEntry_NewLevel(map_entry, level, energy);
			
			var level_stats:Object = getLevelStats(level);
			
			map_entry.enemy_state = level_stats.enemy_state;
			map_entry.after_absorb_state = c_enemy_state_none;
			
			map_entry.sight_range = level_stats.sight_range;
			map_entry.absorb_range = level_stats.absorb_range;
			map_entry.looking_object_type = level_stats.looking_object_type;
			map_entry.looking_second_type = level_stats.looking_second_type;
			map_entry.looking_direction_x = 0;
			map_entry.looking_direction_y = 0;
			map_entry.is_move_looking = false;
			map_entry.path_count = level_stats.path_count;
			
			map_entry.face_state = level_stats.face_state;
			
			return map_entry;
		}			
	}
}