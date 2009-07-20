package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellPrit_Worm extends CellPrit_Move{
		
		public var m_worm_state:uint;
		
		public static const c_worm_state_disable:uint 	= 0x000000;
		public static const c_worm_state_enable:uint 	= 0x000001;
		
		public function CellPrit_Worm(grid:CellGridDisplay, map_entry:Object) {
			
			super(grid, map_entry);
			
			m_worm_state = map_entry.worm_state;
			updateWorm();
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Worm();
			prit.rotation = -90;
			if (m_worm_state == c_worm_state_enable) {
				prit.gotoAndPlay("enable");
			} else {
				prit.gotoAndStop("disable");
			}
			return prit;
		}
		
		public override function absorbed(go:GridObject):void {
			m_radius = 7;
			super.absorbed(go);
			m_worm_state = c_worm_state_disable;
			updateWorm();
		}
		
		public override function reset():void {
			m_radius = 3;
			super.reset();
			m_worm_state = c_worm_state_enable;
			updateWorm();
		}
		
		public function updateWorm():void {
			if (m_worm_state == c_worm_state_enable) {
				pritsGotoAndPlay("enable");
			} else {
				pritsGotoAndStop("disable");
			}
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			
			map_entry.worm_state = m_worm_state;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object):Object {
			map_entry = CellPrit_Move.updateMapEntry_New(map_entry, 3);
			
			map_entry.move_force_max = 10.0;
			map_entry.move_force_min = 8.0;
			map_entry.new_count = 13;
			
			map_entry.worm_state = c_worm_state_enable;
			
			map_entry.prit_type = c_type_worm;
			
			map_entry.mass = 0;
			map_entry.radius = 3;
			
			map_entry.can_be_absorbed = true;
			map_entry.can_be_attacked = true;
			
			return map_entry;
		}
		
	}
}