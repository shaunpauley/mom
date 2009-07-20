package CellStuff {
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.display.Sprite;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;

	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import flash.geom.Point;	
	
	import flash.filters.ColorMatrixFilter;
	
	public class CellNucleus extends MovieClip{
		
		public var myGrid:CellGridDisplay;
		
		public var myCell:CellSingle;
		
		public var myNuclei:Array;
		public var myNucleus:PhysNucleus;
		
		public var myPritStores:Object;
		
		public var myProtCriteria:Object;
		
		public var m_max_prits:int;
		public var m_num_unconsumables:int;
		public var m_energy:int;
		public var m_max_energy:int;
		
		public var m_prit_radius:Number;
		public var m_stores_radius:Number;
		public var m_prit_rotation_size:Number;
		public var m_current_socket_rotation:Number;
		
		public var m_nucleus_level:int;
		
		public var m_is_dead:Boolean;
		
		public static const c_working_view:uint		= 0x000001;
		public static const c_outside_view:uint		= 0x000000;
		
		public static const c_absorb:uint		= 0x000001;
		public static const c_repel:uint		= 0x000002;
		
		
		public var DebugText:TextField;
		
		public function CellNucleus(grid:CellGridDisplay, cell:CellSingle, map_entry:Object) {
			myGrid = grid;
			
			myCell = cell;
			
			myProtCriteria = {};
			
			// map entries
			m_max_prits = map_entry.max_prit_stores;
			m_num_unconsumables = map_entry.num_unconsumables;
			m_energy = map_entry.energy;
			m_max_energy = map_entry.max_energy;
			
			m_prit_radius = map_entry.prit_radius;
			m_stores_radius = map_entry.stores_radius;
			m_prit_rotation_size = map_entry.prit_rotation_size;
			m_current_socket_rotation = map_entry.current_socket_rotation;
			
			m_nucleus_level = map_entry.nucleus_level;
			
			m_is_dead = false;
			
			// nucleus
			myNuclei = new Array();
			
			myNucleus = addNewNucleus();
			addChild(myNucleus);
			
			mouseEnabled = false;
			mouseChildren = false;
			
			// update energy
			updateNucleusEnergy();
			
			// state
			if (myCell.absorbState == CellSingle.c_absorb) {
				absorb();
			} else {
				repel();
			}
			
			// prit stores
			myPritStores = new Object();
			myPritStores.stores = new Array();
			myPritStores.prits = new Array();
			var prit_sprite:Sprite = new Sprite();
			prit_sprite.x = 0;
			prit_sprite.y = 0;
			addChild(prit_sprite);
			myPritStores.sprite = prit_sprite;
			
			// debug text
			DebugText = new TextField();
			DebugText.x = 50;
			DebugText.y = 50;
			DebugText.autoSize = TextFieldAutoSize.LEFT;
			var Format:TextFormat = new TextFormat();
			Format.font = "Courier New";
			Format.color = 0x441111;
			Format.size = 10;
			DebugText.defaultTextFormat = Format;
			DebugText.selectable = false;
			DebugText.text = "0";
			if (CellWorld.c_debug) {
				addChild(DebugText);
			}
		}
		
		public function addNewNucleus():PhysNucleus {
			var new_nucleus:PhysNucleus = new PhysNucleus();
			var new_filters:Array = new Array();
			new_filters.push( new ColorMatrixFilter( createIdentityMatrix() ) );
			new_nucleus.filters = new_filters;
			new_nucleus.gotoAndStop("repel_level" + m_nucleus_level);
			
			myNuclei.push(new_nucleus);
			
			return new_nucleus;
		}
		
		public function consumeAll():void {
			var all_prits:Array = myPritStores.prits;
			
			var remove_prits:Array = new Array();
			if (myProtCriteria.is_complete) {
				var prit_map_entries:Array = new Array();
				while(myProtCriteria.prits.length > 0) {
					var prit_index:int = myProtCriteria.prits.pop();
					var prit:CellPrit = all_prits[prit_index];
					remove_prits.push(prit_index);
					
					// create map entry
					prit_map_entries.push( prit.updateMapEntry( new Object() ) );
				}
				
				var prot:CellProt = CellCreator.CreateProt( myGrid, CellCreator.CreateProtMapEntry(myProtCriteria.type, prit_map_entries, new Array()) );
				
				prot.myGridObject = CellCreator.CreateGridObjectFromNewProt_CellSingle(myGrid, myCell.myGridObject, prot);
				prot.myGridObject.sprite.addChild(prot);
				
				if (prot.isEnabled()) {
					prot.enable();
				} else {
					prot.disable();
				}
				
				myCell.addProt(1, myCell.calculateNewBalancedAngleOnRing(1), prot);
				
				// remove remaining prits
				remove_prits.sort();
				while(remove_prits.length > 0) {
					removePritIndex( remove_prits.pop() );
				}
				
			}
			
			// try to consume rest
			for (var i:int = 0; i < all_prits.length; ++i) {
				if ( consumePrit(all_prits[i]) ) {
					remove_prits.push(i);
				}
			}
			
			// remove remaining prits
			remove_prits.sort();
			while (remove_prits.length > 0) {
				removePritIndex( remove_prits.pop() );
			}
			
		}
		
		public function breakupProt(prot:CellProt) {
			// we absorb held prits first
			var held_prits:Array = prot.releasePrits();
			while (held_prits.length > 0) {
				absorbPrit(held_prits.pop());
			}
			
			while (prot.myConstructedPrits.length > 0) {
				// create each prot
				absorbPrit( CellCreator.CreatePrit(myGrid, prot.myConstructedPrits.pop()) );
			}
		}
		
		public function getNewRotationToAddPrit():Number {
			m_current_socket_rotation += m_prit_rotation_size;
			return m_current_socket_rotation;
		}
		
		public function updateNuclei(state:uint):void {
			for each (var nucleus:PhysNucleus in myNuclei) {
				updateNucleus(nucleus, state);
			}
		}
		
		public function updateNucleus(nucleus:PhysNucleus, state:uint):void {
			switch (state) {
				case c_absorb:
					if (myCell.faceState == CellSingle.c_face_squid) {
						nucleus.gotoAndStop("squid_absorb_level" + m_nucleus_level);
						
					} else {
						nucleus.gotoAndStop("absorb_level" + m_nucleus_level);
						
					}
					break;
				case c_repel:
				default:
					if (myCell.faceState == CellSingle.c_face_squid) {
						nucleus.gotoAndStop("squid_repel_level" + m_nucleus_level);
						
					} else if (myCell.faceState == CellSingle.c_face_sad) {
						nucleus.gotoAndStop("sick_level" + m_nucleus_level);
						
					} else {
						nucleus.gotoAndStop("repel_level" + m_nucleus_level);
						
					}
					break;
					
			}
		}
		
		public function absorb():void {
			updateNuclei(c_absorb);
		}
		
		public function repel():void {
			updateNuclei(c_repel);
		}
		
		public function enable():void {
			repel();
			consumeAll();
		}
		
		public function disable():void {
			absorb();
		}
		
		public function canAbsorbPrit():Boolean {
			return myCell.absorbState == CellSingle.c_absorb;
		}
		
		public function absorbPrit(p:CellPrit):void {
			addToPritStores(p);
			myCell.absorbedPrit(p);
		}
		
		public function removePrit(p:CellPrit):void {
			var i:int = myPritStores.prits.indexOf(p);
			if (i > -1) {
				removePritIndex(i);
			}
		}
		
		public function removePritIndex(i:int):void {
			var prit_handler:Object = myPritStores.stores[i];
			var prit:CellPrit = prit_handler.prit;
			
			myPritStores.sprite.removeChild(prit_handler.socket);
			
			prit.x = 0;
			prit.y = 0;
			prit.myPrit.scaleX = 1;
			prit.myPrit.scaleY = 1;
			prit.alpha = 1.0;
			
			if (!prit.canBeConsumed()) {
				m_num_unconsumables--;
			}
			
			if (prit_handler.socket.rotation == m_current_socket_rotation) {
				if (i < myPritStores.stores.length-1) {
					m_current_socket_rotation = myPritStores.stores[i+1].socket.rotation;
				} else {
					m_current_socket_rotation = 0.0;
				}
			}
			
			// remove from arrays
			myPritStores.stores.splice(i, 1);
			myPritStores.prits.splice(i, 1);
			
			// update prot crit
			myProtCriteria = CellCreator.getProtCriteriaFromPrits(myPritStores.prits);
			
			// call on the cell removes
			myCell.removePrit(i);
			
		}
		
		
		// eat a prit
		public function consumePrit(prit:CellPrit):Boolean {
			if ( prit.canBeConsumed() ) {
				
				if (prit.m_energy > 0) {
					myCell.myGridObject.increaseEnergy(prit.m_energy);
				}
				
				return true;
			}
			
			return false;
		}
		
		public function consumeNextPrit():void {
			var found_next:Boolean = false;
			for (var i:int = myPritStores.prits.length - 1; i >= 0; --i) {
				if ( consumePrit(myPritStores.prits[i]) ) {
					removePritIndex(i);
					break;
				}
			}
		}
		
		public function increaseEnergy(energy:int):int {
			var energy_before:int = m_energy;
			m_energy += energy;
			if (m_energy > m_max_energy) {
				m_energy = m_max_energy;
			}
			updateNucleusEnergy();
			
			return int(m_energy - energy_before);
		}
		
		public function decreaseEnergy(energy:int):int {
			var energy_before:int = m_energy;
			m_energy -= energy;
			if (m_energy < -1) {
				m_energy = -1;
				m_is_dead = true;
			}
			updateNucleusEnergy();
			
			return int(energy_before - m_energy);
		}
		
		public function addToPritStores(p:CellPrit):void {
			
			// make new prit and add it
			var new_prit_socket:Sprite = new Sprite();
			new_prit_socket.rotation = getNewRotationToAddPrit();
			new_prit_socket.addChild(p);
			
			// reset our stats
			p.x = 0;
			p.y = m_stores_radius;
			p.myPrit.scaleX = m_prit_radius / p.m_radius;
			p.myPrit.scaleY = m_prit_radius / p.m_radius;
			p.alpha = 0.70;
			
			var new_prit_handler:Object = new Object();
			new_prit_handler.prit = p;
			new_prit_handler.socket = new_prit_socket;
			
			myPritStores.sprite.addChild(new_prit_socket);
			
			if (p.canBeConsumed()) {
				myPritStores.stores.splice(m_num_unconsumables, 0, new_prit_handler);
				myPritStores.prits.splice(m_num_unconsumables, 0, p);
				
				// update prot crit
				myProtCriteria = CellCreator.getProtCriteriaFromPrits(myPritStores.prits);
				
				myCell.addPrit(p, m_num_unconsumables);
			} else {
				myPritStores.stores.unshift(new_prit_handler);
				myPritStores.prits.unshift(p);
				
				// update prot crit
				myProtCriteria = CellCreator.getProtCriteriaFromPrits(myPritStores.prits);
				
				myCell.addPrit(p);
				m_num_unconsumables++;
			}
			
			
			
			// remove over prit
			if (myPritStores.stores.length > numMaxStores()) {
				consumeNextPrit();
			}
		}
		
		public function numMaxStores():int {
			return m_max_prits + m_num_unconsumables;
		}
		
		/* Energy Shown*/
		public function updateNucleusEnergy():void {
			for each (var nucleus:PhysNucleus in myNuclei) {
				var new_filters:Array = nucleus.filters;
				var color_filter:ColorMatrixFilter = new_filters[0];
				color_filter.matrix = updateColorMatrix( color_filter.matrix, (m_max_energy == 0)?0:(m_energy/m_max_energy) );
				new_filters[0] = color_filter;
				nucleus.filters = new_filters;
			}
		}
		
		public function createIdentityMatrix():Array {
			var matrix:Array = new Array();
			
			matrix = matrix.concat([1, 0, 0, 0, 0]);  // red
			matrix = matrix.concat([0, 1, 0, 0, 0]);  // green
			matrix = matrix.concat([0, 0, 1, 0, 0]);  // blue
			matrix = matrix.concat([0, 0, 0, 1, 0]);  // alpha
			
			return matrix;
		}
		
		public function updateColorMatrix(matrix:Array, saturation:Number = 1.0):Array {
			var non_saturation:Number = 1.0 - saturation;
			var second:Number = non_saturation * 1/3;
			var first:Number = 1.0 - second*2;
			
			// red
			matrix[0] = first;
			matrix[1] = second;
			matrix[2]= second;
			
			// green
			matrix[5] = second;
			matrix[6] = first;
			matrix[7] = second;
			
			// blue
			matrix[10] = second;
			matrix[11] = second;
			matrix[12] = first;
			
			return matrix;
		}
		
		/* Level */
		public function updateLevel(level:int):void {
			var level_stats:Object = getLevelStats(level);
			
			m_prit_radius = level_stats.prit_radius;
			m_stores_radius = level_stats.stores_radius;
			m_prit_rotation_size = level_stats.prit_rotation_size;
			
			m_max_prits = level_stats.max_prits;
			var num_remove_prits:int = myPritStores.stores.length - numMaxStores();
			for (var i:int = 0; i < num_remove_prits; ++i) {
				consumeNextPrit();
			}
			
			m_energy = level_stats.energy;
			m_max_energy = level_stats.max_energy;
			if (m_energy > m_max_energy) {
				m_energy = m_max_energy;
			}
			updateNucleusEnergy();
			
			m_nucleus_level = level_stats.nucleus_level;
			if (myCell.absorbState == CellSingle.c_absorb) {
				absorb();
			} else if (myCell.absorbState == CellSingle.c_repel) {
				repel();
			}
		}
		
		public static function getLevelStats(level:int):Object {
			var level_stats:Object = new Object();
			switch(level) {
				case 0:
				default:
					level_stats.max_energy = 0;
					level_stats.energy = 0;
					level_stats.max_prits = 1;
					level_stats.prit_radius = 6.3;
					level_stats.stores_radius = 12.0;
					level_stats.prit_rotation_size = 60.0;
					level_stats.nucleus_level = 0;
					break;
				case 1:
					level_stats.max_energy = 9;
					level_stats.energy = 4;
					level_stats.max_prits = 2;
					level_stats.prit_radius = 6.3;
					level_stats.stores_radius = 12.0;
					level_stats.prit_rotation_size = 60.0;
					level_stats.nucleus_level = 1;
					break;
				case 2:
					level_stats.max_energy = 19;
					level_stats.energy = 9;
					level_stats.max_prits = 3;
					level_stats.prit_radius = 6.3;
					level_stats.stores_radius = 12.0;
					level_stats.prit_rotation_size = 60.0;
					level_stats.nucleus_level = 1;
					break;
				case 3:
					level_stats.max_energy = 29;
					level_stats.energy = 14;
					level_stats.max_prits = 3;
					level_stats.prit_radius = 6.3;
					level_stats.stores_radius = 16.0;
					level_stats.prit_rotation_size = 45.0;
					level_stats.nucleus_level = 2;
					break;
			}
			return level_stats;
		}
		
		/* WorldMap */
		public function resetFromMapEntry(map_entry:Object):void {
			// reset prit stores
			while (myPritStores.stores.length > 0) {
				removePritIndex(0);
			}
			
			// map entries
			m_max_prits = map_entry.max_prit_stores;
			m_energy = map_entry.energy;
			m_max_energy = map_entry.max_energy;
			
			m_prit_radius = map_entry.prit_radius;
			m_stores_radius = map_entry.stores_radius;
			m_prit_rotation_size = map_entry.prit_rotation_size;
			
			m_nucleus_level = map_entry.nucleus_level;
			
			// nucleus
			mouseEnabled = false;
			mouseChildren = false;
			
			// update energy
			updateNucleusEnergy();
			
			// state
			if (myCell.absorbState == CellSingle.c_absorb) {
				absorb();
			} else {
				repel();
			}
			
			// add prits
			for (var i:int = 0; i < map_entry.prit_stores.length; ++i) {
				addToPritStores( CellCreator.CreatePrit(myGrid, map_entry.prit_stores[i]) );
			}
			
			m_num_unconsumables = map_entry.num_unconsumables;
			m_current_socket_rotation = map_entry.current_socket_rotation;
			
			m_is_dead = false;
		}
		
		public function updateMapEntry(map_entry:Object):Object {
			map_entry.max_prit_stores = m_max_prits;
			map_entry.num_unconsumables = m_num_unconsumables;
			map_entry.energy = m_energy;
			map_entry.max_energy = m_max_energy;
			
			map_entry.prit_radius = m_prit_radius;
			map_entry.stores_radius = m_stores_radius;
			map_entry.prit_rotation_size = m_prit_rotation_size;
			map_entry.current_socket_rotation = m_current_socket_rotation;
			
			map_entry.nucleus_level = m_nucleus_level;
			
			map_entry.prit_stores = new Array();
			for (var i:int = 0; i < myPritStores.prits.length; ++i) {
				map_entry.prit_stores.push( myPritStores.prits[i].updateMapEntry(new Object()) );
			}
			
			return map_entry;
		}
		
		public static function updateMapEntry_NewLevel(map_entry:Object, level:int, energy:int = 0):Object {
			var level_stats:Object = getLevelStats(level);
			
			map_entry.max_prit_stores = level_stats.max_prits;
			map_entry.num_unconsumables = 0;
			
			map_entry.prit_radius = level_stats.prit_radius;
			map_entry.stores_radius = level_stats.stores_radius;
			map_entry.prit_rotation_size = level_stats.prit_rotation_size;
			map_entry.current_socket_rotation = 0;
			
			map_entry.energy = energy;
			map_entry.max_energy = level_stats.max_energy;
			
			map_entry.nucleus_level = level_stats.nucleus_level;
			
			return map_entry;
		}
	}
}