package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellPrit_Heavy extends CellPrit{
		
		public function CellPrit_Heavy(grid:CellGridDisplay, map_entry:Object) {
			
			super(grid, map_entry);
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Heavy();
			prit.gotoAndPlay(1);
			return prit;
		}
		
		/* World Map */
		public static function updateMapEntry_New(map_entry:Object):Object {
			map_entry = CellPrit.updateMapEntry_New(map_entry);
			
			map_entry.prit_type = c_type_heavy;
			
			map_entry.mass = GridObject.c_max_mass;
			map_entry.radius = 9.0;
			
			map_entry.can_be_attacked = false;
			
			return map_entry;
		}
		
	}
}