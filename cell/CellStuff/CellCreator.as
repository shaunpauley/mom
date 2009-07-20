package CellStuff {
	import flash.display.MovieClip;
	
	import flash.geom.Point;
	
	public class CellCreator{
		
		public static const c_type_none:uint	= 0x999999;
		
		/* Cell Creator */
		
		/* Prit Creator */
		public static function CreatePritMapEntry(prit_record:Object):Object {
			var map_entry:Object = new Object();
			
			switch(prit_record.prit_type) {
				case CellPrit.c_type_heavy:
					map_entry = CellPrit_Heavy.updateMapEntry_New(map_entry);
					break;					
				case CellPrit.c_type_boss:
					map_entry = CellPrit_Boss.updateMapEntry_New(
					map_entry, 
					prit_record.area_text_type, 
					prit_record.area_texts,
					prit_record.area_text_repeat,
					prit_record.absorb_text_type,
					prit_record.absorb_texts,
					prit_record.absorb_text_repeat);
					break;					
				case CellPrit.c_type_question:
					map_entry = CellPrit_Question.updateMapEntry_New(map_entry);
					break;					
				case CellPrit.c_type_letter:
					map_entry = CellPrit_Letter.updateMapEntry_New(map_entry, prit_record.energy, prit_record.letter);
					break;					
				case CellPrit.c_type_gold:
					map_entry = CellPrit_Gold.updateMapEntry_New(map_entry);
					break;					
				case CellPrit.c_type_white:
					map_entry = CellPrit_White.updateMapEntry_New(map_entry);
					break;					
				case CellPrit.c_type_energyball:
					map_entry = CellPrit_EnergyBall.updateMapEntry_New(map_entry, 
					prit_record.max_energy, 
					prit_record.replace_entry);
					break;					
				case CellPrit.c_type_butterfly:
					map_entry = CellPrit_Butterfly.updateMapEntry_New(map_entry, prit_record.energy, prit_record.level);
					break;					
				case CellPrit.c_type_attack:
					map_entry = CellPrit_Attack.updateMapEntry_New(map_entry);
					break;					
				case CellPrit.c_type_heart:
					map_entry = CellPrit_Heart.updateMapEntry_New(map_entry);
					break;					
				case CellPrit.c_type_fish:
					map_entry = CellPrit_Fish.updateMapEntry_New(map_entry, prit_record.energy, prit_record.level);
					break;					
				case CellPrit.c_type_worm:
					map_entry = CellPrit_Worm.updateMapEntry_New(map_entry);
					break;					
				case CellPrit.c_type_hurt:
					map_entry = CellPrit_Hurt.updateMapEntry_New(map_entry, prit_record.energy);
					break;					
				case CellPrit.c_type_soft:
					map_entry = CellPrit_Soft.updateMapEntry_New(map_entry, prit_record.energy);
					break;					
				case CellPrit.c_type_move:
					map_entry = CellPrit_Move.updateMapEntry_New(map_entry, prit_record.energy);
					break;					
				case CellPrit.c_type_default:
				default:
					map_entry = CellPrit.updateMapEntry_New(map_entry);
					break;					
			}
			
			return map_entry;
		}
		
		public static function CreatePrit(grid:CellGridDisplay, map_entry:Object):CellPrit {
			
			var prit:CellPrit = null;
			
			switch(map_entry.prit_type) {
				case CellPrit.c_type_heavy:
					prit = new CellPrit_Heavy(grid, map_entry);
					break;					
				case CellPrit.c_type_boss:
					prit = new CellPrit_Boss(grid, map_entry);
					break;					
				case CellPrit.c_type_question:
					prit = new CellPrit_Question(grid, map_entry);
					break;					
				case CellPrit.c_type_letter:
					prit = new CellPrit_Letter(grid, map_entry);
					break;					
				case CellPrit.c_type_gold:
					prit = new CellPrit_Gold(grid, map_entry);
					break;					
				case CellPrit.c_type_white:
					prit = new CellPrit_White(grid, map_entry);
					break;					
				case CellPrit.c_type_energyball:
					prit = new CellPrit_EnergyBall(grid, map_entry);
					break;					
				case CellPrit.c_type_butterfly:
					prit = new CellPrit_Butterfly(grid, map_entry);
					break;					
				case CellPrit.c_type_attack:
					prit = new CellPrit_Attack(grid, map_entry);
					break;					
				case CellPrit.c_type_heart:
					prit = new CellPrit_Heart(grid, map_entry);
					break;					
				case CellPrit.c_type_fish:
					prit = new CellPrit_Fish(grid, map_entry);
					break;					
				case CellPrit.c_type_worm:
					prit = new CellPrit_Worm(grid, map_entry);
					break;					
				case CellPrit.c_type_hurt:
					prit = new CellPrit_Hurt(grid, map_entry);
					break;					
				case CellPrit.c_type_soft:
					prit = new CellPrit_Soft(grid, map_entry);
					break;
				case CellPrit.c_type_move:
					prit = new CellPrit_Move(grid, map_entry);
					break;					
				case CellPrit.c_type_default:
				default:
					prit = new CellPrit(grid, map_entry);
					break;					
			}
			
			// todo: separate rotation
			prit.rotation = (Math.random()*360);
			
			return prit;
		}
		
		/* Prot Creator */
		public static function CreateProtMapEntry(prot_type:uint, constructed_prits:Array, prits_held:Array):Object {
			var map_entry:Object = new Object();
			
			switch(prot_type) {
				case CellProt.c_type_cat:
					map_entry = CellProt_Cat.updateMapEntry_New(map_entry, constructed_prits, prits_held);
					break;
				case CellProt.c_type_boss:
					map_entry = CellProt_Boss.updateMapEntry_New(map_entry, constructed_prits, prits_held);
					break;
				case CellProt.c_type_fish:
					map_entry = CellProt_Fish.updateMapEntry_New(map_entry, constructed_prits, prits_held);
					break;
				case CellProt.c_type_pearl:
					map_entry = CellProt_Pearl.updateMapEntry_New(map_entry, constructed_prits, prits_held);
					break;
				case CellProt.c_type_worm:
					map_entry = CellProt_Worm.updateMapEntry_New(map_entry, constructed_prits, prits_held);
					break;
				case CellProt.c_type_heartclick:
					map_entry = CellProt_HeartClick.updateMapEntry_New(map_entry, constructed_prits, prits_held);
					break;
				case CellProt.c_type_attack:
					map_entry = CellProt_Attack.updateMapEntry_New(map_entry, constructed_prits, prits_held);
					break;
				case CellProt.c_type_default:
				default:
					map_entry = CellProt.updateMapEntry_New(map_entry, constructed_prits, prits_held);
					break;
			}
			return map_entry;
		}
		
		public static function CreateProt(grid:CellGridDisplay, map_entry):CellProt {
			var prot:CellProt = null;
			
			switch(map_entry.prot_type) {
				case CellProt.c_type_cat:
					prot = new CellProt_Cat(grid, map_entry);
					break;
				case CellProt.c_type_boss:
					prot = new CellProt_Boss(grid, map_entry);
					break;
				case CellProt.c_type_fish:
					prot = new CellProt_Fish(grid, map_entry);
					break;
				case CellProt.c_type_pearl:
					prot = new CellProt_Pearl(grid, map_entry);
					break;
				case CellProt.c_type_worm:
					prot = new CellProt_Worm(grid, map_entry);
					break;
				case CellProt.c_type_heartclick:
					prot = new CellProt_HeartClick(grid, map_entry);
					break;
				case CellProt.c_type_attack:
					prot = new CellProt_Attack(grid, map_entry);
					break;
				case CellProt.c_type_default:
				default:
					prot = new CellProt(grid, map_entry);
					break;
			}
			
			return prot;
		}
		
		public static function getProtCriteriaFromPrits(prits:Array):Object {
			var prot_crit:Object = {is_complete:false, num_complete:0};
			
			var pritLookup:Array = new Array();
			for (var i:int = 0; i < CellWorld.c_num_prits; i++) {
				pritLookup.push( new Array() );
			}
			
			for (i = 0; i < prits.length; i++) {
				var prit:CellPrit = prits[i];
				pritLookup[prit.m_type].push(i);
			}
			
			for (i = 0; i < 8; ++i) {
				var new_prot_crit:Object = null;
				switch (i) {
					case 0:
						new_prot_crit = CellProt_Cat.getPritCriteria(pritLookup, prits);
						break;
					case 1:
						new_prot_crit = CellProt_Worm.getPritCriteria(pritLookup);
						break;
					case 2:
						new_prot_crit = CellProt_Fish.getPritCriteria(pritLookup, prits);
						break;
					case 3:
						new_prot_crit = CellProt_Pearl.getPritCriteria(pritLookup);
						break;
					case 4:
						new_prot_crit = CellProt_HeartClick.getPritCriteria(pritLookup);
						break;
					case 5:
						new_prot_crit = CellProt_Attack.getPritCriteria(pritLookup);
						break;
					case 6:
						new_prot_crit = CellProt_Boss.getPritCriteria(pritLookup);
						break;
					default:
						new_prot_crit = CellProt.getPritCriteria();
						break;
				}
				
				if (new_prot_crit.is_complete) {
					prot_crit = new_prot_crit;
					break;
				} else if (new_prot_crit.num_complete > prot_crit.num_complete) {
					prot_crit = new_prot_crit;
				}
			}
			
			return prot_crit;
		}
		
		// we have this method here because there are different times we will need to make a prot:
		// 1) when we have a prot enter a world
		// 2) when we collect prits to make a prot
		public static function CreateGridObjectFromProt_CellSingle(grid:CellGridDisplay, cell_go:GridObject, prot:CellProt):GridObject {
			prot.myGridObject = grid.makeGridObject(GridObject.c_type_prot, prot.m_radius, cell_go.mass, cell_go.move_max_speed);
			prot.myGridObject.initLocationFromObject(cell_go);
			
			prot.myGridObject.prot = prot;
			
			grid.addToGridLocal( prot.myGridObject, grid.getGridFromObject(cell_go), cell_go.getLocalPoint() );
			grid.attachRotatingObject(prot.myGridObject, cell_go);
			
			return prot.myGridObject;
		}
		
		public static function CreateGridObjectFromNewProt_CellSingle(grid:CellGridDisplay, cell_go:GridObject, prot:CellProt):GridObject {
			var go:GridObject = CreateGridObjectFromProt_CellSingle(grid, cell_go, prot);
			
			// since this is a new prot, we create and add the area here
			var map_entry:Object = prot.createAreaMapEntry();
			
			if (map_entry) {
				var area:CellArea = CellCreator.CreateArea(grid, map_entry);
				CreateGridObjectFromArea(grid, go, area);
			}
			
			return go;
		}
		
		/* Area Creator */
		public static function CreateAreaMapEntry(area_record:Object):Object {
			var map_entry:Object = new Object();
			
			switch(area_record.area_type) {
				case CellArea.c_type_textdisplay:
					map_entry = CellArea_TextDisplay.updateMapEntry_New( 
					new Object(), 
					area_record.radius, 
					area_record.area_texts, 
					area_record.area_text_type, 
					area_record.area_text_repeat);
					break;
				case CellArea.c_type_report:
				default:
					map_entry = CellArea_Report.updateMapEntry_New( new Object(), area_record.radius );
					break;
			}
			
			return map_entry;
		}
		
		public static function CreateArea(grid:CellGridDisplay, map_entry:Object):CellArea {
			var area:CellArea = null;
			
			switch(map_entry.area_type) {
				case CellArea.c_type_none:
				default:
					area = new CellArea(grid, map_entry);
					break;
				case CellArea.c_type_textdisplay:
					area = new CellArea_TextDisplay(grid, map_entry);
					break;
				case CellArea.c_type_attack:
					area = new CellArea_Attack(grid, map_entry);
					break;
				case CellArea.c_type_energysuck:
					area = new CellArea_EnergySuck(grid, map_entry);
					break;
				case CellArea.c_type_report:
					area = new CellArea_Report(grid, map_entry);
					break;
				case CellArea.c_type_upgrade:
					area = new CellArea_Upgrade(grid, map_entry);
					break;
			}
			
			return area;
		}
		
		public static function CreateGridObjectFromArea(grid:CellGridDisplay, go:GridObject, area:CellArea):GridObject {
			area.myGridObject = grid.makeGridObject(GridObject.c_type_area, area.m_radius, go.mass, go.move_max_speed);
			area.myGridObject.initLocationFromObject(go);
			
			area.myGridObject.area = area;
			
			grid.addToGridLocal( area.myGridObject, grid.getGridFromObject(go), go.getLocalPoint() );
			grid.attachAreaObject(area.myGridObject, go);
			
			return area.myGridObject;
		}
	}
}