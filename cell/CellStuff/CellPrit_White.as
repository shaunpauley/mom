package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellPrit_White extends CellPrit{
		
		public function CellPrit_White(grid:CellGridDisplay, map_entry:Object) {
			
			super(grid, map_entry);
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_White();
			prit.gotoAndPlay(1);
			return prit;
		}
		
		/* World Map */
		public static function updateMapEntry_New(map_entry:Object):Object {
			map_entry = CellPrit.updateMapEntry_New(map_entry);
			
			map_entry.prit_type = c_type_white;
			
			map_entry.mass = 0.0;
			map_entry.radius = 9.0;
			
			map_entry.energy = 1;
			map_entry.max_energy = 1;
			
			map_entry.can_be_attacked = false;
			
			return map_entry;
		}
		
	}
}