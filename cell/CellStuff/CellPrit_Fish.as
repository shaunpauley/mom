package CellStuff {
	import flash.display.MovieClip;
	
	import flash.geom.Point;
	
	public class CellPrit_Fish extends CellPrit_Move{
		
		public var m_fish_level:int;
		
		public var m_fish_state:uint;
		public var m_fish_moving_state:uint;
		
		public var m_fish_direction:Point;
		
		public static const c_fish_state_disable:uint 	= 0x000000;
		public static const c_fish_state_enable:uint 	= 0x000001;
		
		public static const c_fish_moving_looking:uint 	= 0x000000;
		public static const c_fish_moving_chasing:uint 	= 0x000001;
		public static const c_fish_moving_running:uint 	= 0x000002;
		
		public static const c_fish_level_green:int	= 0;
		public static const c_fish_level_blue:int	= 1;
		public static const c_fish_level_red:int	= 2;
		
		public function CellPrit_Fish(grid:CellGridDisplay, map_entry:Object) {
			
			m_fish_level = map_entry.fish_level;
			
			super(grid, map_entry);
			
			m_fish_state = map_entry.fish_state;
			m_fish_moving_state = map_entry.fish_moving_state;
			
			m_fish_direction = map_entry.fish_direction;
			
			updateFish();
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Fish();
			prit.rotation = -90;
			if (m_fish_state == c_fish_state_enable) {
				prit.gotoAndPlay("enable_level" + m_fish_level);
			} else {
				prit.gotoAndStop("disable");
			}
			return prit;
		}
		
		public function updateFish():void {
			if (m_fish_state == c_fish_state_enable) {
				pritsGotoAndPlay("enable_level" + m_fish_level);
			} else {
				pritsGotoAndStop("disable");
			}
		}
		
		public override function absorbed(go:GridObject):void {
			super.absorbed(go);
			m_fish_state = c_fish_state_disable;
			updateFish();
		}
		
		public override function reset():void {
			super.reset();
			m_fish_state = c_fish_state_enable;
			updateFish();
		}
		
		public override function canBeAbsorbedBy(go:GridObject):Boolean {
			if ( (m_fish_moving_state != c_fish_moving_chasing) && 
			(go.type == GridObject.c_type_cell) && !go.is_removed && (go.cell.m_is_player) ) {
				return false;
			}
			return true;
		}
		
		public override function newPath():void {
			var move_speed:Number = 0;
			var dv:Point = new Point(0, 0);
			switch (m_fish_moving_state) {
				case c_fish_moving_looking:
				default:
					move_speed = Math.random()*(m_move_force_max-m_move_force_min)+m_move_force_min;
					dv.x = Math.random()*10-5;
					dv.y = Math.random()*10-5;
					dv.normalize(move_speed);
					break;
				case c_fish_moving_running:
					dv.x = m_fish_direction.x;
					dv.y = m_fish_direction.y;
					break;
				case c_fish_moving_chasing:
					dv.x = m_fish_direction.x;
					dv.y = m_fish_direction.y;
					break;
			}
			
			myGridObject.move(dv);
			// display the direction we are moving
			rotation = Math.atan2(dv.y, dv.x) * 180/Math.PI + 90;
		}
		
		
		/* Call Back */
		public function observeEnter(go:GridObject):void {
			if ( (go.type == GridObject.c_type_prot) && (!go.is_removed) && 
			(go.prot.m_type == CellProt.c_type_worm) ) {
				m_fish_moving_state = c_fish_moving_chasing;
			}
		}
		
		public function observeUpdate(go:GridObject, overlap:Point):void {
			if ( (go.type == GridObject.c_type_prot) && (!go.is_removed) && 
			(go.prot.m_type == CellProt.c_type_worm) ) {
				
				// go close to the worm!
				m_fish_moving_state = c_fish_moving_chasing;
				
				m_fish_direction.x = overlap.x;
				m_fish_direction.y = overlap.y;
				m_fish_direction.normalize(5);
				m_new_count = 25;
				
			} else if ( (m_fish_moving_state != c_fish_moving_chasing) &&
			(go.type == GridObject.c_type_cell) && (!go.is_removed) && (go.cell.m_is_player) ) {
				
				// RUN!
				m_fish_moving_state = c_fish_moving_running;
				
				m_fish_direction.x = overlap.x;
				m_fish_direction.y = overlap.y;
				m_fish_direction.normalize(-(go.move_max_speed + 5));
				m_new_count = 5;
				
				newPathCallback();
			}
		}
		
		public function observeLeave(go:GridObject):void {
			if ( ((go.type == GridObject.c_type_cell) && (!go.is_removed) && (go.cell.m_is_player)) ||
			((go.type == GridObject.c_type_prot) && (!go.is_removed) && (go.prot.m_type == CellProt.c_type_worm)) ) {
				// Phew...
				m_fish_moving_state = c_fish_moving_looking;
				
				m_new_count = 13;
			}
		}
		
		public override function report(report_type:uint, args:Object):void {
			switch (report_type) {
				case GridObject.c_report_type_enter:
				default:
					observeEnter(args.go);
					break;
				case GridObject.c_report_type_update:
					observeUpdate(args.go, args.overlap);
					break;
				case GridObject.c_report_type_leave:
					observeLeave(args.go);
					break;
			}
		}
		
		
		/* World Map */
		public override function createAreaMapEntry():Object {
			return CellArea_Report.updateMapEntry_New( new Object(), 100.0);
		}
		
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			
			map_entry.fish_level = m_fish_level;
			map_entry.fish_state = m_fish_state;
			map_entry.fish_moving_state = m_fish_moving_state
			
			map_entry.fish_direction = m_fish_direction;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, energy:int, level:int):Object {
			map_entry = CellPrit_Move.updateMapEntry_New(map_entry, energy);
			
			map_entry.energy = 5;
			map_entry.max_energy = 5;
			map_entry.prit_type = c_type_fish;
			
			map_entry.fish_level = level;
			map_entry.fish_state = c_fish_state_enable;
			map_entry.fish_moving_state = c_fish_moving_looking;
			
			map_entry.fish_direction = new Point(0, 0);
			
			map_entry.move_force_max = 6.0;
			map_entry.move_force_min = 4.0;
			map_entry.new_count = 13;
			
			map_entry.mass = 2.0;
			map_entry.radius = 9.0;
			
			map_entry.can_be_attacked = true;
			map_entry.can_be_absorbed = true;
			
			return map_entry;
			
		}
		
	}
}