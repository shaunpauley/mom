package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellPrit_Letter extends CellPrit{
		
		public var m_letter:int;
		
		public static const c_letter_a:int	= 1;
		public static const c_letter_c:int	= 3;
		public static const c_letter_t:int	= 20;
		
		public function CellPrit_Letter(grid:CellGridDisplay, map_entry:Object) {
			m_letter = map_entry.letter;
			
			super(grid, map_entry);
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Letter();
			prit.gotoAndPlay(m_letter);
			return prit;
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			map_entry.letter = m_letter;
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, energy:int, letter:int):Object {
			map_entry = CellPrit.updateMapEntry_New(map_entry);
			
			map_entry.letter = letter;
			switch(letter) {
				case c_letter_a:
					map_entry.sound_absorb = CellWorld.c_sound_letter_a;
					break;
				case c_letter_c:
					map_entry.sound_absorb = CellWorld.c_sound_letter_c;
					break;
				case c_letter_t:
					map_entry.sound_absorb = CellWorld.c_sound_letter_t;
					break;
				default:
					break;
			}
			
			map_entry.energy = energy;
			map_entry.max_energy = energy;
			map_entry.exp = 0;
			map_entry.prit_type = c_type_letter;
			
			map_entry.mass = 2.0;
			map_entry.radius = 14.0;
			
			return map_entry;
		}
		
	}
}