package CellStuff {
	import flash.display.MovieClip;
	
	public class CellProt_Boss extends CellProt{
		
		public function CellProt_Boss(grid:CellGridDisplay, map_entry:Object) {
			if (!myProt) {
				myProt = new PhysProt_Boss();
				myProt.gotoAndStop("disable");
				myProt.rotation = 90;
				addChild(myProt);
			}
			
			super(grid, map_entry);
			
		}
		
		public override function enable():void {
			super.enable();
			myProt.gotoAndPlay("enable");
		}
		
		public override function disable():void {
			super.disable();
			myProt.gotoAndStop("disable");
		}
		
		/* Prot Creator */
		public static function getPritCriteria(prit_lookup:Array):Object {
			if (prit_lookup[CellPrit.c_type_boss].length > 0) {
				var prit_index:Array = new Array();
				var num_boss_prits:int = prit_lookup[CellPrit.c_type_boss].length;
				for (var i:int = 0; (i < 3) && (i < num_boss_prits); ++i) {
					prit_index.push(prit_lookup[CellPrit.c_type_boss][i]);
				}
				return {type:c_type_boss, prits:prit_index, is_complete:(prit_index.length == 3), num_complete:prit_index.length};
			}
			return {type:c_type_boss, is_complete:false, num_complete:0};
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, constructed_prits:Array, prits_held:Array):Object {
			map_entry = CellProt.updateMapEntry_New(map_entry, constructed_prits, prits_held);
			
			map_entry.prot_type = c_type_boss;
			
			map_entry.state = c_state_enable;
			
			map_entry.radius = 17.0;
			map_entry.max_prits_held = 0;
			
			return map_entry;
		}
		
	}
}