package CellStuff {
	import flash.display.MovieClip;
	
	import flash.geom.Point;
	
	import flash.events.Event;
	
	public class CellPrit_Move extends CellPrit{
		
		public var m_move_force_max:Number;
		public var m_move_force_min:Number;
		public var m_new_count:int;
		
		public function CellPrit_Move(grid:CellGridDisplay, map_entry:Object) {
			
			super(grid, map_entry);
			
			// map entries
			m_move_force_max = map_entry.move_force_max;
			m_move_force_min = map_entry.move_force_min;
			m_new_count = map_entry.new_count;
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Move();
			prit.gotoAndPlay("normal");
			return prit;
		}
		
		public function newPath():void {
			var move_speed:Number = Math.random()*(m_move_force_max-m_move_force_min)+m_move_force_min;
			var dv:Point = new Point(Math.random()*10-5, Math.random()*10-5);
			dv.normalize(move_speed);
			
			myGridObject.move(dv);
			
			// display the direction we are moving
			rotation = Math.atan2(dv.y, dv.x) * 180/Math.PI + 90;
		}
		
		/* Callbacks */
		public function newPathCallback():void {
			newPath();
			myGridObject.newTimedEvent(newPathCallback, Math.random()*m_new_count);
		}
		
		public override function absorbed(go:GridObject):void {
			super.absorbed(go);
			rotation = 0;
		}
		
		public override function reset():void {
			super.reset();
			newPathCallback();
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			
			map_entry.move_force_max = m_move_force_max;
			map_entry.move_force_min = m_move_force_min;
			map_entry.new_count = m_new_count;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, energy:int):Object {
			map_entry = CellPrit.updateMapEntry_New(map_entry);
			
			map_entry.move_force_max = 15.0;
			map_entry.move_force_min = 5.0;
			map_entry.new_count = 25;
			
			map_entry.energy = energy;
			map_entry.max_energy = energy;
			map_entry.prit_type = c_type_move;
			
			map_entry.mass = 0.0;
			map_entry.radius = 9.0;
			
			return map_entry;
		}
		
	}
}