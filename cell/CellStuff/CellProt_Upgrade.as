package CellStuff {
	import flash.display.MovieClip;
	
	public class CellProt_Upgrade extends CellProt{
		
		public function CellProt_Upgrade(grid:CellGridDisplay, map_entry:Object) {
			if (!myProt) {
				myProt = new PhysProt_Upgrade();
				myProt.play();
				addChild(myProt);
			}
			
			super(grid, map_entry);
		}
		
		public override function enable():void {
			super.enable();
			myProt.gotoAndPlay("enabled_level" + m_level);
		}
		
		public override function disable():void {
			super.disable();
			myProt.gotoAndPlay("disabled_level" + m_level);
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, constructed_prits:Array, prits_held:Array):Object {
			map_entry = CellProt.updateMapEntry_New(map_entry, constructed_prits, prits_held);
			
			map_entry.prot_type = c_type_upgrade;
			
			map_entry.state = c_state_enable;
			
			map_entry.radius = c_radius_default;
			map_entry.max_prits_held = 0;
			
			return map_entry;
		}
		
	}
}