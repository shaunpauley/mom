package CellStuff {
	import flash.display.MovieClip;
	
	import flash.geom.Point;
	
	import flash.display.BlendMode;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class CellPrit_EnergyBall extends CellPrit{
		
		public var myLight:PhysLights;
		
		public var m_replace_entry:Object;
		public var m_alpha_light_value:Number;
		
		public var m_energyball_level:int;
		
		public static const c_alpha_step:Number = 0.01;
		
		public function CellPrit_EnergyBall(grid:CellGridDisplay, map_entry:Object) {
			m_energyball_level = map_entry.energyball_level;
			
			super(grid, map_entry);
			
			m_replace_entry = map_entry.replace_entry;
			m_alpha_light_value = map_entry.alpha_light_value;
			
			myLight = new PhysLights();
			myLight.alpha = 0.0;
			myLight.blendMode = BlendMode.ADD;
			myLight.gotoAndPlay(1);
			myPrit.addChild(myLight);
			updateLight();
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_EnergyBall();
			prit.gotoAndStop("no_energy_level" + m_energyball_level);
			return prit;
		}
		
		public override function increaseEnergy(energy:int):int {
			var de:int = super.increaseEnergy(energy);
			updateLight();
			
			if (m_energy == m_max_energy) {
				replaceEnergyBall();
			}
			return de;
		}
		
		public function replaceEnergyBall():void {
			var replace_prit:CellPrit = CellCreator.CreatePrit(myGrid, m_replace_entry);
			
			var grid_handler:Object = myGridObject.myGridHandler;
			var local_point:Point = myGridObject.getLocalPoint();
			
			myGrid.addExplosion( myGridObject.getGridCol(), myGridObject.getGridRow(), myGridObject.getLocalPoint(), m_radius );
			myGrid.destroyGridObject(myGridObject);
			
			//CellCreator.CreateGridObjectLocal_CellPrit_New(myGrid, grid_handler, local_point, replace_prit);
			replace_prit.makeGridObject(grid_handler, local_point);
			myGrid.handleTooClose(replace_prit.myGridObject);
			
		}
		
		public function updateLight():void {
			m_alpha_light_value = m_energy/m_max_energy;
			if (myGridObject) {
				myGridObject.newTimedEvent(updateLightCallBack, 0, true);
			} else {
				myLight.alpha = m_alpha_light_value;
				myLight.scaleX = 1 + 2*m_alpha_light_value;
				myLight.scaleY = 1 + 2*m_alpha_light_value;
			}
		}
		
		public function updateLightCallBack():void {
			var dv:Number = (m_alpha_light_value - myLight.alpha);
			var new_val:Number = 0;
			if (Math.abs(dv) < c_alpha_step) {
				// set and remove callback
				new_val = m_alpha_light_value;
				myGridObject.removeTimedEvent();
			} else {
				new_val = myLight.alpha + c_alpha_step*(dv<0?-1:1);
			}
			myLight.alpha = new_val;
			myLight.scaleX = 1 + 2*new_val;
			myLight.scaleY = 1 + 2*new_val;
		}
		
		/* World Map */
		public override function createAreaMapEntry():Object {
			if (m_energyball_level == 1) {
				return CellArea_EnergySuck.updateMapEntry_New( new Object(), 40.0, 2);
			}
			return CellArea_EnergySuck.updateMapEntry_New( new Object(), 40.0);
		}
		
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			
			map_entry.replace_entry = m_replace_entry;
			map_entry.alpha_light_value = m_alpha_light_value;
			
			map_entry.energyball_level = m_energyball_level;
			
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, max_energy:int, replace_entry:Object):Object {
			map_entry = CellPrit.updateMapEntry_New(map_entry);
			
			map_entry.prit_type = c_type_energyball;
			
			map_entry.mass = GridObject.c_max_mass;
			map_entry.radius = 16.0;
			
			map_entry.energy = 0;
			map_entry.max_energy = max_energy;
			
			map_entry.energyball_level = (max_energy > 10)?1:0;
			
			map_entry.can_be_attacked = false;
			map_entry.can_be_absorbed = false;
			
			map_entry.replace_entry = replace_entry;
			map_entry.alpha_light_value = 0.0;
			
			return map_entry;
			
			
		}
		
	}
}