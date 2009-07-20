package CellStuff {
	import flash.display.MovieClip;
	
	import flash.geom.Point;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;	
	
	public class CellPrit extends MovieClip{
		
		public var myPrit:MovieClip;
		public var myPrits:Array;
		
		public var myGrid:CellGridDisplay;
		
		public var myGridObject:GridObject;
		
		public var m_energy:int;
		public var m_max_energy:int;
		public var m_type:uint;
		public var m_sound_absorb:int;
		public var pos:int;
		
		public var m_mass:Number;
		public var m_radius:Number;
		public var m_max_speed:Number;
		
		public var can_be_absorbed:Boolean;
		public var can_be_attacked:Boolean;
		public var can_be_consumed:Boolean;
		
		public var m_is_special:Boolean;
		public var m_special_object:Object;
		
		
		public var DebugText:TextField;
		
		public static const c_type_default:uint 	= 0x000000;
		public static const c_type_heavy:uint 		= 0x000001;
		public static const c_type_boss:uint 		= 0x000002;
		public static const c_type_white:uint		= 0x000003;
		public static const c_type_energyball:uint	= 0x000004;
		public static const c_type_butterfly:uint	= 0x000005;
		public static const c_type_heart:uint 		= 0x000006;
		public static const c_type_attack:uint		= 0x000007;
		public static const c_type_fish:uint		= 0x000008;
		public static const c_type_worm:uint		= 0x000009;
		
		
		public static const c_type_letter:uint 		= 0x000010;
		
		public static const c_type_question:uint 	= 0x000011;
		public static const c_type_gold:uint 		= 0x000012;
		
		public static const c_type_hurt:uint 		= 0x000013;
		public static const c_type_move:uint 		= 0x000014;
		
		public static const c_type_type1:uint 		= 0x000015;
		public static const c_type_soft:uint 		= 0x000016;
		
		
		public static const c_default_radius:Number = 9;
		
		public function CellPrit(grid:CellGridDisplay, map_entry:Object):void {
			
			myGrid = grid;
			
			// debug text
			DebugText = new TextField();
			DebugText.x = 0;
			DebugText.y = 0;
			DebugText.autoSize = TextFieldAutoSize.LEFT;
			
			var Format:TextFormat = new TextFormat();
			Format.font = "Courier New";
			Format.color = 0x441111;
			Format.size = 10;
			
			DebugText.defaultTextFormat = Format;
			DebugText.selectable = false;
			DebugText.text = "";
			if (CellWorld.c_debug) {
				addChild(DebugText);
			}
			
			// map entries
			m_type = map_entry.prit_type;
			m_sound_absorb = map_entry.sound_absorb;
			
			m_max_energy= map_entry.max_energy;
			m_energy = map_entry.energy;
			
			m_mass = map_entry.mass;
			
			m_radius = map_entry.radius;
			m_max_speed = map_entry.max_speed;
			
			can_be_absorbed = map_entry.can_be_absorbed;
			can_be_attacked = map_entry.can_be_attacked;
			can_be_consumed = map_entry.can_be_consumed;
			
			m_is_special = map_entry.is_special;
			m_special_object = map_entry.special_object;
			
			pos = map_entry.pos;
			
			// phys prit
			myPrits = new Array();
			myPrit = addNewPhysicalPrit();
			addChild(myPrit);
			
			// mouse
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		public function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit();
			prit.gotoAndStop(1);
			return prit;
		}
		
		public function addNewPhysicalPrit():MovieClip {
			var prit:MovieClip = physPrit();
			myPrits.push(prit);
			return prit;
		}
		
		public function pritsGotoAndPlay(frame:Object):void {
			for each (var prit:MovieClip in myPrits) {
				prit.gotoAndPlay(frame);
			}
		}
		
		public function pritsGotoAndStop(frame:Object):void {
			for each (var prit:MovieClip in myPrits) {
				prit.gotoAndStop(frame);
			}
		}
		
		public function makeGridObject(grid_handler:Object, local_point:Point):GridObject {
			if (myGridObject && !myGridObject.is_removed) {
				myGrid.removeFromGrid(myGridObject);
			} else {
				myGridObject = myGrid.makeGridObjectLocal(local_point.x, local_point.y,
				GridObject.c_type_prit, 
				m_radius, 
				m_mass, 
				m_max_speed,
				myGrid.myWorldMap.level);
			}
			
			myGridObject.prit = this;
			myGridObject.setLocalPoint(local_point);
			myGridObject.sprite.addChild(this);
			
			reset();
			
			myGrid.addToGridLocal(myGridObject, grid_handler, local_point);
			
			return myGridObject;
		}
		
		public function createAreaMapEntry():Object {
			return null;
		}
		
		public function attacked(a:int):void {
			myGridObject.decreaseEnergy(a);
		}
		
		public function canBeAbsorbed():Boolean {
			return can_be_absorbed;
		}
		
		public function canBeAbsorbedBy(go:GridObject):Boolean {
			return true;
		}
		
		public function canBeAttacked():Boolean {
			return can_be_attacked;
		}
		
		public function canBeConsumed():Boolean {
			return can_be_consumed;
		}
		
		public function increaseEnergy(energy:int):int {
			var energy_before:int = m_energy;
			m_energy += energy;
			if (m_energy > m_max_energy) {
				m_energy = m_max_energy;
			}
			return int(m_energy - energy_before);
		}
		
		public function decreaseEnergy(energy:int):int {
			var energy_before:int = m_energy;
			m_energy -= energy;
			if (m_energy < -1) {
				m_energy = -1;
				
				// destroy
				myGrid.addExplosion( myGridObject.getGridCol(), myGridObject.getGridRow(), myGridObject.getLocalPoint(), m_radius );
				myGrid.destroyGridObject(myGridObject);
			}
			return int(energy_before - m_energy);
		}
		
		public virtual function absorbed(go:GridObject):void {
			if (m_is_special) {
				CellWorld.unregisterSpecial(m_special_object);
			}
		}
		
		public virtual function removed():void {};
		
		public virtual function reset():void {};
		
		public virtual function report(report_type:uint, args:Object):void {};
		
		/* World Map */
		public virtual function updateMapEntry(map_entry:Object):Object {
			map_entry.prit_type = m_type;
			map_entry.sound_absorb = m_sound_absorb;
			
			map_entry.max_energy = m_max_energy;
			map_entry.energy = m_energy;
			
			map_entry.mass = m_mass;
			
			map_entry.radius = m_radius;
			map_entry.max_speed = m_max_speed;
			
			map_entry.can_be_absorbed = can_be_absorbed;
			map_entry.can_be_attacked = can_be_attacked;
			map_entry.can_be_consumed = can_be_consumed;
			
			map_entry.is_special = m_is_special;
			map_entry.special_object = m_special_object;
			
			map_entry.pos = pos;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object):Object {
			map_entry.prit_type = c_type_default;
			map_entry.sound_absorb = CellWorld.c_sound_default;
			
			map_entry.max_energy = 0;
			map_entry.energy = 0;
			
			map_entry.mass = 0;
			
			map_entry.pos = -1;
			
			map_entry.radius = c_default_radius;
			map_entry.max_speed = GridObject.c_default_max_move_speed;
			
			map_entry.can_be_absorbed = true;
			map_entry.can_be_attacked = true;
			map_entry.can_be_consumed = true;
			
			map_entry.is_special = false;
			map_entry.special_object = null;
			
			return map_entry;
		}
		
	}
}