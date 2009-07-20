package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellPrit_Boss extends CellPrit{
		
		public var m_area_texts:Array;
		public var m_area_text_type:uint;
		public var m_area_text_repeat:Boolean;
		
		public var m_absorb_texts:Array;
		public var m_absorb_text_type:uint;
		public var m_absorb_text_repeat:Boolean;
		
		public static const c_radius_area_text:Number = 100.0;
		
		public function CellPrit_Boss(grid:CellGridDisplay, map_entry:Object) {
			super(grid, map_entry);
			
			m_area_texts = map_entry.area_texts;
			m_area_text_type = map_entry.area_text_type;
			m_area_text_repeat = map_entry.area_text_repeat;
			
			m_absorb_texts = map_entry.absorb_texts;
			m_absorb_text_type = map_entry.absorb_text_type;
			m_absorb_text_repeat = map_entry.absorb_text_repeat;
			
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Boss();
			prit.gotoAndPlay(1);
			return prit;
		}
		
		public override function absorbed(go:GridObject):void {
			super.absorbed(go);
			if (m_absorb_texts) {
				CellWorld.addNewText_Player(m_absorb_texts, m_absorb_text_type, m_absorb_text_repeat);
			}
			
			if (go.type == GridObject.c_type_cell) {
				go.cell.levelUp();
			}
			
			CellWorld.isNextWorldLevel = true;
		}
		
		/* World Map */
		public override function createAreaMapEntry():Object {
			if (m_area_texts) {
				return CellArea_TextDisplay.updateMapEntry_New( new Object(), c_radius_area_text, m_area_texts, m_area_text_type, m_area_text_repeat);
			}
			return null;
		}
		
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			
			map_entry.area_texts = m_area_texts;
			map_entry.area_text_type = m_area_text_type;
			map_entry.area_text_repeat = m_area_text_repeat;
			
			map_entry.absorb_texts = m_absorb_texts;
			map_entry.absorb_text_type = m_absorb_text_type;
			map_entry.area_text_repeat = m_area_text_repeat;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, 
		area_text_type:uint, 
		area_texts:Array, 
		area_text_repeat:Boolean,
		absorb_text_type:uint, 
		absorb_texts:Array,
		absorb_text_repeat:Boolean):Object {
			map_entry = CellPrit.updateMapEntry_New(map_entry);
			
			map_entry.prit_type = c_type_boss;
			
			map_entry.mass = 1.1;
			map_entry.radius = 9.0;
			
			map_entry.can_be_attacked = false;
			map_entry.can_be_consumed = false;
			
			map_entry.area_text_type = area_text_type;
			map_entry.area_texts = area_texts;
			map_entry.area_text_repeat = area_text_repeat;
			
			map_entry.absorb_text_type = absorb_text_type;
			map_entry.absorb_texts = absorb_texts;
			map_entry.absorb_text_repeat = absorb_text_repeat;
			
			return map_entry;
		}
		
	}
}