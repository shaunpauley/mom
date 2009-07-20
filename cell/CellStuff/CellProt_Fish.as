package CellStuff {
	import flash.display.MovieClip;
	
	import flash.geom.Point;
	
	public class CellProt_Fish extends CellProt{
		
		public function CellProt_Fish(grid:CellGridDisplay, map_entry:Object) {
			if (!myProt) {
				myProt = new PhysProt_RainbowFish();
				myProt.gotoAndStop("disable");
				myProt.scaleX = 1/2;
				myProt.scaleY = 1/2;
				
				addChild(myProt);
			}
			
			super(grid, map_entry);
		}
		
		public override function enable():void {
			super.enable();
			myProt.gotoAndPlay("enable");
		}
		
		public override function disable():void {
			super.disable();
			myProt.gotoAndStop("disable");
		}
		
		public function observeEnter(go:GridObject):void {
			if ( (go.type == GridObject.c_type_cell) && (!go.is_removed) && 
			(!go.cell.m_is_player) && (go.cell.absorbState == c_absorb) ) {
				// kill this thing
				destroyFishAndEnemy(go);
			}
		}
		
		public function observeUpdate(go:GridObject, overlap:Point):void {
			if ( (go.type == GridObject.c_type_cell) && (!go.is_removed) && 
			(!go.cell.m_is_player) && (go.cell.absorbState == c_absorb) ) {
				// kill this thing
				destroyFishAndEnemy(go);
			}
		}
		
		public function destroyFishAndEnemy(go):void {
			destroyFish();
			
			// destroy enemy
			var boss_prit:CellPrit = CellCreator.CreatePrit(myGrid, CellCreator.CreatePritMapEntry({prit_type:CellPrit.c_type_boss}) );
			
			var local_point:Point = go.getLocalPoint();
			var col:int = go.getGridCol();
			var row:int = go.getGridRow();
			var grid_handler:Object = go.myGridHandler;
			
			myGrid.addExplosion(col, row, local_point, go.boundingRadius );
			myGrid.destroyGridObject(go);
			
			//CellCreator.CreateGridObjectLocal_CellPrit_New(myGrid, grid_handler, local_point, boss_prit);
			boss_prit.makeGridObject(grid_handler, local_point);
			myGrid.handleTooClose(boss_prit.myGridObject);
			
		}
		
		public function destroyFish():void {
			myGrid.addExplosion( myGridObject.getGridCol(), myGridObject.getGridRow(), myGridObject.getLocalPoint(), m_radius );
			myCell.removeProt(this);
		}
		
		public override function report(report_type:uint, args:Object):void {
			switch (report_type) {
				case GridObject.c_report_type_enter:
					observeEnter(args.go);
					break;
				case GridObject.c_report_type_update:
					observeUpdate(args.go, args.overlap);
					break;
				default:
					break;
			}
		}
		
		/* Prot Creator */
		public static function getPritCriteria(prit_lookup:Array, prits:Array):Object {
			if (prit_lookup[CellPrit.c_type_fish].length > 0) {
				var fish_lookup:Array = new Array();
				for (var i:int = 0; i < 26; ++i) {
					fish_lookup.push( new Array() );
				}
				for (i = 0; i < prits.length; ++i) {
					if (prits[i].m_type == CellPrit.c_type_fish) {
						fish_lookup[prits[i].m_fish_level].push(i);
					}
				}
				
				var prit_index:Array = new Array();
				if (fish_lookup[CellPrit_Fish.c_fish_level_green].length > 0) {
					prit_index.push(fish_lookup[CellPrit_Fish.c_fish_level_green][0]);
				}
				if (fish_lookup[CellPrit_Fish.c_fish_level_blue].length > 0) {
					prit_index.push(fish_lookup[CellPrit_Fish.c_fish_level_blue][0]);
				}
				if (fish_lookup[CellPrit_Fish.c_fish_level_red].length > 0) {
					prit_index.push(fish_lookup[CellPrit_Fish.c_fish_level_red][0]);
				}
				
				return {type:c_type_fish, prits:prit_index, is_complete:(prit_index.length == 3), num_complete:prit_index.length};
			}
			
			return {type:c_type_fish, is_complete:false, num_complete:0};
		}
		
		/* World Map */
		public override function createAreaMapEntry():Object {
			return CellArea_Report.updateMapEntry_New( new Object(), 23.0);
		}
		
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, constructed_prits:Array, prits_held:Array):Object {
			map_entry = CellProt.updateMapEntry_New(map_entry, constructed_prits, prits_held);
			
			map_entry.prot_type = c_type_fish;
			
			map_entry.state = c_state_disable;
			
			map_entry.radius = c_radius_default;
			map_entry.max_prits_held = 0;
			
			return map_entry;
		}
		
	}
}