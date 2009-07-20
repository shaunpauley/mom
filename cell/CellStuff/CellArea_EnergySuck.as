package CellStuff {
	
	import flash.events.Event;
	
	import flash.geom.Point;
	
	public class CellArea_EnergySuck extends CellArea {
		
		public var m_suck_increment:int;
		public var m_min_energy_left:int;
		public var m_is_move_suck:Boolean;
		public var m_is_opposite:Boolean;
		public var m_is_force:Boolean;
		
		
		public function CellArea_EnergySuck(grid:CellGridDisplay, map_entry:Object) {
			super(grid, map_entry);
			
			m_suck_increment = map_entry.suck_increment;
			m_min_energy_left = map_entry.min_energy_left;
			m_is_move_suck = map_entry.is_move_suck;
			m_is_opposite = map_entry.is_opposite;
			m_is_force = map_entry.is_force;
			
		}
		
		/* Perform Area Action */
		public override function performAreaAction_Update(go:GridObject, overlap:Point):void {
			if (go.canBeAttacked()) {
				var suck_to_object:GridObject = myGridObject.attach_source;
				if (m_is_opposite) {
					suck_to_object = go;
					go = myGridObject.attach_source;
				}
				
				var can_suck:Boolean = (suck_to_object.getEnergy() < suck_to_object.getMaxEnergy()) && (go.getEnergy() >= m_min_energy_left);
				
				if (m_is_force) {
					if (m_is_opposite) {
						suck_to_object.increaseEnergy(m_suck_increment);
					} else {
						go.decreaseEnergy(m_suck_increment);
					}
				} else if (can_suck) {
					suck_to_object.increaseEnergy( go.decreaseEnergy(m_suck_increment) );
				}
				
				if (m_is_move_suck && (can_suck || m_is_force) ) {
					var dv:Point = overlap.clone();
					dv.normalize(-1);
					go.moveAdd(dv);
				}
			}
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			
			map_entry.suck_increment = m_suck_increment;
			map_entry.min_energy_left = m_min_energy_left;
			map_entry.is_move_suck = m_is_move_suck;
			map_entry.is_opposite = m_is_opposite;
			map_entry.is_force = m_is_force;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, 
		radius:Number, 
		suck_increment:int = 1,
		min_energy_left:int = 2,
		is_opposite:Boolean = false,
		is_force:Boolean = false,
		is_move_suck:Boolean = false):Object {
			map_entry = CellArea.updateMapEntry_New(map_entry);
			
			map_entry.area_type = c_type_energysuck;
			map_entry.radius = radius;
			
			map_entry.suck_increment = suck_increment;
			map_entry.min_energy_left = min_energy_left;
			map_entry.is_move_suck = is_move_suck;
			map_entry.is_force = is_force;
			map_entry.is_opposite = is_opposite;
			
			return map_entry;
		}
		
	}
}