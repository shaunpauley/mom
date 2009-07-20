package CellStuff {
	import flash.display.MovieClip;
	
	public class CellProt_Cat extends CellProt{
		
		public function CellProt_Cat(grid:CellGridDisplay, map_entry:Object) {
			if (!myProt) {
				myProt = new PhysProt_Cat();
				myProt.gotoAndStop(1);
				myProt.rotation = 90;
				addChild(myProt);
			}
			
			super(grid, map_entry);
		}
		
		/* Prot Creator */
		public static function getPritCriteria(prit_lookup:Array, prits:Array):Object {
			if (prit_lookup[CellPrit.c_type_letter].length > 0) {
				var letter_lookup:Array = new Array();
				for (var i:int = 0; i < 26; ++i) {
					letter_lookup.push( new Array() );
				}
				for (i = 0; i < prits.length; ++i) {
					if (prits[i].m_type == CellPrit.c_type_letter) {
						letter_lookup[prits[i].m_letter].push(i);
					}
				}
				
				var prit_index:Array = new Array();
				if (letter_lookup[CellPrit_Letter.c_letter_c].length > 0) {
					prit_index.push(letter_lookup[CellPrit_Letter.c_letter_c][0]);
				}
				if (letter_lookup[CellPrit_Letter.c_letter_a].length > 0) {
					prit_index.push(letter_lookup[CellPrit_Letter.c_letter_a][0]);
				}
				if (letter_lookup[CellPrit_Letter.c_letter_t].length > 0) {
					prit_index.push(letter_lookup[CellPrit_Letter.c_letter_t][0]);
				}
				
				return {type:c_type_cat, prits:prit_index, is_complete:(prit_index.length == 3), num_complete:prit_index.length};
			}
			
			return {type:c_type_cat, is_complete:false, num_complete:0};
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, constructed_prits:Array, prits_held:Array):Object {
			map_entry = CellProt.updateMapEntry_New(map_entry, constructed_prits, prits_held);
			
			map_entry.prot_type = c_type_cat;
			
			map_entry.state = c_state_enable;
			
			map_entry.radius = c_radius_default;
			map_entry.max_prits_held = 0;
			
			return map_entry;
		}
		
	}
}