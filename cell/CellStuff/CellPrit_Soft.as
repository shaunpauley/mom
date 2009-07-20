package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellPrit_Soft extends CellPrit_Hurt{
		
		public function CellPrit_Soft(grid:CellGridDisplay, map_entry:Object) {
			
			super(grid, map_entry);
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Soft();
			prit.gotoAndPlay("normal");
			return prit;
		}
		
		public override function attacked(a:int):void {
			super.attacked(a);
			DebugText.text = "m_energy: " + m_energy + "\nm_state: " + m_state;
		}
		
		/* World Map */
		public static function updateMapEntry_New(map_entry:Object, energy:int):Object {
			map_entry = CellPrit_Hurt.updateMapEntry_New(map_entry, energy);
			
			map_entry.energy = energy;
			map_entry.max_energy = energy;
			map_entry.prit_type = c_type_soft;
			
			map_entry.mass = 0.0;
			map_entry.radius = 9.0;
			
			return map_entry;
		}
		
	}
}