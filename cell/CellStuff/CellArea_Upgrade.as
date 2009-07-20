package CellStuff {
	import flash.events.Event;
	
	public class CellArea_Upgrade extends CellArea {
		public var m_upgrade_level:int;
		
		public function CellArea_Upgrade(grid:CellGridDisplay, map_entry:Object) {
			super(grid, map_entry);
			
			m_upgrade_level = map_entry.upgrade_level;
		}
		
		/* Perform Area Action */
		public override function performAreaAction_Enter(go:GridObject):void {
			go.upgraded(m_upgrade_level);
		}
		
		public override function performAreaAction_Leave(go:GridObject):void {
			go.upgraded(0);
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			
			map_entry.upgrade_level = m_upgrade_level;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, upgrade_level:int):Object {
			map_entry = CellArea.updateMapEntry_New(map_entry);
			
			map_entry.area_type = c_type_upgrade;
			
			map_entry.upgrade_level = upgrade_level;
			
			return map_entry;
		}
		
	}
}