package CellStuff {
	
	import flash.geom.Point;
	
	public class CellArea {
		
		protected var myGrid:CellGridDisplay;
		
		public var myGridObject:GridObject;
		
		public var m_type:uint;
		public var m_radius:Number;
		public var m_filter:uint;
		public var m_is_enabled:Boolean;
		
		public var m_action_is_entry:Boolean;
		
		public var m_contains_enter:Array;
		public var m_contains_update:Array;
		public var m_contains_leave:Array;
		
		public static const c_type_none:uint 			= 0x000000;
		public static const c_type_textdisplay:uint 	= 0x000001;
		public static const c_type_attack:uint 			= 0x000002;
		public static const c_type_energysuck:uint 		= 0x000003;
		public static const c_type_report:uint 			= 0x000004;
		
		
		public static const c_type_upgrade:uint 		= 0x000004;
		
		public static const c_radius_default:Number		= 10.0;
		
		public static const c_filter_none:uint			= 0x000000;
		
		public function CellArea(grid:CellGridDisplay, map_entry:Object) {
			
			myGrid = grid;
			
			// map entries
			m_type = map_entry.area_type;
			m_radius = map_entry.radius;
			m_filter = map_entry.filter;
			m_is_enabled = map_entry.is_enabled;
			
			m_action_is_entry = false;
			
			// containers
			m_contains_enter = new Array();
			m_contains_update = new Array();
			m_contains_leave = new Array();
		}
		
		/* Removed */
		public function removed():void {
			m_is_enabled = false;
			
			while (m_contains_enter.length > 0) {
				var go:GridObject = m_contains_enter.pop();
				if (!go.is_removed) {
					go.removeArea(this);
				}
			}
			
			// move all update into leave
			while (m_contains_update.length > 0) {
				m_contains_leave.push( m_contains_update.pop() );
			}
			
			// handle leaves
			while (m_contains_leave.length > 0) {
				go = m_contains_leave.pop();
				if (!go.is_removed) {
					performAreaAction_Leave(go);
					go.removeArea(this);
				}
			}
			
		}
		
		public function addGridObjectEnter(go:GridObject):void {
			if (!go.isAlreadyInArea(this)) {
				m_contains_enter.push(go);
				go.addArea(this);
				checkActionEntry();
			}
		}
		
		
		/* Perform Area Action */
		public virtual function performAreaAction_Enter(go:GridObject):void {};
		
		public virtual function performAreaAction_Update(go:GridObject, overlap:Point):void {};
		
		public virtual function performAreaAction_Leave(go:GridObject):void {};
		
		public function checkActionEntry():void {
			if (!m_action_is_entry) {
				CellWorld.addAreaActions(this);
				m_action_is_entry = true;
			}
		}
		
		public function enable():void {
			m_is_enabled = true;
		}
		
		public function disable():void {
			m_is_enabled = false;
		}
		
		/* WorldMap */
		public virtual function updateMapEntry(map_entry:Object):Object {
			map_entry.area_type = m_type;
			map_entry.radius = m_radius;
			map_entry.filter = m_filter;
			map_entry.is_enabled = m_is_enabled;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object):Object {
			map_entry.area_type = c_type_none;
			map_entry.radius = c_radius_default;
			map_entry.filter = c_filter_none;
			map_entry.is_enabled = true;
			
			return map_entry;
		}
	}
}