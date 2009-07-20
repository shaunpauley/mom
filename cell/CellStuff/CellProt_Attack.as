package CellStuff {
	import flash.display.MovieClip;
	
	public class CellProt_Attack extends CellProt{
		
		public static const c_radius_attack:Number = 10.0;
		
		public static const c_action_attack_radius:Number = 20.0;
		public static const c_force_added:Number = 10.0;
		public static const c_attack:int = 1;
		
		
		public function CellProt_Attack(grid:CellGridDisplay, map_entry:Object) {
			if (!myProt) {
				myProt = new PhysProt_Attack();
				myProt.gotoAndPlay(1);
				addChild(myProt);
			}
			
			super(grid, map_entry);
		}
		
		
		public override function enable():void {
			super.enable();
			myProt.gotoAndPlay("enabled_level" + m_level);
		}
		
		public override function disable():void {
			super.disable();
			myProt.gotoAndPlay("disable_level" + m_level);
		}
		
		public override function upgraded(a:int):void {
			m_upgrade_level = a;
			//todo:figure out area accessibility
			//myArea.m_attack = 1+4*(m_level + m_upgrade_level);
			
			//HelpToolTip.updateText("myArea.m_attack: " + myArea.m_attack);
		}
		
		/* Prot Creator */
		public static function getPritCriteria(prit_lookup:Array):Object {
			if (prit_lookup[CellPrit.c_type_hurt].length > 0) {
				var prit_index:Array = new Array();
				var num_hurt_prits:int = prit_lookup[CellPrit.c_type_hurt].length;
				for (var i:int = 0; (i < 3) && (i < num_hurt_prits); ++i) {
					prit_index.push( prit_lookup[CellPrit.c_type_hurt][i] );
				}
				return {type:c_type_attack, prits:prit_index, is_complete:(prit_index.length == 3), num_complete:prit_index.length};
			}
			return {type:c_type_attack, is_complete:false, num_complete:0};
			
		}
		
		public static function getType():uint {
			return c_type_attack;
		}
		
		/* World Map */
		public override function createAreaMapEntry():Object {
			return CellArea_Attack.updateMapEntry_New(new Object(), c_action_attack_radius, c_force_added, c_attack);
		}
		
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, constructed_prits:Array, prits_held:Array):Object {
			map_entry = CellProt.updateMapEntry_New(map_entry, constructed_prits, prits_held);
			
			map_entry.prot_type = c_type_attack;
			
			map_entry.state = c_state_enable;
			
			map_entry.radius = c_radius_attack;
			map_entry.max_prits_held = 0;
			
			return map_entry;
		}
	}
}