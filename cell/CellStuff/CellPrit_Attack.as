package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellPrit_Attack extends CellPrit_Move{
		
		public function CellPrit_Attack(grid:CellGridDisplay, map_entry:Object) {
			super(grid, map_entry);
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Attack();
			prit.gotoAndPlay("enable");
			return prit;
		}
		
		/* World Map */
		public override function createAreaMapEntry():Object {
			return CellArea_Attack.updateMapEntry_New( new Object(), 9.0, 10.0, 2);
		}
		
		public static function updateMapEntry_New(map_entry:Object):Object {
			map_entry = CellPrit_Move.updateMapEntry_New(map_entry, 2);
			
			map_entry.move_force_max = 6.0;
			map_entry.move_force_min = 4.0;
			map_entry.new_count = 13;
			
			map_entry.prit_type = c_type_attack;
			
			map_entry.mass = 0.5;
			map_entry.radius = 6.5;
			
			map_entry.can_be_absorbed = false;
			map_entry.can_be_attacked = false;
			
			return map_entry;
		}
		
	}
}