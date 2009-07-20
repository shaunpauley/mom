package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellPrit_Hurt extends CellPrit{
		
		public var m_state:uint;
		
		public var m_cooldown_hurt:int 		= 2;
		
		public static const c_state_normal:uint 	= 0x000001;
		public static const c_state_hurt:uint		= 0x000002;
		
		public function CellPrit_Hurt(grid:CellGridDisplay, map_entry:Object) {
			
			super(grid, map_entry);
			
			// map entries
			m_state = map_entry.state;
			m_cooldown_hurt = map_entry.cooldown_hurt;
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Hurt();
			prit.gotoAndPlay("normal");
			return prit;
		}
		
		/* Callbacks */
		public function hurtFinishedCallback():void {
			changeState(c_state_normal);
		}
		
		/* Change State */
		public function changeState(state:uint):void {
			switch(state) {
				case c_state_normal:
					pritsGotoAndPlay("normal");
					break;
				case c_state_hurt:
					pritsGotoAndPlay("hurt");
					myGridObject.newTimedEvent(hurtFinishedCallback, m_cooldown_hurt);
					break;
				default:
					break;
			}
			
			m_state = state;
		}
		
		
		public override function attacked(a:int):void {
			super.attacked(a);
			if (!myGridObject.is_removed) {
				changeState(c_state_hurt);
			}
		}
		
		public override function removed():void {
			super.removed();
			myGridObject.removeTimedEvent();
		}
		
		public override function absorbed(go:GridObject):void {
			super.absorbed(go);
			myGridObject.removeTimedEvent();
		}
		
		public override function reset():void {
			super.reset();
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			
			map_entry.state = m_state;
			map_entry.cooldown_hurt = m_cooldown_hurt;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, energy:int):Object {
			map_entry = CellPrit.updateMapEntry_New(map_entry);
			
			map_entry.prit_type = c_type_hurt;
			
			map_entry.state = c_state_normal;
			
			map_entry.cooldown_hurt = 2;
			
			map_entry.energy = energy;
			map_entry.max_energy = energy;
			
			map_entry.mass = 5;
			map_entry.radius = 9.0;
			
			return map_entry;
		}
		
	}
}