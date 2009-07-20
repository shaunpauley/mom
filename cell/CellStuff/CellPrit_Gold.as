package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellPrit_Gold extends CellPrit{
		
		public function CellPrit_Gold(grid:CellGridDisplay, map_entry:Object) {
			
			super(grid, map_entry);
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Gold();
			prit.gotoAndPlay(1);
			return prit;
		}
		
		public override function absorbed(go:GridObject):void {
			super.absorbed(go);
			CellWorld.isNextWorldLevel = true;
		}
		
		/* World Map */
		public static function updateMapEntry_New(map_entry:Object):Object {
			map_entry = CellPrit.updateMapEntry_New(map_entry);
			
			map_entry.sound_absorb = CellWorld.c_sound_gold;
			map_entry.prit_type = c_type_gold;
			
			map_entry.mass = 1.1;
			map_entry.can_be_attacked = false;
			
			return map_entry;
		}
		
	}
}