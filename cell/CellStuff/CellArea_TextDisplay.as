package CellStuff {
	import flash.events.Event;
	
	public class CellArea_TextDisplay extends CellArea {
		public var m_texts:Array;
		public var m_text_type:uint;
		public var m_text_repeat:Boolean
		
		public function CellArea_TextDisplay(grid:CellGridDisplay, map_entry:Object) {
			super(grid, map_entry);
			
			m_texts = map_entry.texts;
			m_text_type = map_entry.text_type;
			m_text_repeat = map_entry.text_repeat;
		}
		
		/* Perform Area Action */
		public override function performAreaAction_Enter(go:GridObject):void {
			if ( (go.type == GridObject.c_type_cell) && (go.cell.m_is_player) ) {
				CellWorld.addNewText_GridObject(myGridObject.attach_source, m_texts, m_text_type, m_text_repeat);
			}
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			
			map_entry.texts = m_texts;
			map_entry.text_type = m_text_type;
			map_entry.text_repeat = m_text_repeat;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, radius:Number, texts:Array, text_type:uint, text_repeat:Boolean):Object {
			map_entry = CellArea.updateMapEntry_New(map_entry);
			
			map_entry.area_type = c_type_textdisplay;
			map_entry.radius = radius;
			
			map_entry.text_type = text_type;
			map_entry.texts = texts;
			map_entry.text_repeat = text_repeat;
			
			return map_entry;
		}
		
	}
}