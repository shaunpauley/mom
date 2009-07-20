package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellPrit_Butterfly extends CellPrit_Move{
		
		public var m_butterfly_level:int;
		public var m_butterfly_state:uint;
		
		public static const c_butterfly_state_disable:uint 	= 0x000000;
		public static const c_butterfly_state_enable:uint 	= 0x000001;
		
		public function CellPrit_Butterfly(grid:CellGridDisplay, map_entry:Object) {
			
			super(grid, map_entry);
			
			m_butterfly_level = map_entry.butterfly_level;
			m_butterfly_state = map_entry.butterfly_state;
			
			updateButterfly();
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Butterfly();
			if (m_butterfly_state == c_butterfly_state_enable) {
				prit.gotoAndPlay("enabled_level" + m_butterfly_level);
			} else {
				prit.gotoAndStop("disabled");
			}
			return prit;
		}
		
		public override function decreaseEnergy(energy:int):int {
			var de:int = 0;
			if (m_butterfly_level < 2) {
				de = super.decreaseEnergy(energy);
			}
			return de;
		}
		
		public function updateButterfly():void {
			if (m_butterfly_state == c_butterfly_state_enable) {
				pritsGotoAndPlay("enabled_level" + m_butterfly_level);
			} else {
				pritsGotoAndStop("disabled");
			}
		}
		
		public override function absorbed(go:GridObject):void {
			super.absorbed(go);
			m_butterfly_state = c_butterfly_state_disable;
			updateButterfly();
		}
		
		public override function reset():void {
			super.reset();
			m_butterfly_state = c_butterfly_state_enable;
			updateButterfly();
		}
		
		/* World Map */
		public override function createAreaMapEntry():Object {
			var area_entry:Object = new Object();
			switch (m_butterfly_level) {
				case 0:
				default:
					area_entry = CellArea_EnergySuck.updateMapEntry_New( new Object(), 9.0, 1, -1, false, true );
					break;
				case 1:
					area_entry = null;
					break;
				case 2:
					area_entry = CellArea_EnergySuck.updateMapEntry_New( new Object(), 9.0, 1, -1, true, true );
					break;
			}
			
			return area_entry;
		}
		
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			
			map_entry.butterfly_level = m_butterfly_level;
			map_entry.butterfly_state = m_butterfly_state;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, energy:int, butterfly_level:int):Object {
			map_entry = CellPrit_Move.updateMapEntry_New(map_entry, energy);
			
			map_entry.energy = energy;
			map_entry.max_energy = 5;
			map_entry.prit_type = c_type_butterfly;
			
			map_entry.butterfly_level = butterfly_level;
			map_entry.butterfly_state = c_butterfly_state_enable;
			
			map_entry.move_force_max = 6.0;
			map_entry.move_force_min = 4.0;
			map_entry.new_count = 13;
			
			map_entry.mass = 0.0;
			map_entry.radius = 4.0;
			
			map_entry.can_be_attacked = true;
			map_entry.can_be_absorbed = true;
			
			return map_entry;
			
		}
		
	}
}