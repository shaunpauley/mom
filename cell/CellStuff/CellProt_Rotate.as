package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellProt_Rotate extends CellProt{
		
		public static const c_radius_rotate:Number = 10.0;
		
		public function CellProt_Rotate(grid:CellGridDisplay, map_entry:Object) {
			if (!myProt) {
				myProt = new PhysProt_Rotate();
				myProt.gotoAndPlay(1);
				addChild(myProt);
			}
			
			super(grid, map_entry);
		}
		
		public function rotateRingCallback():void {
			// move only when the cell moves. this prevents unwanted selecting problems
			if ( myCell && !myCell.myGridObject.isMovementStop() &&  (m_ring > 0) ) {
				CellWorld.rotateRing(myCell, m_ring, 2);
			}
		}
		
		public override function disable():void {
			super.disable();
			myGridObject.removeTimedEvent();
			myProt.gotoAndPlay("disabled_level" + m_level);
		}
		
		public override function enable():void {
			super.enable();
			myGridObject.newTimedEvent(rotateRingCallback, 0, true);
			myProt.gotoAndPlay("enabled_level" + m_level);
		}
		
		public override function removed():void {
			myGridObject.removeTimedEvent();
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, constructed_prits:Array, prits_held:Array):Object {
			map_entry = CellProt.updateMapEntry_New(map_entry, constructed_prits, prits_held);
			
			map_entry.prot_type = c_type_rotate;
			
			map_entry.state = c_state_enable;
			
			map_entry.radius = c_radius_rotate;
			map_entry.max_prits_held = 0;
			
			return map_entry;
		}
	}
}