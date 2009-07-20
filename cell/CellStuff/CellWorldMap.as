package CellStuff {
	
	import flash.geom.Point;
	
	public class CellWorldMap {
		public var myMap:Array;
		
		public var myCellPlayer:CellSingle_Player;
		
		public var myPersistants:Array;
		public var mySpecialObjects:Array;
		public var myTextRecords:Array;
		
		public var level:int
		public var cols:int;
		public var rows:int;
		
		public var m_current_col:int
		public var m_current_row:int
		
		public var m_start_col:int;
		public var m_start_row:int;
		
		public var m_player_entry:Object;
		
		public static const c_type_nothing:uint		= 0x000000;
		public static const c_type_random:uint		= 0x000001;
		
		public function CellWorldMap(l:int, cs:int, rs:int, start_col:int, start_row:int, cell_player:CellSingle_Player, default_background:uint) {
			
			myMap = new Array();
			
			myCellPlayer = cell_player;
			
			level = l;
			cols = cs;
			rows = rs;
			
			m_start_col = start_col;
			m_start_row = start_row;
			
			m_current_col = start_col;
			m_current_row = start_row;
			
			myPersistants = new Array();
			for (var p:int = 0; p < CellWorld.c_num_prits; ++p) {
				myPersistants.push(false);
			}
			
			mySpecialObjects = new Array();
			myTextRecords = new Array();
			
			for (var r:int = 0; r < rows; r++) {
				for (var c:int = 0; c < cols; c++) {
					addNewPlaceInfo(c, r, default_background);
				}
			}
			
			// player
			m_player_entry = null;
		}
		
		/* Clear World Map */
		public function clearMap():void {
			m_current_col = m_start_col;
			m_current_row = m_start_row;
			
			for (var p:int = 0; p < CellWorld.c_num_prits; ++p) {
				myPersistants[p] = false;
			}
			
			while (mySpecialObjects.length > 0) {
				mySpecialObjects.pop();
			}
			
			for (var r:int = 0; r < rows; r++) {
				for (var c:int = 0; c < cols; c++) {
					resetPlaceInfo(c, r);
				}
			}
		}
		
		public function resetPlaceInfo(c:int, r:int):void {
			var place_info:Object = getPlaceInfo(c, r);
			
			while (place_info.objects.length > 0) {
				place_info.objects.pop();
			}
			
			while (place_info.special_objects.length > 0) {
				place_info.special_objects.pop();
			}
		}
		
		/* New Place Informaion */
		public function addNewPlaceInfo(c:int, r:int, default_background:uint):void {
			var place_info:Object = new Object();
			
			place_info.objects = new Array();
			place_info.col = c;
			place_info.row = r;
			
			place_info.background = default_background;
			place_info.special_objects = new Array();
			
			myMap.push(place_info);
		}
		
		/* Moving */
		public function moveCurrentCol(dc:int):void {
			m_current_col += dc;
			if (m_current_col >= cols) {
				m_current_col -= cols;
			} else if (m_current_col < 0) {
				m_current_col += cols;
			}
		}
		
		public function moveCurrentRow(dr:int):void {
			m_current_row += dr;
			if (m_current_row >= rows) {
				m_current_row -= rows;
			} else if (m_current_row < 0) {
				m_current_row += rows;
			}
		}
		
		/* Get Place Information */
		public function getPlaceInfo(c:int, r:int):Object {
			return myMap[c + r*cols];
		}
		
		public function getPlaceInfo_Grid(gc:int, gr:int):Object {
			return getPlaceInfo( (gc + m_current_col) % cols, (gr + m_current_row) % rows );
		}
		
		public function getPlaceInfo_Random():Object {
			return getPlaceInfo( int(cols*Math.random()), int(rows*Math.random()) );
		}
		
		public function getPlaceObjects(c:int, r:int):Array {
			return getPlaceInfo(c, r).objects;
		}
		
		public function getPlaceObjects_Grid(gc:int, gr:int):Array {
			return getPlaceInfo_Grid(gc, gr).objects;
		}
		
		public function fillWithRandomPlaces(prit_set:Array, enemy_set:Array, persist:Boolean = false, num_prits_each:int = 10, num_enemies:int = 0):void {
			for (var c:int = 0; c < cols; c++) {
				for (var r:int = 0; r < rows; r++) {
					addRandomPlace(c, r, prit_set, persist, num_prits_each);
				}
			}
			for (var e:int = 0; e < num_enemies; ++e) {
				var local_point:Point = new Point(CellGridDisplay.gridWidthPixel*Math.random(), CellGridDisplay.gridHeightPixel*Math.random());
				addNewEnemy(int(Math.random()*cols), int(Math.random()*rows), local_point, enemy_set[int(Math.random()*enemy_set.length)]);
			}
		}
		
		public function addRandomPlace(c, r, prit_set:Array, persist:Boolean = false, num_prits:int = 10):void {
			for (var i:int = 0; i < num_prits; i++) {
				var local_point:Point = new Point(CellGridDisplay.gridWidthPixel*Math.random(), CellGridDisplay.gridHeightPixel*Math.random());
				
				var percent_choose:Number = Math.random() * 1.0;
				var prit_record:Object = prit_set[0];
				var percent_total:Number = 0.0;
				for (var p:int = 0; (p < prit_set.length) && (percent_choose > percent_total); ++p) {
					prit_record = prit_set[p];
					percent_total += prit_record.percent;
				}
				addNewPrit(c, r, local_point, prit_record, persist);
			}
		}
		
		public function createNewPritMapEntry(prit_record:Object):Object {
			var new_entry:Object = CellCreator.CreatePritMapEntry(prit_record);
			
			new_entry.type = GridObject.c_type_prit;
			new_entry.prit_type = prit_record.prit_type;
			new_entry.attached = new Array();
			
			// this is a new prit so set new
			new_entry.is_new = true;
			
			return new_entry;
		}
		
		public function addNewPrit(c:int, r:int, local_point:Point, prit_record:Object, persist:Boolean = false):void {
			var new_entry:Object = createNewPritMapEntry(prit_record);
			
			myPersistants[prit_record.prit_type] = persist;
			
			new_entry.col = c;
			new_entry.row = r;
			new_entry.local_point = local_point;
			
			if (prit_record.texts) {
				var text_record:Object = {map_entry:new_entry, 
				texts:prit_record.texts, 
				text_type:prit_record.text_type, 
				text_repeat:prit_record.text_repeat};
				
				new_entry.text_record = text_record;
				
				myTextRecords.push(text_record);
			}
			
			// special
			if (prit_record.is_special) {
				var special_object:Object = new Object();
				special_object.type = prit_record.special_type;
				special_object.object = null;
				special_object.col = c;
				special_object.row = r;
				special_object.local_point = local_point;
				
				new_entry.is_special = true;
				new_entry.special_object = special_object;
				
				mySpecialObjects.push(special_object);
			}
			
			var prit_info:Object = getPlaceInfo(c, r);
			prit_info.objects.push(new_entry);
		}
		
		public function addNewPrit_RandomLocation(prit_record:Object, persist:Boolean = false, num:int = 1):void {
			for (var i:int = 0; i < num; ++i) {
				var c:int = int(Math.random()*cols);
				var r:int = int(Math.random()*rows);
				var local_point:Point = new Point(CellGridDisplay.gridWidthPixel*Math.random(), CellGridDisplay.gridHeightPixel*Math.random());
				addNewPrit(c, r, local_point, prit_record, persist);
			}
		}
		
		public function addMapEntry_RandomLocation(map_entry:Object):void {
			var c:int = int(Math.random()*cols);
			var r:int = int(Math.random()*rows);
			
			map_entry.col = c;
			map_entry.row = r;
			map_entry.local_point.x = CellGridDisplay.gridWidthPixel*Math.random();
			map_entry.local_point.y = CellGridDisplay.gridHeightPixel*Math.random();
			getPlaceObjects(c, r).push(map_entry);
		}
		
		public function addNewEnemy(c:int, r:int, local_point:Point, enemy_record:Object, attached_record:Object = null):void {
			var new_entry:Object = new Object();
			new_entry.col = c;
			new_entry.row = r;
			new_entry.local_point = local_point;
			new_entry.type = GridObject.c_type_cell;
			
			new_entry.attached = new Array();
			
			if (attached_record) {
				if (attached_record.type == GridObject.c_type_area) {
					var area_entry:Object = CellCreator.CreateAreaMapEntry(attached_record);
					area_entry.local_point = new Point(0, 0);
					area_entry.type = GridObject.c_type_area;
					new_entry.attached.push(area_entry);
				}
			}
			
			new_entry = CellSingle_Enemy.updateMapEntry_NewLevel(new_entry, enemy_record.level, enemy_record.energy);
			
			getPlaceObjects(c, r).push(new_entry);
		}
		
		public function isPersistantObject(go:GridObject):Boolean {
			if ( (go.type == GridObject.c_type_prit) && (go.prit) ) {
				if (go.prit) {
					return myPersistants[go.prit.m_type];
				}
			}
			return false;
		}
		
		public function handlePersistantObject(go:GridObject):void {
			if ( isPersistantObject(go) ) {
				addMapEntry_RandomLocation(go.makeMapEntry());
			}
		}
		
		/* Player Entry */
		public function storePlayerEntry(cell_player:CellSingle_Player, gc:int, gr:int, local_point:Point):void {
			var entry:Object = cell_player.myGridObject.makeMapEntry();
			entry.local_point = local_point;
			entry.col = gc + m_current_col;
			entry.row = gr + m_current_row;
			entry.grid_col = gc;
			entry.grid_row = gr;
			
			m_player_entry = entry;
		}
		
		public function loadPlayerTransition_Init(cell_player:CellSingle_Player, gc:int, gr:int, local_point:Point, grid:CellGridDisplay):void {
			
			// add to grid
			var go:GridObject = grid.makeGridObjectLocal(local_point.x, local_point.y,
			GridObject.c_type_cell, 
			cell_player.stats_radius, 
			cell_player.stats_mass, 
			cell_player.stats_max_speed, 
			grid.myWorldMap.level);
			
			cell_player.myGridObject = go;
			go.cell = cell_player;
			
			go.sprite.addChild(cell_player);
			
			var grid_handler:Object = grid.getGrid(gc, gr);
			grid.addToGridLocal(go, grid_handler, local_point);
			
			// set distance
			var world_point1:Point = grid.localToWorld(grid_handler, local_point);
			
			grid_handler = grid.getGrid(m_player_entry.grid_col, m_player_entry.grid_col);
			var world_point2:Point = grid.localToWorld(grid_handler, m_player_entry.local_point);
			
			var dv:Point = world_point2.subtract(world_point1);
			dv.normalize( dv.length/(CellWorld.c_death_reset_count * CellWorld.c_fps / 1000) );
			m_player_entry.load_transition_move = dv;
		}
		
		public function loadPlayerTransition_Update(cell_player:CellSingle_Player, grid:CellGridDisplay):void {
			// move player
			grid.moveObject(cell_player.myGridObject, m_player_entry.load_transition_move);
		}
		
		public function loadPlayerTransition_End(cell_player:CellSingle_Player, grid:CellGridDisplay):void {
			var map_entry:Object = m_player_entry;
			cell_player.resetFromMapEntry(map_entry);
			
			// add to grid
			var go:GridObject = grid.makeGridObjectLocal(map_entry.local_point.x, map_entry.local_point.y,
			GridObject.c_type_cell, 
			cell_player.stats_radius, 
			cell_player.stats_mass, 
			cell_player.stats_max_speed, 
			grid.myWorldMap.level);
			
			cell_player.myGridObject = go;
			go.cell = cell_player;
			
			go.sprite.addChild(cell_player);
			
			var grid_handler:Object = grid.getGrid(m_player_entry.grid_col, m_player_entry.grid_row);
			grid.addToGridLocal(go, grid_handler, map_entry.local_point);
				
				/* TODO
				// handle attached
				while (entry.attached.length > 0) {
					entry_attached = entry.attached.pop();
					entry_attached.attach_source = go;
					makeGridObjectFromEntry(grid, grid_handler, entry_attached);
				}
				*/
				
			// init our cell
			go.cell.reset();
				
			// needed incase we drop a prit on top of another object
			grid.handleTooClose(go);
		}
		
		/* Grid Object Entries */
		public function addGridObject(go:GridObject, local_point:Point, gc:int, gr:int):void {
			var c:int = (gc + m_current_col) % cols;
			var r:int = (gr + m_current_row) % rows;
			var place:Array = getPlaceObjects(c, r);
			var entry:Object = go.makeMapEntry();
			
			entry.col = c;
			entry.row = r;
			entry.local_point = local_point;
			
			place.push(entry);
		}
		
		public function updateGrid(grid:CellGridDisplay, grid_handler:Object):void {
			var place_info:Object = getPlaceInfo_Grid(grid_handler.col, grid_handler.row);
			grid_handler.background = place_info.background;
			
			var place:Array = place_info.objects;
			
			while(place.length > 0) {
				var entry:Object = place.pop();
				var go:GridObject = makeGridObjectFromEntry(grid, grid_handler, entry.local_point, entry);
			}
		}
		
		public function makeGridObjectFromEntry(grid:CellGridDisplay, grid_handler:Object, local_point:Point, entry:Object):GridObject {
			var go:GridObject = null;
			
			if (entry.type == GridObject.c_type_prit) {
				var prit:CellPrit = CellCreator.CreatePrit(grid, entry);
				
				if (entry.is_new) {
					//go = CellCreator.CreateGridObjectLocal_CellPrit_New(grid, grid_handler, entry.local_point, prit);
					go = prit.makeGridObject(grid_handler, local_point);
					var map_entry:Object = prit.createAreaMapEntry();
					if (map_entry) {
						var area:CellArea = CellCreator.CreateArea(grid, map_entry);
						CellCreator.CreateGridObjectFromArea(grid, go, area);
					}
					
				} else {
					//go = CellCreator.CreateGridObjectLocal_CellPrit(grid, grid_handler, entry.local_point, prit);
					go = prit.makeGridObject(grid_handler, local_point);
				}
				
				while (entry.attached.length > 0) {
					var entry_attached:Object = entry.attached.pop();
					entry_attached.attach_source = go;
					makeGridObjectFromEntry(grid, grid_handler, entry_attached.local_point, entry_attached);
				}
				
				grid.handleTooClose(go);
				
			} else if (entry.type == GridObject.c_type_cell) {
				var cell:CellSingle = new CellSingle_Enemy(grid, myCellPlayer, entry);
				
				go = grid.makeGridObjectLocal(local_point.x, local_point.y,
											GridObject.c_type_cell, cell.stats_radius, cell.stats_mass, cell.stats_max_speed, 
											grid.myWorldMap.level);
				//
				cell.myGridObject = go;
				go.cell = cell;
				
				go.sprite.addChild(cell);
				
				// add to the grid
				grid.addToGridLocal(go, grid_handler, local_point);
				
				// handle attached
				while (entry.attached.length > 0) {
					entry_attached = entry.attached.pop();
					entry_attached.attach_source = go;
					makeGridObjectFromEntry(grid, grid_handler, entry_attached.local_point, entry_attached);
				}
				
				
				// init our cell
				go.cell.reset();
				
				// needed incase we drop a prit on top of another object
				grid.handleTooClose(go);
				
			} else if ( (entry.type == GridObject.c_type_prot) && (entry.attach_source != null) ) {
				var prot:CellProt = CellCreator.CreateProt(grid, entry);
				
				if (entry.state == CellProt.c_state_enable) {
					prot.enable();
				} else {
					prot.disable();
				}
				
				var cell_go:GridObject = entry.attach_source;
				go = CellCreator.CreateGridObjectFromProt_CellSingle(grid, cell_go, prot);
				go.sprite.addChild(prot);
				prot.myGridObject = go;
				
				// add prot adds to grid, etc.
				entry.attach_source.cell.addProt(entry.ring, entry.angle, prot);
				
				while (entry.attached.length > 0) {
					entry_attached = entry.attached.pop();
					entry_attached.attach_source = prot.myGridObject;
					makeGridObjectFromEntry(grid, grid_handler, entry_attached.local_point, entry_attached);
				}
				
			} else if ( (entry.type == GridObject.c_type_area) && (entry.attach_source != null) ) {
				area = CellCreator.CreateArea(grid, entry);
				var prot_go:GridObject = entry.attach_source;
				// create grid object adds go to the grid
				go = CellCreator.CreateGridObjectFromArea(grid, prot_go, area);
				area.myGridObject = go;
			} 
			
			// text object
			if (entry.text_object) {
				go.text_object = entry.text_object;
				entry.text_object.grid_object = go;
				entry.text_object.map_entry = null;
			}
			
			if (entry.text_record) {
				entry.text_record.grid_object = go;
			}
			
			if (entry.is_special) {
				entry.special_object.object = go;
			}
			
			return go;
		}
		
		
		/* Create World Map */
		public static function fillWorldMap(world_map:CellWorldMap, grid:CellGridDisplay):CellWorldMap {
			var prit_set:Array = new Array();
			var enemy_set:Array = new Array();
			switch(world_map.level) {
				case 0:
				default:
					prit_set.push( {prit_type:CellPrit.c_type_default, percent:0.80} );
					prit_set.push( {prit_type:CellPrit.c_type_heavy, percent:0.20} );
					
					enemy_set.push( {level:0, energy:0} );
					
					world_map.fillWithRandomPlaces(prit_set, enemy_set, true, 10, 40);
					
					var texts:Array = new Array();
					texts.push("");
					texts.push("HELP ME!");
					texts.push("");
					texts.push("HEY! HELP ME!!");
					texts.push("");
					texts.push("PLEASE! COME HERE!");
					
					var area_texts:Array = new Array();
					area_texts.push("CAN YOU EAT ME?");
					area_texts.push("PRESS SPACEBAR \nTO OPEN YOUR MOUTH");
					area_texts.push("THEN SPACEBAR AGAIN \nTO CLOSE");
					
					var absorb_texts:Array = new Array();
					absorb_texts.push("THANK YOU!\nHERE IS SOME ENERGY.");
					absorb_texts.push("PLEASE FIND MY FRIENDS");
					
					world_map.addNewPrit_RandomLocation( 
					{prit_type:CellPrit.c_type_boss, 
					texts:texts,
					text_type:CellTextHandler.c_text_type_red_large,
					text_repeat:true,
					area_texts:area_texts,
					area_text_type:CellTextHandler.c_text_type_normal,
					area_text_repeat:false,
					absorb_texts:absorb_texts,
					absorb_text_type:CellTextHandler.c_text_type_normal,
					absorb_text_repeat:false}, 
					false, 1 );
					
					break;
				case 1:
					prit_set.push( {prit_type:CellPrit.c_type_heavy, percent:0.10} );
					prit_set.push( {prit_type:CellPrit.c_type_white, percent:0.90} );
					
					world_map.fillWithRandomPlaces(prit_set, enemy_set, true, 8, 0);
					
					var heart_entry:Object = world_map.createNewPritMapEntry( {prit_type:CellPrit.c_type_heart} );
					
					world_map.addNewPrit_RandomLocation( {prit_type:CellPrit.c_type_energyball, max_energy:5, replace_entry:heart_entry}, false, 5 );
					world_map.addNewPrit_RandomLocation( {prit_type:CellPrit.c_type_butterfly, energy:0, level:0}, false, 20 );
					world_map.addNewPrit_RandomLocation( {prit_type:CellPrit.c_type_butterfly, energy:3, level:1}, false, 10 );
					world_map.addNewPrit_RandomLocation( {prit_type:CellPrit.c_type_butterfly, energy:5, level:2}, false, 5 );
					
					absorb_texts = new Array();
					absorb_texts.push("THANK YOU!");
					absorb_texts.push("ONLY ONE FRIEND LEFT");
					
					var boss_entry:Object = world_map.createNewPritMapEntry( 
					{prit_type:CellPrit.c_type_boss, 
					absorb_texts:absorb_texts, 
					absorb_text_type:CellTextHandler.c_text_type_normal,
					absorb_text_repeat:false} );
					
					world_map.addNewPrit_RandomLocation( {prit_type:CellPrit.c_type_energyball, max_energy:20, replace_entry:boss_entry}, false, 1 );
					world_map.addNewPrit_RandomLocation( 
					{prit_type:CellPrit.c_type_boss, 
					is_special:true, 
					special_type:CellBackground.c_special_type_light}
					, false, 1);
					
					break;
				case 2:
					prit_set.push( {prit_type:CellPrit.c_type_fish, level:0, percent:0.22} );
					prit_set.push( {prit_type:CellPrit.c_type_fish, level:1, percent:0.13} );
					prit_set.push( {prit_type:CellPrit.c_type_fish, level:2, percent:0.05} );
					prit_set.push( {prit_type:CellPrit.c_type_white, percent:0.05} );
					prit_set.push( {prit_type:CellPrit.c_type_attack, percent:0.25} );
					prit_set.push( {prit_type:CellPrit.c_type_worm, percent:0.30} );
					
					enemy_set.push( {level:1, energy:9} );
					
					world_map.fillWithRandomPlaces(prit_set, enemy_set, true, 5, 0);
					
					world_map.addNewPrit_RandomLocation( {prit_type:CellPrit.c_type_fish, level:2}, true, 5 );
					
					area_texts = new Array();
					area_texts.push("FEED ME\nA RAINDBOW FISH...");
					area_texts.push("AND I'LL GIVE YOU\nSOMETHING SPECIAL");
					
					world_map.addNewEnemy(3, 3, new Point(100, 100), 
					{level:1, 
					energy:3, 
					is_special:true, 
					special_type:CellBackground.c_special_type_light}, 
					{type:GridObject.c_type_area, 
					area_type:CellArea.c_type_textdisplay,
					radius:100,
					area_texts:area_texts,
					area_text_type:CellTextHandler.c_text_type_normal,
					area_text_reapeat:false});
					
					world_map.addNewPrit_RandomLocation( 
					{prit_type:CellPrit.c_type_boss, 
					is_special:true, 
					special_type:CellBackground.c_special_type_light}
					, false, 1);
					
					break;
					
				case 3:
					prit_set.push( {prit_type:CellPrit.c_type_default, percent:0.80} );
					prit_set.push( {prit_type:CellPrit.c_type_heavy, percent:0.20} );
					prit_set.push( {prit_type:CellPrit.c_type_attack, percent:0.25} );
					
					enemy_set.push( {level:0, energy:0} );
					
					world_map.fillWithRandomPlaces(prit_set, enemy_set, true, 10, 40);
					
					break;
			}
			
			return world_map;
			
		}
		
		public static function createWorldMap(grid:CellGridDisplay, cell_player:CellSingle_Player, level:int):CellWorldMap {
			var world_map:CellWorldMap = null;
			switch(level) {
				case 0:
				default:
					world_map = fillWorldMap( new CellWorldMap(level, 5, 5, 0, 0, cell_player, CellBackground.c_background_normal), grid);
					break;
				case 1:
					world_map = fillWorldMap( new CellWorldMap(level, 3, 3, 0, 0, cell_player, CellBackground.c_background_trees), grid);
					break;
				case 2:
					world_map = fillWorldMap( new CellWorldMap(level, 4, 4, 0, 0, cell_player, CellBackground.c_background_bubbles), grid);
					break;
				case 3:
					world_map = fillWorldMap( new CellWorldMap(level, 5, 5, 0, 0, cell_player, CellBackground.c_background_fire), grid);
					break;
			}
			return world_map;
		}
		
	}
}