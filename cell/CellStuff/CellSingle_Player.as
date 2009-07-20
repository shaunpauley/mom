package CellStuff {
	
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.geom.Point;
	
	import fl.transitions.Tween;
	
	public class CellSingle_Player extends CellSingle {
		
		public var SelectedProt:int;
		public var SelectedRing:int;
		
		public var TargetRing:int;
		public var TargetRingRotation:Number;
		public var TargetProtRotation:Number;
		public var TargetAngle:Number;
		
		public var isRotatingRing:Boolean;
		public var isProtSelected:Boolean;
		
		public var cancelMouseClick:Boolean;
		
		public var DraggingSprite:MovieClip;
		public var RingSelect:Sprite;
		public var RingSelectSpeed:Number;
		public var LastRotationSpeed:Number;
		
		public static const c_command_type_none:uint					= 0x000000;
		public static const c_command_type_special_text_display:uint	= 0x000001;
		public static const c_command_type_text_display:uint			= 0x000002;
		
		public static const c_prit_status_radius:Number 	= 13;
		
		public function CellSingle_Player(grid:CellGridDisplay, map_entry:Object) {
			
			hitArea = new Sprite();
			addChild(hitArea);
			
			super(grid, map_entry);
			
			// cell status
			myCellStatus = new Object();
			myCellStatus.rollups = new Array();
			
			myCellStatus.sprite = new Sprite();
			myCellStatus.sprite.x = 20;
			myCellStatus.sprite.y = 20;
			
			myCellStatus.cell = new Sprite();
			
			myCellStatus.cell_socket = new Sprite();
			myCellStatus.cell_socket.addChild(myCellStatus.cell);
			
			myCellStatus.prits = new Array();
			myCellStatus.prit_stores = Nucleus.myPritStores;
			myCellStatus.prit_lights = new Array();
			myCellStatus.prits_socket = new Sprite();
			
			updateCellStatus();
			
			myCellStatus.nucleus = Nucleus.addNewNucleus();
			myCellStatus.cell.addChild(myCellStatus.nucleus);
			
			myCellStatus.face_object = addNewFaceObject(false);
			myCellStatus.cell.addChild(myCellStatus.face_object.eyes);
			myCellStatus.cell.addChild(myCellStatus.face_object.face);
			
			myCellStatus.sprite.addChild(myCellStatus.cell_socket);
			myCellStatus.sprite.addChild(myCellStatus.prits_socket);
			
			myCellStatus.health = new Object();
			myCellStatus.health.phys_health = new PhysNumberRollup();
			myCellStatus.health.phys_health.x = - 20;
			myCellStatus.health.phys_health.y = 20;
			myCellStatus.health.phys_health.gotoAndStop(1);
			myCellStatus.health.textBox = myCellStatus.health.phys_health.textBox;
			myCellStatus.health.textBox.blendMode = BlendMode.LAYER;
			myCellStatus.health.textBox.alpha = 0.40;
			myCellStatus.cell_socket.addChild(myCellStatus.health.phys_health);
			
			updateHealthStatus();
			
			updatePritStatus();
			
			// selecting
			Selected = false;
			
			SelectedProt = -1;
			SelectedRing = -1;
			
			TargetRing = -1;
			TargetRingRotation = 0;
			TargetProtRotation = 0;
			TargetAngle = 0;
			
			isRotatingRing = false;
			isProtSelected = false;
			
			cancelMouseClick = false;
			
			DraggingSprite = null;
			RingSelect = null
			RingSelectSpeed = 0;
			LastRotationSpeed = 0;
			
			// mouse
			mouseEnabled = true;
			mouseChildren = true;
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler_Ring);
			
		}
		
		public function updateCellStatus():void {
			myCellStatus.cell_socket.x = stats_radius;
			myCellStatus.cell_socket.y = stats_radius;
			myCellStatus.cell.scaleX = 27 / stats_radius;
			myCellStatus.cell.scaleY = 27 / stats_radius;
			myCellStatus.cell.alpha = 0.35;
			
			myCellStatus.prits_socket.x = stats_radius*2 + c_prit_status_radius + 20;
			myCellStatus.prits_socket.y = stats_radius;
			
			
			var i:int = myCellStatus.prits.length-1;
			for each (var prit:Sprite in myCellStatus.prits) {
				prit.x = i * (c_prit_status_radius*2 + 7);
				prit.y = 0;
				--i;
			}
		}
		
		public function updatePritStatus():void {
			for each (var prit_light in myCellStatus.prit_lights) {
				prit_light.visible = false;
			}
			
			var prot_crit:Object = Nucleus.myProtCriteria;
			if (prot_crit.is_complete) {
				for each (var i:int in prot_crit.prits) {
					myCellStatus.prit_lights[i].visible = true;
					myCellStatus.prit_lights[i].alpha = 0.4;
				}
			} else if (prot_crit.num_complete > 1) {
				for each (i in prot_crit.prits) {
					myCellStatus.prit_lights[i].visible = true;
					myCellStatus.prit_lights[i].alpha = 0.2;
				}
			}
		}
		
		public override function addPrit(prit:CellPrit, pos:int = 0):void {
			var phys_prit:MovieClip = prit.addNewPhysicalPrit();
			phys_prit.scaleX = c_prit_status_radius / prit.m_radius;
			phys_prit.scaleY = c_prit_status_radius / prit.m_radius;
			phys_prit.alpha = 0.35;
			
			var prit_light:PhysLights = new PhysLights();
			prit_light.gotoAndStop(1);
			prit_light.blendMode = BlendMode.ADD;
			prit_light.alpha = 0.0;
			prit_light.scaleX = c_prit_status_radius * 1.5 / 18;
			prit_light.scaleY = c_prit_status_radius * 1.5 / 18;
			prit_light.visible = false;
			
			var phys_prit_socket:Sprite = new Sprite();
			phys_prit_socket.addChild(phys_prit);
			phys_prit_socket.addChild(prit_light);
			
			myCellStatus.prits_socket.addChild(phys_prit_socket);
			myCellStatus.prits.splice(pos, 0, phys_prit_socket);
			myCellStatus.prit_lights.splice(pos, 0, prit_light);
			
			// update locations
			updateCellStatus();
			updatePritStatus();
		}
		
		public override function removePrit(i:int):void {
			var phys_prit_socket:Sprite = myCellStatus.prits[i];
			myCellStatus.prits_socket.removeChild(phys_prit_socket);
			myCellStatus.prits.splice(i, 1);
			myCellStatus.prit_lights.splice(i, 1);
			
			// update locations
			updateCellStatus();
			updatePritStatus();
		}
		
		public function updateHealthStatus():void {
			var health:int = Nucleus.m_energy + 1;
			var max_health:int = Nucleus.m_max_energy + 1
			var text_format:TextFormat = myCellStatus.health.textBox.defaultTextFormat;
			
			var health_ratio:Number = health / max_health;
			if (health_ratio >= 0.30) {
				text_format.color = 0x26732E;
				text_format.size = 30;
				
			} else {
				text_format.color = 0x733D26;
				text_format.size = 35;
				
			}
			myCellStatus.health.textBox.defaultTextFormat = text_format;
			
			myCellStatus.health.textBox.text = String(health) + " / " + String(max_health);
		}
		
		public override function addRing(draw_ring:Boolean = true):void {
			super.addRing(draw_ring);
			updateHitArea(MyRings.length);
		}
		
		public function updateHitArea(rings:int):void {
			var pos:Number = getRingLengthFromPosition(rings) - (c_ring_radius_inc/2);
			
			hitArea.graphics.clear();
			hitArea.graphics.beginFill(0xFFCCFF, 1);
			hitArea.graphics.drawCircle(0, 0, pos);
			hitArea.graphics.endFill();
			hitArea.visible = false;
			hitArea.mouseEnabled = false;
			hitArea.mouseChildren = false;
		}
		
		public function updateRingRotation():void {
			if ( isRotatingRing && (Math.abs(RingSelectSpeed) > Number.MIN_VALUE) ) {
				var rotation_distance:Number = rotationDistanceSigned(RingSelect.rotation, TargetRingRotation);
				var sign:int = rotation_distance<0?-1:1;
				if (Math.abs(rotation_distance) < Math.abs(RingSelectSpeed)) {
					RingSelectSpeed = rotation_distance * -1;
				}
				RingSelect.rotation += RingSelectSpeed;
				
				rotation_distance = rotationDistanceSigned(RingSelect.rotation, TargetRingRotation);
				if ( (sign != (rotation_distance<0?-1:1)) || (Math.abs(rotation_distance) < Number.MIN_VALUE) ) {
					RingSelectSpeed = 0;
				}
			}
		}
		
		public override function addProt(ring:int, angle:Number, prot:CellProt):void {
			prot.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler_Prot);
			prot.addEventListener(MouseEvent.CLICK, mouseClickHandler_Prot);
			
			super.addProt(ring, angle, prot);
			
			if (prot.m_type == CellProt.c_type_cat) {
				faceState = c_face_happy;
				updateFaces();
				
				CellWorld.myBackground.exchangeSounds(0, new PhysBGSound_Cat());
			}
		}
		
		public override function removeProt(prot:CellProt):void {
			// remove Handlers
			prot.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler_Prot);
			prot.removeEventListener(MouseEvent.CLICK, mouseClickHandler_Prot);
			
			super.removeProt(prot);
		}
		
		public override function increaseEnergy(energy:int):int {
			var de:int = super.increaseEnergy(energy);
			updateHealthStatus();
			return de;
			
		}
		
		public override function decreaseEnergy(energy:int):int {
			var de:int = super.decreaseEnergy(energy);
			updateHealthStatus();
			return de;
			
		}
		
		public override function die():void {
			CellWorld.isDeathReset = true;
		}
		
		
		// selecting stuff
		public function rotationDistance(a:Number, b:Number):Number {
			return Math.abs(rotationDistanceSigned(a, b));
		}
		
		// note: we might to need to handle something for the shortest or closest rotation distance
		public function rotationDistanceSigned(a:Number, b:Number):Number {
			var v1:Number = a - b;
			if (v1 == 0) {
				return 0;
			}
			var sign:int = v1<0?-1:1;
			var v2:Number = v1 - sign*360;
			if (Math.abs(v2) < Math.abs(v1)) {
				return v2;
			}
			return v1;
		}
		
		/* Mouse Handlers */
		public function mouseClickHandler_Prot(event:MouseEvent):void {
			if (!cancelMouseClick) {
				var prot:CellProt = getProt(SelectedRing, SelectedProt);
				
				prot.switchAble();
				
				if (prot.m_state == CellProt.c_state_disable) {
					var prits:Array = prot.releasePrits();
					while(prits.length > 0) {
						var prit:CellPrit = prits.pop();
						if (absorbState == c_absorb) {
							Nucleus.absorbPrit(prit);
						} else {
							/*
							prit.reset();
							var local_point:Point = prot.myGridObject.getLocalPoint().add( new Point(Math.random()*2.0-1.0, Math.random()*2.0-1.0) );
							var grid_handler:Object = myGrid.getGridFromObject(prot.myGridObject);
							var prit_grid_object:GridObject = CellCreator.CreateGridObjectLocal_CellPrit_New(myGrid, grid_handler, local_point, prit);
							*/
						}
					}
				}
				
			}
		}
		
		public function mouseDownHandler_Ring(event:MouseEvent):void {
			if (isProtSelected) {
				return;
			}
			
			// first determine if we are actually dragging a ring
			var local_cell_point:Point = globalToLocal(new Point(event.stageX, event.stageY));
			SelectedRing = getRingPositionFromLength(local_cell_point.length);
			
			if ( !isRingOutside(SelectedRing) && !isRingInsideNucleus(SelectedRing) ) {
				isRotatingRing = true;
				
				// create our dragging sprite
				DraggingSprite = new PhysRingSelect();
				DraggingSprite.gotoAndStop(c_frame_normal);
				DraggingSprite.x = local_cell_point.x;
				DraggingSprite.y = local_cell_point.y;
				DraggingSprite.alpha = 0.4;
				DraggingSprite.mouseEnabled = false;
				DraggingSprite.mouseChildren = false;
				
				addChild(DraggingSprite);
				
				// add another physringselect to the exact rotation point on the ring
				// 1) get current angle
				// 2) add a physringselect to the angle
				var mouse_rotation:Number = Math.atan2(local_cell_point.y, local_cell_point.x) * 180/Math.PI - 90;
				
				var ring_select_focal:PhysRingSelect = new PhysRingSelect();
				ring_select_focal.y = getRingLengthFromPosition(SelectedRing);
				ring_select_focal.gotoAndStop(c_frame_normal);
				
				RingSelect = new Sprite();
				RingSelect.addChild(ring_select_focal);
				RingSelect.rotation = mouse_rotation;
				
				var ring_handler:Object = getRing(SelectedRing);
				ring_handler.ring_pos.addChild(RingSelect);
				
				RingSelectSpeed = 0;
				TargetRingRotation = 0;
				
				// setup handling mouse actions
				CellWorld.newMouseMoveHandler(this, mouseMoveHandler_Ring);
				CellWorld.myStage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler_Ring);
				
				updateRingDragging(local_cell_point);
			}
		}
		
		public function mouseDownHandler_Prot(event:MouseEvent):void {
			// we need to create a ghost sprite that will be transparent to simulate a prot move
			// we need to use globalToLocal here to grab local mouse coords
			var local_cell_point:Point = globalToLocal(new Point(event.stageX, event.stageY));
			var mouse_rotation:Number = Math.atan2(local_cell_point.y, local_cell_point.x) * 180/Math.PI - 90;
			
			isProtSelected = true;
			cancelMouseClick = false;
			
			DraggingSprite = new PhysGhostProt();
			DraggingSprite.gotoAndStop(c_frame_normal);
			DraggingSprite.alpha = 0.4;
			DraggingSprite.mouseChildren = false;
			addChild(DraggingSprite);
			
			CellWorld.newMouseMoveHandler(this, mouseMoveHandler_Prot);
			CellWorld.myStage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler_Prot);
			
			// record our selectedring and selectedprot so that we can simulate rotation
			var prot:CellProt = CellProt(event.currentTarget);
			SelectedProt = prot.pos;
			SelectedRing = prot.m_ring;
			
			// state
			prot.m_is_dragging = true;
			prot.myGridObject.moveStop();
			
			TargetRing = SelectedRing;
			
			// call our event to handle when the mouse is off of the centre of the prot a little bit when clicking on it
			updateProtDragging(local_cell_point);
			
		}
		
		public function mouseUpHandler_Ring(event:MouseEvent):void {
			removeChild(DraggingSprite);
			var ring_handler:Object = getRing(SelectedRing);
			ring_handler.ring_pos.removeChild(RingSelect);
			
			// simulate rotating the ring by rotating prots
			for (var p:int = 0; p < getRingSize(SelectedRing); ++p) {
				var prot:CellProt = getProt(SelectedRing, p);
				prot.myGridObject.moveStop();
			}
			
			SelectedRing = 0;
			RingSelect = null;
			TargetRingRotation = 0;
			isRotatingRing = false;
			
			CellWorld.removeMouseMoveHandler();
			CellWorld.myStage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler_Ring);
		}
		
		public function mouseUpHandler_Prot(event:MouseEvent):void {
			// we want to remove the ghost prot and event listeners
			removeChild(DraggingSprite);
			CellWorld.removeMouseMoveHandler();
			CellWorld.myStage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler_Prot);
			
			isProtSelected = false;
			
			var prot:CellProt = getProt(SelectedRing, SelectedProt);
			
			// we update the dragging prot and move the prot if we can
			var local_cell_point:Point = new Point(event.stageX, event.stageY);
			if ( updateProtDragging(local_cell_point) ) {
				moveProt(SelectedRing, SelectedProt, TargetRing, TargetAngle);
			} else {
				prot.myGridObject.moveStop();
			}
			
			// reset the rings state
			TargetProtRotation = 0;
			TargetRing = -1;
			TargetAngle = 0;
			
			prot.m_is_dragging = false;
		}
		
		public function mouseMoveHandler_Ring(stageX, stageY):void {
			var local_cell_point:Point = globalToLocal(new Point(stageX, stageY));
			updateRingDragging(local_cell_point);
		}
		
		public function mouseMoveHandler_Prot(stageX, stageY):void {
			cancelMouseClick = true;
			// we want to setup the rotations for the ghost prot and
			// at the same time, rotate the actual ring
			var local_cell_point:Point = globalToLocal(new Point(stageX, stageY));
			updateProtDragging(local_cell_point);
		}
		
		public function updateRingDragging(local_cell_point:Point):void {
			DraggingSprite.x = local_cell_point.x;
			DraggingSprite.y = local_cell_point.y;
			
			var mouse_rotation:Number = Math.atan2(local_cell_point.y, local_cell_point.x) * 180/Math.PI - 90;
			var rotation_distance:Number = rotationDistanceSigned(mouse_rotation, RingSelect.rotation);
			
			var sign:int = rotation_distance<0?-1:1;
			RingSelectSpeed = c_max_prot_speed * sign;
			TargetRingRotation = mouse_rotation;
			
			CellWorld.rotateRing(this, SelectedRing, RingSelectSpeed);
		}
		
		// updates the dragging state and returns whether the prot can be dropped
		public function updateProtDragging(local_cell_point:Point):Boolean {
			// we want to setup the rotations for the ghost prot and
			// at the same time, rotate the actual ring
			
			DraggingSprite.x = local_cell_point.x;
			DraggingSprite.y = local_cell_point.y;
			
			var mouse_rotation:Number = Math.atan2(local_cell_point.y, local_cell_point.x) * 180/Math.PI - 90;
			DraggingSprite.rotation = mouse_rotation;
			TargetProtRotation = mouse_rotation;
			
			var prot:CellProt = getProt(SelectedRing, SelectedProt);
			
			var rotation_distance:Number = rotationDistanceSigned( TargetProtRotation, prot.myGridObject.getRotation() );
			var sign:int = rotation_distance<0?-1:1;
			
			// check if we drag too far
			TargetRing = getRingPositionFromLength(local_cell_point.length);
			if (TargetRing > MyRings.length) {
				TargetRing = MyRings.length;
			}
			
			var in_range:Boolean = false;
			if (Math.abs(rotation_distance) <= c_max_ring_speed) {
				in_range = true;
			}
			
			// we want to be able to drag everywhere, but only show an X prot depending on the target
			// 1st get target local insert angle:
			TargetAngle = 0;
			if ( (TargetRing > 0) && (TargetRing < MyRings.length) ) {
				TargetAngle = mouse_rotation;
			}
			
			// set a rotation
			prot.myGridObject.rotate(c_max_prot_speed * sign, true, TargetProtRotation);
			
			// check if we are dragging over an object
			var world_point:Point = calculatePointOnRing(TargetRing, TargetAngle).add( myGrid.getWorldFromObject(myGridObject) );
			var object_under:Boolean = !myGrid.canMoveToWorldWithoutCollision(prot.myGridObject, world_point);
			return draggingCanDrop(TargetRing, SelectedRing, in_range, TargetAngle, object_under);
		}
		
		// note angle is local to target_ring
		public function draggingCanDrop(target_ring:int, selected_ring:int, in_range:Boolean, angle:Number, object_under:Boolean):Boolean {
			var rval:Boolean = !object_under && canDrop(target_ring, selected_ring, in_range, angle);
			if (rval) {
				DraggingSprite.gotoAndStop(c_frame_normal);
			} else {
				DraggingSprite.gotoAndStop(c_frame_xprot);
			}
			
			return rval;
		}
		
		public function canDrop(target_ring:int, selected_ring:int, in_range:Boolean, angle:Number):Boolean {
			return ( ( in_range || ((target_ring == 0) && (getRingSize(0) == 0)) || (selected_ring == 0) ) && 
					( !isRingOutside(target_ring) || (selected_ring == MyRings.length-1) ) &&
					(selected_ring != target_ring) );
		}
		
		public override function levelUp():void {
			super.levelUp();
			// todo: display rollup
			
			// update Cell Status
			updateCellStatus();
			updateHealthStatus();
		}
		
		public override function absorbedPrit(prit:CellPrit):void {
			CellWorld.mySoundList[prit.m_sound_absorb].play();
			
			// update Cell Status Prits
		}
		
		public override function checkGridUnder(grid_handler:Object):void {
			if (!Nucleus.m_is_dead) {
				CellWorld.changeBackground(grid_handler.background);
			} else {
				CellWorld.changeBackground(CellBackground.c_background_gold);
			}
		}
		
		/* Map Entry */
		public override function resetFromMapEntry(map_entry:Object):void {
			super.resetFromMapEntry(map_entry);
			
			// selecting
			Selected = false;
			
			SelectedProt = -1;
			SelectedRing = -1;
			
			TargetRing = -1;
			TargetRingRotation = 0;
			TargetProtRotation = 0;
			TargetAngle = 0;
			
			isRotatingRing = false;
			isProtSelected = false;
			
			cancelMouseClick = false;
			
			DraggingSprite = null;
			RingSelect = null;
			RingSelectSpeed = 0;
			LastRotationSpeed = 0;
			
			// mouse
			mouseEnabled = true;
			mouseChildren = true;
			
			// update statuses
			updateCellStatus();
			updateHealthStatus();
			updatePritStatus();
		}
		
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			return map_entry;
		}
		
		public static function updateMapEntry_NewLevel(map_entry:Object, level:int):Object {
			map_entry = CellSingle.updateMapEntry_NewLevel(map_entry, level);
			
			map_entry.is_player = true;
			
			return map_entry;
		}
	}
}