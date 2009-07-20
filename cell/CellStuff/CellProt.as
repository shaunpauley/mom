package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;

	public class CellProt extends MovieClip{
		
		public var myProt:MovieClip;
		
		protected var myGrid:CellGridDisplay;
		
		public var myGridObject:GridObject;
		public var myCell:CellSingle;
		
		public var myConstructedPrits:Array;
		public var myPritsHeld:Array;
		
		public var pos:int;
		public var m_ring:int;
		
		public var m_state:uint;
		
		public var m_type:uint;
		public var m_radius:Number;
		
		public var m_max_prits_held:int;
		
		public var m_level:int;
		public var m_upgrade_level:int;
		
		public var m_is_dragging:Boolean;
		
		public static const c_state_disable:uint	= 0x000000;
		public static const c_state_enable:uint 	= 0x000001;
		
		public static const c_repel:uint = 0x000000;
		public static const c_absorb:uint = 0x000001;
		
		public static const c_type_default:uint 	= 0x000000;
		public static const c_type_heartclick:uint 	= 0x000001;
		public static const c_type_worm:uint 		= 0x000002;
		public static const c_type_pearl:uint 		= 0x000003;
		public static const c_type_fish:uint 		= 0x000004;
		public static const c_type_boss:uint 		= 0x000005;
		public static const c_type_cat:uint 		= 0x000006;
		
		public static const c_type_upgrade:uint 		= 0x000007;
		public static const c_type_upgrade_area:uint 	= 0x000008;
		public static const c_type_attack:uint 			= 0x000009;
		public static const c_type_rotate:uint 			= 0x000010;
		
		public static const c_radius_default:Number = 18.0;
		
		public function CellProt(grid:CellGridDisplay, map_entry:Object):void {
			
			myGrid = grid;
			
			// prot sprite
			if (!myProt) {
				myProt = new PhysProt();
				addChild(myProt);
				myProt.gotoAndPlay("disable_level0");
			}
			
			// map entries
			m_type = map_entry.prot_type;
			
			myConstructedPrits = map_entry.constructed_prits;
			myPritsHeld = map_entry.prits_held;
			
			m_state = map_entry.state;
			
			m_radius = map_entry.radius;
			m_max_prits_held = map_entry.max_prits_held;
			
			m_level = map_entry.level;
			m_upgrade_level = map_entry.upgrade_level;
			
			m_is_dragging = map_entry.is_dragging;
			
			pos = map_entry.pos;
			m_ring = map_entry.ring;
		}
		
		public function enable():void {
			m_state = c_state_enable;
			myProt.gotoAndStop("enable_level" + m_level);
		}
		
		public function disable():void {
			m_state = c_state_disable;
			myProt.gotoAndStop("disable_level" + m_level);
		}
		
		public function switchAble():void {
			if (m_state == c_state_disable) {
				enable();
			} else if (m_state == c_state_enable) {
				disable();
			}
		}
		
		public function holdPrit(prit:CellPrit):void {
			myPritsHeld.push(prit);
			addChild(prit);
		}
		
		public function releasePrits():Array {
			var prits:Array = new Array();
			while(myPritsHeld.length > 0) {
				var prit:CellPrit = myPritsHeld.pop();
				removeChild(prit);
				prits.push(prit);
			}
			
			return prits;
		}
		
		public function canBeAttacked():Boolean {
			return true;
		}
		
		public function isEnabled():Boolean {
			return m_state == c_state_enable;
		}
		
		public function canHoldPrit(how_many:int = 1):Boolean {
			return isEnabled() && (myPritsHeld.length + how_many <= m_max_prits_held);
		}
		
		public function upgraded(a:int):void {
			m_upgrade_level = a;
		}
		
		public function moveToRing(new_ring:int):void {
		}
		
		public virtual function removed():void {
		}
		
		public function report(report_type:uint, args:Object):void {};
		
		/* Prot Creator */
		public static function getPritCriteria():Object {
			return {type:c_type_default, is_complete:false, num_complete:0};
		}
		
		/* World Map */
		public function createAreaMapEntry():Object {
			return null;
		}
		
		public virtual function updateMapEntry(map_entry:Object):Object {
			map_entry.prot_type = m_type ;
			
			map_entry.constructed_prits = myConstructedPrits;
			map_entry.prits_held = myPritsHeld;
			
			map_entry.state = m_state;
			
			map_entry.radius = m_radius;
			map_entry.max_prits_held = m_max_prits_held;
			
			map_entry.level = m_level;
			map_entry.upgrade_level = m_upgrade_level;
			
			map_entry.is_dragging = m_is_dragging;
			
			map_entry.pos = pos;
			map_entry.ring = m_ring;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, constructed_prits:Array, prits_held:Array):Object {
			map_entry.prot_type = c_type_default;
			
			map_entry.constructed_prits = constructed_prits;
			map_entry.prits_held = prits_held;
			
			map_entry.state = c_state_disable;
			
			map_entry.radius = c_radius_default;
			map_entry.max_prits_held = 0;
			
			map_entry.level = 0;
			map_entry.upgrade_level = 0;
			
			map_entry.is_dragging = false;
			
			map_entry.ring = -1;
			map_entry.pos = -1;
			
			return map_entry;
		}
	}
}