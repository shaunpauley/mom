package CellStuff {
	import flash.display.MovieClip;
	
	public class CellProt_Pearl extends CellProt{
		
		public function CellProt_Pearl(grid:CellGridDisplay, map_entry:Object) {
			if (!myProt) {
				myProt = new PhysProt_Pearl();
				myProt.gotoAndPlay("enable");
				addChild(myProt);
			}
			
			super(grid, map_entry);
		}
		
		public override function enable():void {
			super.enable();
			myProt.gotoAndPlay("enable");
		}
		
		public override function disable():void {
			super.enable();
		}
		
		/* Prot Creator */
		public static function getPritCriteria(prit_lookup:Array):Object {
			return {type:c_type_pearl, is_complete:false, num_complete:0};
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, constructed_prits:Array, prits_held:Array):Object {
			map_entry = CellProt.updateMapEntry_New(map_entry, constructed_prits, prits_held);
			
			map_entry.prot_type = c_type_pearl;
			
			map_entry.state = c_state_enable;
			
			map_entry.radius = 9.0;
			map_entry.max_prits_held = 0;
			
			return map_entry;
		}
		
	}
}