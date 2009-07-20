package CellStuff {
	import flash.display.MovieClip;
	
	import flash.geom.Point;
	
	public class CellProt_HeartClick extends CellProt{
		
		public function CellProt_HeartClick(grid:CellGridDisplay, map_entry:Object) {
			if (!myProt) {
				myProt = new PhysProt_HeartClick();
				myProt.gotoAndPlay("disable_level0");
				myProt.rotation = 90;
				addChild(myProt);
			}
			
			super(grid, map_entry);
			
		}
		
		public override function enable():void {
			super.enable();
			
			if (myCell) {
				var heart_prit:CellPrit = CellCreator.CreatePrit(myGrid, CellCreator.CreatePritMapEntry({prit_type:CellPrit.c_type_heart}) );
				
				var grid_handler:Object = myGridObject.myGridHandler;
				var local_point:Point = myGridObject.getLocalPoint();
				
				myGrid.addExplosion( myGridObject.getGridCol(), myGridObject.getGridRow(), myGridObject.getLocalPoint(), m_radius );
				myCell.removeProt(this);
				
				//CellCreator.CreateGridObjectLocal_CellPrit_New(myGrid, grid_handler, local_point, heart_prit);
				heart_prit.makeGridObject(grid_handler, local_point);
				myGrid.handleTooClose(heart_prit.myGridObject);
				
			}
		}
		
		public override function disable():void {
			super.disable();
			myProt.gotoAndPlay("disable_level" + m_level);
		}
		
		/* Prot Creator */
		public static function getPritCriteria(prit_lookup:Array):Object {
			if (prit_lookup[CellPrit.c_type_white].length > 0) {
				var prit_index:Array = new Array();
				var num_white_prits:int = prit_lookup[CellPrit.c_type_white].length;
				for (var i:int = 0; (i < 3) && (i < num_white_prits); ++i) {
					prit_index.push( prit_lookup[CellPrit.c_type_white][i] );
				}
				return {type:c_type_heartclick, prits:prit_index, is_complete:(prit_index.length == 3), num_complete:prit_index.length};
			}
			return {type:c_type_heartclick, is_complete:false, num_complete:0};
			
		}
		
		public static function getType():uint {
			return c_type_heartclick;
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, constructed_prits:Array, prits_held:Array):Object {
			map_entry = CellProt.updateMapEntry_New(map_entry, constructed_prits, prits_held);
			
			map_entry.prot_type = c_type_heartclick;
			
			map_entry.state = c_state_disable;
			
			map_entry.radius = c_radius_default;
			map_entry.max_prits_held = 0;
			
			return map_entry;
		}
		
	}
}