package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellPrit_Heart extends CellPrit{
		
		public function CellPrit_Heart(grid:CellGridDisplay, map_entry:Object) {
			
			super(grid, map_entry);
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Heart();
			prit.gotoAndPlay(1);
			return prit;
		}
		
		/* World Map */
		public static function updateMapEntry_New(map_entry:Object):Object {
			map_entry = CellPrit.updateMapEntry_New(map_entry);
			
			map_entry.energy = 10;
			map_entry.max_energy = 10;
			map_entry.prit_type = c_type_heart;
			
			map_entry.mass = 0.0;
			map_entry.radius = 6.0;
			
			map_entry.can_be_attacked = false;
			
			return map_entry;
		}
		
	}
}