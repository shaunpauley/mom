package CellStuff {
	import flash.events.Event;
	
	import flash.geom.Point;
	
	public class CellArea_Attack extends CellArea {
		public var m_force_added:Number;
		public var m_attack:Number;
		
		public function CellArea_Attack(grid:CellGridDisplay, map_entry:Object) {
			super(grid, map_entry);
			
			m_force_added = map_entry.force_added;
			m_attack = map_entry.attack;
		}
		
		/* Perform Area Action */
		public override function performAreaAction_Update(go:GridObject, overlap:Point):void {
			if (go.canBeAttacked()) {
				var dv:Point = overlap.clone();
				dv.normalize(m_force_added);
				
				// move or "punch" the object
				go.move(dv);
				
				// forward attack
				go.attacked(m_attack);
			}
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			
			map_entry.force_added = m_force_added;
			map_entry.attack = m_attack;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, radius:Number, force_added:Number, attack:int):Object {
			map_entry = CellArea.updateMapEntry_New(map_entry);
			
			map_entry.area_type = c_type_attack;
			map_entry.radius = radius;
			
			map_entry.force_added = force_added;
			map_entry.attack = attack;
			
			return map_entry;
		}
		
	}
}