/*
* Copyright 2009 Shaun Pauley
* 
* As this isn't really published as of yet, I'm still figuring out licences.  
* So currently code should be used for personal use only and not for commercial use.
*/

package {
	import CellStuff.*;
	
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.BlendMode;

	import flash.geom.Point;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class CellWorld extends MovieClip {
		
		private var myGrid:CellGridDisplay;
		
		private var myLoadingScreen:PhysLoading;
		
		private var myUpdateTimer:Timer;
		
		private var myGUI:Sprite;
		
		private var myWorldDisplay:Sprite;
		
		private var myLevels:Array;
		private var currentLevel:int;
		
		private var myCell:CellSingle_Player;
		
		private var myToolTip:HelpToolTip;
		
		private var myViewer:CellGridViewer;
		
		// keyboard handling
		private var isKeyDown:Boolean;
		private var isKeyUp:Boolean;
		private var isKeyRight:Boolean;
		private var isKeyLeft:Boolean;
		
		private var isKeyZoomIn:Boolean;
		private var isKeyZoomOut:Boolean;
		
		// timer to evaluate cpu load
		private var beginTimer:uint;
		
		// death reset state
		private var m_death_reset_state:uint;
		private var m_death_reset_count:int;
		
		// static vars
		public static var myStage:Stage;
		
		public static var mySoundList:Array;
		
		public static var myRollups:Array;
		
		public static var myBackground:CellBackground;
		
		public static var myTextHandler:CellTextHandler;
		
		public static var myWorldMap:CellWorldMap;
		
		public static var isDeathReset:Boolean;
		//public static var myDeadObjects:Array;
		public static var myObjectMoves:Array;
		
		public static var myAbsorbingObjects:Array;
		public static var myMovedAttachedObjects:Array;
		public static var myAreaActions:Array;
		public static var myObjectCooldowns:Array;
		
		public static var myZoomTo:Number;
		
		public static var myTimedEvents:Array;
		
		public static var isNextWorldLevel:Boolean;
		
		// mouse handling
		public static var isHandleMouseMove:Boolean;
		public static var mouseMoveCallingObject:Object;
		
		// zoom
		public var m_zoom_to_current:Number = 1.0;
		public var m_zoom_speed:Number = 0.03;
		public var m_zoom_factor:Number = 2.0;
		
		public var m_is_zooming:Boolean = false;
		
		// constants
		
		public static const c_fps:Number = 50;
		
		// rollups
		public static const c_rollup_stop:uint = 0x000000;
		public static const c_rollup_running:uint = 0x000001;
		
		public static const c_rollup_alpha_step:Number = 0.05;
		
		public static const c_rollup_energy_full:uint 		= 0x000000;
		public static const c_rollup_energy_empty:uint 		= 0x000001;
		public static const c_rollup_energy_dead:uint 		= 0x000002;
		public static const c_rollup_energy_increase:uint 	= 0x000003;
		public static const c_rollup_energy_decrease:uint 	= 0x000004;
		
		// death reset
		public static const c_death_reset_init:uint			= 0x000000;
		public static const c_death_reset_update:uint		= 0x000001;
		public static const c_death_reset_end:uint			= 0x000002;
		
		public static const c_death_reset_count:int 		= 3000; // seconds
		
		// keys
		public static const c_key_up:uint	= 38;
		public static const c_key_down:uint = 40;
		public static const c_key_left:uint = 37;
		public static const c_key_right:uint = 39;
		
		public static const c_key_w:uint	= 87;
		public static const c_key_s:uint	= 83;
		public static const c_key_a:uint	= 65;
		public static const c_key_d:uint	= 68;
		
		public static const c_key_j:uint		= 74;
		public static const c_key_k:uint		= 75;
		public static const c_key_n:uint		= 78;
		public static const c_key_m:uint		= 77;
		public static const c_key_comma:uint	= 188;
		public static const c_key_period:uint	= 190;
		public static const c_key_slash:uint	= 191;
		
		public static const c_key_1:uint = 49;
		public static const c_key_2:uint = 50;
		
		// cell movement
		public static const m_max_speed = 8.0;
		public static const m_friction = 1.0;
		public static const m_speed_inc = 1.8;
		
		// view screen
		public static const m_view_screen_left = 200;
		public static const m_view_screen_right = 350;
		public static const m_view_screen_top = 200;
		public static const m_view_screen_bottom = 350;
		
		public static const c_min_view:Number = 1.5;
		public static const c_max_view:Number = 0.3;
		
		public static const c_cell_start_x:Number = 0; 
		public static const c_cell_start_y:Number = 0; 
		
		public static const c_attach_distance_threshold:Number = 6;
		public static const c_attach_return_accel:Number = 0.6;
		public static const c_attach_return_inc_speed:Number = 2.3;
		
		public static const c_num_prits:int = 20;
		
		public static const c_sound_default:int = 0;
		public static const c_sound_gold:int = 1;
		public static const c_sound_letter_c:int = 2;
		public static const c_sound_letter_a:int = 3;
		public static const c_sound_letter_t:int = 4;
		
		
		public var DebugText:TextField;
		
		public static const c_debug:Boolean = true;
		
		// init our cell world
		// basically, we want to create our cell and a cell grid and other things
		public function CellWorld():void {
			
			myStage = stage;
			
			// sound list
			mySoundList	= new Array();
			mySoundList.push(new PhysGloopSound());
			mySoundList.push(new PhysGoldSound());
			mySoundList.push(new PhysLetterCSound());
			mySoundList.push(new PhysLetterASound());
			mySoundList.push(new PhysLetterTSound());
			
			// top player graphics user interface
			myBackground = new CellBackground(275, 275);
			
			myWorldDisplay = new Sprite();
			myWorldDisplay.mouseEnabled = false;
			
			// GUI
			myGUI = new Sprite();
			myGUI.mouseEnabled = false;
			myGUI.mouseChildren = false;
			
			myToolTip = new HelpToolTip();
			
			m_death_reset_state = c_death_reset_init;
			m_death_reset_count = c_death_reset_count;
			
			isDeathReset = false;
			//myDeadObjects = new Array();
			myObjectMoves = new Array();
			
			myAbsorbingObjects = new Array();
			myMovedAttachedObjects = new Array();
			myAreaActions = new Array();
			myObjectCooldowns = new Array();
			
			myTimedEvents = new Array();
			
			// debug text
			DebugText = new TextField();
			DebugText.x = 0;
			DebugText.y = 0;
			DebugText.autoSize = TextFieldAutoSize.LEFT;
			var Format:TextFormat = new TextFormat();
			Format.font = "Courier New";
			Format.color = 0x441111;
			Format.size = 10;
			DebugText.defaultTextFormat = Format;
			DebugText.selectable = false;
			DebugText.text = "cellworld:";
			if (CellWorld.c_debug) {
				myGUI.addChild(DebugText);
			}
			
			// grid
			myGrid = new CellGridDisplay(myBackground);
			
			// set our world maps
			myLevels = new Array();
			currentLevel = 0;
			isNextWorldLevel = false;
			
			// cell
			var cell_map_entry:Object = CellSingle_Player.updateMapEntry_NewLevel(new Object(), 0);
			myCell = new CellSingle_Player(myGrid, cell_map_entry);
			
			myGUI.addChild(myCell.myCellStatus.sprite);
			
			// maps
			for (var l:int = 0; l < 4; ++l) {
				myLevels.push( CellWorldMap.createWorldMap(myGrid, myCell, l) );
			}
			myWorldMap = myLevels[0];
			
			myGrid.setWorldMap(myWorldMap);
			
			myWorldDisplay.addChild(myGrid);
			
			myWorldDisplay.x = 275;
			myWorldDisplay.y = 275;
			
			// zoom
			
			myZoomTo = 1;
			
			
			// Cell
				// init our cell
			myCell.x = c_cell_start_x;
			myCell.y = c_cell_start_y;
			
			myCell.stats_mass += 0.1; // just to be different than enemy cells
			
			var grid_handler:Object = myGrid.getGridFromView(new Point(c_cell_start_x, c_cell_start_y));
			
			myCell.myGridObject = myGrid.makeGridObjectLocal(c_cell_start_x, c_cell_start_y, 
			GridObject.c_type_cell, myCell.stats_radius, 
			myCell.stats_mass, myCell.stats_max_speed);
			
			myCell.myGridObject.cell = myCell;
			
			
				// add to our world
			myCell.myGridObject.sprite.addChild(myCell);
			myCell.myGridObject.move_accel = -m_friction;
			
				// add ToolTip
			myCell.addChild(myToolTip);
			
			myGrid.addToGridLocal( myCell.myGridObject, grid_handler, new Point(c_cell_start_x, c_cell_start_y) );
			
				// push other objects away if it is too close
			myGrid.handleTooClose(myCell.myGridObject);
			
			// number rollups
			myRollups = new Array();
			
			// update background
			myBackground.setGridMapCell(myGrid, myWorldMap, myCell);
			myBackground.updateSpecialObjects( myWorldMap.mySpecialObjects );
			
			
			// text handler
			myTextHandler = new CellTextHandler(myGrid, myWorldMap, myCell, 250, 250);
			myTextHandler.updateNewWorldMap_TextObjects();
			
			// mouse init
			isHandleMouseMove = false;
			mouseMoveCallingObject = null;
			
			// loading
			myLoadingScreen	= new PhysLoading();
			myLoadingScreen.x = 250;
			myLoadingScreen.y = 250;
			myLoadingScreen.gotoAndStop("loading");
			
			// add Children
			
			addChild(myBackground);
			addChild(myWorldDisplay);
			addChild(myTextHandler);
			addChild(myGUI);
			addChild(myLoadingScreen);
			
			this.root.loaderInfo.addEventListener(Event.COMPLETE, loadingComplete);
			
			if (c_debug) {
				CellGridLocations.UnitTest();
				//CellGridViewer.UnitTest(myWorldDisplay);
				myViewer = new CellGridViewer( CellGridViewer.CreateViewerData() );
				myWorldDisplay.addChild(myViewer);
			}
			
			
		}
		
		/* Loading Button */
		public function loadingComplete(event:Event):void {
			myLoadingScreen.gotoAndStop("play");
			
			mouseEnabled = true;
			mouseChildren = true;
			
			myLoadingScreen.addEventListener(MouseEvent.CLICK, mouseClickLoadingScreenPlay);
			this.root.loaderInfo.removeEventListener(Event.COMPLETE, loadingComplete);
		}
		
		public function mouseClickLoadingScreenPlay(event:MouseEvent):void {
			myLoadingScreen.removeEventListener(MouseEvent.CLICK, mouseClickLoadingScreenPlay);
			removeChild(myLoadingScreen);
			
			// keyboard init
			isKeyDown = false;
			isKeyUp = false;
			isKeyRight = false;
			isKeyLeft = false;
			isKeyZoomIn = false;
			isKeyZoomOut = false;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			// timer
			beginTimer = getTimer();
			
			// game loop
			//myUpdateTimer = new Timer(1000/c_fps);
			//myUpdateTimer.addEventListener(TimerEvent.TIMER, GameLoop, false, 0, true);
			//myUpdateTimer.start();
			stage.addEventListener(Event.ENTER_FRAME, GameLoop, false, 0, true);
		}
		
		
		/* GameLoop */
		public function GameLoop(event:Event):void {
			var frameRate:Number = 1000/(getTimer() - beginTimer);
			beginTimer = getTimer();
			var sectionTimer:uint = beginTimer;
			
			// zoom
			updateZoom();
			var zoomFR:Number = 1000/(getTimer() - sectionTimer);
			sectionTimer = getTimer();
			
			// apply movements, ie. keyboard movements
			moveCell();
			var moveCellFR:Number = 1000/(getTimer() - sectionTimer);
			sectionTimer = getTimer();
			
			// update our view
			updateView();
			var updateViewFR:Number = 1000/(getTimer() - sectionTimer);
			sectionTimer = getTimer();
			
			// cell ring rotations
			myCell.updateRingRotation();
			var cellRingRotationFR:Number = 1000/(getTimer() - sectionTimer);
			sectionTimer = getTimer();
			
			// update area actions
			updateAreaActions();
			var updateAreaActionsFR:Number = 1000/(getTimer() - sectionTimer);
			sectionTimer = getTimer();
			
			// update attached objects
			updateAttachedDistance();
			var updateAttachedDistanceFR:Number = 1000/(getTimer() - sectionTimer);
			sectionTimer = getTimer();
			
			// update timed events
			updateTimedEvents();
			var updateTimedEventsFR:Number = 1000/(getTimer() - sectionTimer);
			sectionTimer = getTimer();
			
			// update external movements
			handleObjectMoves();
			var handleObjectMovesFR:Number = 1000/(getTimer() - sectionTimer);
			sectionTimer = getTimer();
			
			// handle absorbing objects
			handleAbsorbing();
			var handleAbsorbingFR:Number = 1000/(getTimer() - sectionTimer);
			sectionTimer = getTimer();
			
			// handle mouse moves
			if (isHandleMouseMove && ((mouseMoveCallingObject.lastX != stage.mouseX) || (mouseMoveCallingObject.lastY != stage.mouseY)) ) {
				mouseMoveCallingObject.lastX = stage.mouseX;
				mouseMoveCallingObject.lastY = stage.mouseY;
				mouseMoveCallingObject.callback.call(mouseMoveCallingObject.object, stage.mouseX, stage.mouseY);
			}
			
			// update background
			updateBackground();
			var updateBackgroundFR:Number = 1000/(getTimer() - sectionTimer);
			sectionTimer = getTimer();
			
			// update text
			myTextHandler.handleTexts();
			
			// handle rollups
			handleRollups();
			
			// world level
			if (isNextWorldLevel) {
				isNextWorldLevel = false;
				nextWorldLevel();
				myWorldMap.storePlayerEntry(myCell, myCell.myGridObject.getGridCol(), myCell.myGridObject.getGridRow(), myCell.myGridObject.getLocalPoint());
			}
			
			// death
			handleDeathReset();
			
			// refresh animations
			//event.updateAfterEvent();
			
			if (c_debug) {
				var frStr:String = "frameRate: " + frameRate + " \nzoomFR: " + zoomFR + " \nmoveCellFR: " + moveCellFR;
				frStr += " \nupdateViewFR: " + updateViewFR;
				frStr += " \ncellRingRotationFR: " + cellRingRotationFR + " \nActionsFR: " + updateAreaActionsFR;
				frStr += " \nupdatedAttachedDistanceFR: " + updateAttachedDistanceFR + " \nupdateTimedEventsFR: " + updateTimedEventsFR;
				frStr += " \nupdateTimedEventsFR: " +  updateTimedEventsFR + " \nhandleObjectMovesFR: " + handleObjectMovesFR;
				frStr += " \nhandleAbsorbingFR: " + handleAbsorbingFR + "\nupdateBackgroundFR: " + updateBackgroundFR;
				frStr += " \n\tLevel = " +  currentLevel;
				DebugText.text = frStr;
			}
		}
		
		/* GUI */
		
		/* Absorbing */
		public function handleAbsorbing():void {
			while(myAbsorbingObjects.length > 0) {
				var go:GridObject = myAbsorbingObjects.pop();
				if (!go.is_removed) {
					
					while(go.absorbed.length > 0) {
						var prit_go:GridObject = go.absorbed.pop();
						
						if (prit_go.type == GridObject.c_type_prit && !prit_go.is_removed && prit_go.canBeAbsorbed()) {
							var prit:CellPrit = prit_go.prit;
							myGrid.destroyGridObject(prit_go);
							
							if (go.type == GridObject.c_type_prot) {
								go.prot.holdPrit(prit);
								
							} else if (go.type == GridObject.c_type_cell) {
								go.cell.Nucleus.absorbPrit(prit);
								
							}
						}
					}
				}
			}
		}
		
		public static function addAbsorbingObject(go:GridObject):void {
			var i:int = myAbsorbingObjects.indexOf(go);
			if (i < 0) {
				myAbsorbingObjects.push(go);
			}
		}
		
		/* Area Actions */
		public function updateAreaActions():void {
			var cooldown_updates:Array = new Array();
			var remove:Array = new Array();
			for each (var area:CellArea in myAreaActions) {
				if (!area.m_is_enabled || area.myGridObject.is_removed) {
					remove.push(area);
					continue;
				}
				
				while(area.m_contains_enter.length > 0) {
					var go:GridObject = area.m_contains_enter.pop();
					if (!go.is_removed) {
						area.performAreaAction_Enter(go);
						area.m_contains_update.push(go);
					}
				}
				
				var go_remove:Array = new Array();
				var i:int = 0;
				for each (go in area.m_contains_update) {
					if (!go.is_removed) {
						var dv:Point = myGrid.getDistance(area.myGridObject, go);
						if (dv.length < area.myGridObject.boundingRadius + go.boundingRadius) {
							if (go.in_area_cooldown < 1) {
								area.performAreaAction_Update(go, dv);
								if ( cooldown_updates.indexOf(go) < 0) {
									cooldown_updates.push(go);
								}
							}
						} else {
							area.m_contains_leave.push(go);
							go_remove.push(i);
						}
					}
					++i;
				}
				
				while (go_remove.length > 0) {
					area.m_contains_update.splice(go_remove.pop(), 1);
				}
				
				while(area.m_contains_leave.length > 0) {
					go = area.m_contains_leave.pop();
					if (!go.is_removed) {
						area.performAreaAction_Leave(go);
						go.removeArea(area);
					}
				}
				
				if ( (area.m_contains_enter.length == 0) && 
				(area.m_contains_update.length == 0) && 
				(area.m_contains_leave.length == 0) ) {
					remove.push(area);
				}
				
			}
			
			while (cooldown_updates.length > 0) {
				go = cooldown_updates.pop()
				go.updateAreaCooldown();
				myObjectCooldowns.push(go);
			}
			
			var cooldown_removed:Array = new Array();
			i = 0;
			for each (go in myObjectCooldowns) {
				--go.in_area_cooldown;
				if (go.in_area_cooldown < 1) {
					cooldown_removed.push(i);
				}
				++i;
			}
			
			while (cooldown_removed.length > 0) {
				myObjectCooldowns.splice( cooldown_removed.pop(), 1 );
			}
			
			while(remove.length > 0) {
				removeAreaActions(remove.pop());
			}
			
		}
		
		public static function addAreaActions(area:CellArea):void {
			myAreaActions.push(area);
		}
		
		public static function removeAreaActions(area:CellArea):void {
			var i:int = myAreaActions.indexOf(area);
			if (i >= 0) {
				myAreaActions.splice(i, 1);
			}
			area.m_action_is_entry = false;
		}
		
		/*Attached Distances*/
		// we need to make sure to prevent floating attached objects
		public function updateAttachedDistance():void {
			var remove:Array = new Array();
			var i:int = 0;
			for each (var go:GridObject in myMovedAttachedObjects) {
				if (!go.is_removed) {
					var dv:Point = myGrid.getDistance(go, go.attach_source);
					
					if ( (dv.length > (go.attached_target_distance + c_attach_distance_threshold)) ) {
						dv.normalize(c_attach_return_inc_speed);
						go.moveAdd(dv);
						go.is_outside_attach_target_distance = true;
					} else if( (dv.length < (go.attached_target_distance + 3 - c_attach_distance_threshold)) ) {
						dv.normalize(-c_attach_return_inc_speed);
						go.moveAdd(dv);
						go.is_outside_attach_target_distance = true;
					} else if (go.is_outside_attach_target_distance) {
						go.moveStop_Slow();
						remove.push(i);
					} 
				} else {
					remove.push(i);
				}
				i++;
			}
			
			// handle removed
			while(remove.length > 0) {
				i = remove.pop();
				myMovedAttachedObjects[i].is_outside_attach_target_distance = false;
				myMovedAttachedObjects[i].is_moved = false;
				myMovedAttachedObjects.splice(i, 1);
			}
		}
		
		/* View */
		public function updateView():void {
			// get viewport coords for cell
			// note: this may be the only place where we need global coords
			var global_cell_point:Point = myCell.localToGlobal(new Point(0, 0));
			
			// check if we are near viewport threshold.
			// if we go over the threshold we want to:
			// 1) find distance over threshold
			// 2) move the grid that distance
			// 3) subtract from our local point (so it seems like we move, but we don't)
			// note: this thresh_diff is the difference from scaling.  So we need to inverse_scale this value
			var thresh_diff:Point = new Point(0, 0);
			if (global_cell_point.x < m_view_screen_left) {
				thresh_diff.x = (m_view_screen_left - global_cell_point.x);
			} else if (global_cell_point.x > m_view_screen_right) {
				thresh_diff.x = (m_view_screen_right - global_cell_point.x);
			}
			
			if (global_cell_point.y < m_view_screen_top) {
				thresh_diff.y = (m_view_screen_top - global_cell_point.y);
			} else if (global_cell_point.y > m_view_screen_bottom) {
				thresh_diff.y = (m_view_screen_bottom - global_cell_point.y);
			}
			
			// this gets messy when we start to scale:
			// basically we want to shift the global_cell_point, but we need to inverse_scale this distance
			// so we don't move something like 1000x the speed of light.  We want to move the correct amount.
			if (thresh_diff.length > 0) {
				
				// inverse scale the threshold
				thresh_diff.x /= myWorldDisplay.scaleX;
				thresh_diff.y /= myWorldDisplay.scaleY;
				
				myGrid.moveGrids(thresh_diff);
			}
			
		}
		
		// try to make fluid zooms
		public function updateZoom():void {
			if (isKeyZoomIn) {
				myZoomTo = myWorldDisplay.scaleX * 1.10;
			} else if (isKeyZoomOut) {
				myZoomTo = myWorldDisplay.scaleX * 0.90;
			}
			
			if (myZoomTo < myCell.stats_max_view) {
				myZoomTo = myCell.stats_max_view;
			} else if (myZoomTo > c_min_view) {
				myZoomTo = c_min_view;
			}
			
			var dz:Number = myZoomTo - myWorldDisplay.scaleX;
			
			if (Math.abs(dz) > Number.MIN_VALUE) {
				// calculate time in steps to finish point
				var sign:int = dz<0?-1:1;
				var steps:int = 11;
				if (Math.abs(m_zoom_speed) > Number.MIN_VALUE) {
					steps = int(dz/m_zoom_speed);
				}
				
				if (steps > 10)  {
					m_zoom_speed = dz/steps;
				}
				
				if (Math.abs(dz) < Math.abs(m_zoom_speed)) {
					m_zoom_speed = dz * -1;
				}
				
				myWorldDisplay.scaleX -= m_zoom_speed*sign;
				myWorldDisplay.scaleY -= m_zoom_speed*sign;
				
				dz = myZoomTo - myWorldDisplay.scaleX;
				if ( (sign != dz<0?-1:1) || (Math.abs(dz) < Number.MIN_VALUE) ) {
					myWorldDisplay.scaleX = myZoomTo;
					myWorldDisplay.scaleY = myZoomTo;
					m_zoom_speed = 0.0;
				} 
				
				if (c_debug) {
					HelpToolTip.updateText("scaleX: " + myWorldDisplay.scaleX + ", scaleY: " + myWorldDisplay.scaleY);
				}
			}
		}
		
		public static function newZoomTo(zoomTo:Number):void {
			myZoomTo = zoomTo;
		}
		
		/* Timed Events */
		public function updateTimedEvents():void {
			if (myTimedEvents.length == 0) {
				return;
			}
			
			var f:Function = function(item:*, index:int, array:Array):Boolean {
				var timed_event:Object = Object(item);
				if (timed_event.current_time-- == 0) {
					if (timed_event.recurring) {
						// we are going to trust that the callback doesn't remove or add a time event
						timed_event.callback.call(timed_event.object);
						timed_event.current_time = timed_event.init_time;
						return false;
					}
					return true;
				} 
				return false;
			};
			
			var remove:Array = myTimedEvents.filter(f);
			while(remove.length > 0) {
				var timed_event:Object = remove.pop();
				// remove and then call incase that call readds timed_event
				removeFromTimedEvents(timed_event.object);
				timed_event.callback.call(timed_event.object);
			}
		}
		
		public static function newTimedEvent(go:GridObject, callback:Function, t:uint, recurring:Boolean = false):Object {
			var timed_event:Object = new Object();
			timed_event.object = go;
			timed_event.callback = callback;
			timed_event.current_time = t;
			timed_event.init_time = t;
			timed_event.recurring = recurring;
			myTimedEvents.push(timed_event);
			go.myTimedEvent = timed_event;
			return timed_event;
		}
		
		public static function removeFromTimedEvents(go:GridObject):void {
			myTimedEvents.splice( myTimedEvents.indexOf(go.myTimedEvent), 1 );
			go.myTimedEvent = null;
		}
		
		/* Movement */
		public function moveCell():void {
			var speed:Point = new Point(0, 0);
			
			// keys
			if (isKeyDown) {
				speed.y = 1;
			} else if (isKeyUp) {
				speed.y = -1;
			}
			
			if (isKeyRight) {
				speed.x = 1;
			} else if (isKeyLeft) {
				speed.x = -1;
			}
			
			// apply speed to cell;
			if (speed.length > Number.MIN_VALUE) {
				speed.normalize(m_speed_inc);
				myCell.myGridObject.moveAdd(speed);
			}
			
			myCell.updateFaceDirection(myCell.myGridObject.move_speed.x, myCell.myGridObject.move_speed.y);
			
			myGrid.getViewFromObject(myCell.myGridObject);
			myGrid.checkGridShiftFromObject(myCell.myGridObject);
			
		}
		
		public function handleObjectMoves():void {
			var remove_moves:Array = new Array();
			for each (var go:GridObject in myObjectMoves) {
				
				if (!go.is_removed) {
					// check displacement
					var dv:Point = go.getMovement();
					if (dv.length > Number.MIN_VALUE) {
						go.move_speed = myGrid.getCollisionResult_Circle(go, dv);
					}
					var speed_abs:Number = go.move_speed.length;
					if (speed_abs + go.move_accel < Number.MIN_VALUE) {
						go.move_speed.x = 0;
						go.move_speed.y = 0;
						if (go.isRotationStop()) {
							remove_moves.push(go);
						}
					} else {
						var n:Point = go.move_speed.clone();
						n.normalize(1);
						go.move_speed.x += go.move_accel*n.x;
						go.move_speed.y += go.move_accel*n.y;
					}
					
					// check rotation
					if (go.is_attached) {
						var rs:Number = go.rotate_speed;
						if (go.rotate_has_target) {
							var rd:Number = rotationDistanceSigned(go.getRotation(), go.rotate_target);
							var sign:int = (rd < 0)?-1:1;
							
							if (Math.abs(rd) < Math.abs(rs)) {
								rs = rd * -1;
							}
							myGrid.getRotateCollisionResult_Circle(go, rs);
							rd = rotationDistanceSigned(go.getRotation(), go.rotate_target);
							if ( (sign != (( rd < 0 )?-1:1)) || (Math.abs(rd) < Number.MIN_VALUE) ) {
								go.rotate_speed = 0;
								go.rotate_target = 0;
								if (go.isMovementStop()) {
									remove_moves.push(go);
								}
							}
						} else {
							if (Math.abs(rs) > Number.MIN_VALUE) {
								myGrid.getRotateCollisionResult_Circle(go, rs);
							}
							if (Math.abs(go.rotate_speed) + go.rotate_accel < Number.MIN_VALUE) {
								go.rotate_speed = 0;
								if (go.isMovementStop()) {
									remove_moves.push(go);
								}
							} else {
								go.rotate_speed += go.rotate_accel*(go.rotate_speed<-1?-1:1);
							}
						}
					}
				} else {
					remove_moves.push(go);
				}
			}
			
			while (remove_moves.length > 0) {
				removeObjectMove(remove_moves.pop());
			}
		}
		
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
		
		public static function addObjectMove(go:GridObject):void {
			myObjectMoves.push(go);
		}
		
		public static function removeObjectMove(go:GridObject):void {
			var i:int = myObjectMoves.indexOf(go);
			if (i >= 0) {
				myObjectMoves.splice(i, 1);
			}
			go.move_is_entry = false;
		}
		
		
		public static function rotateRing(cell:CellSingle, ring:int, speed:Number):void {
			for (var p:int = 0; p < cell.getRingSize(ring); ++p) {
				var prot:CellProt = cell.getProt(ring, p);
				prot.myGridObject.rotateAdd(speed);
			}
		}
		
		/* Mouse */
		public static function newMouseMoveHandler(cell:CellSingle, f:Function):void {
			mouseMoveCallingObject = new Object();
			mouseMoveCallingObject.object = cell;
			mouseMoveCallingObject.callback = f;
			mouseMoveCallingObject.lastX = myStage.mouseX;
			mouseMoveCallingObject.lastY = myStage.mouseY;
			isHandleMouseMove = true;
		}
		
		public static function removeMouseMoveHandler():void {
			mouseMoveCallingObject = null;
			isHandleMouseMove = false;
		}
		
		/* Keyboard */
		public function keyDownHandler(event:KeyboardEvent):void {
			isKeyDown ||= (event.keyCode == c_key_down) || (event.keyCode == c_key_s);
			isKeyUp ||= (event.keyCode == c_key_up) || (event.keyCode == c_key_w);
			isKeyRight ||= (event.keyCode == c_key_right) || (event.keyCode == c_key_d);
			isKeyLeft ||= (event.keyCode == c_key_left) || (event.keyCode == c_key_a);
			isKeyZoomIn ||= (event.keyCode == c_key_1);
			isKeyZoomOut ||= (event.keyCode == c_key_2);
			
			if (event.keyCode == 32) {
				if (myCell.absorbState == CellSingle.c_repel) {
					myCell.updateEnable(false);
				} else {
					myCell.updateEnable(true);
				}
			}
			
		}
		
		public function keyUpHandler(event:KeyboardEvent):void {
			isKeyDown &&= !(event.keyCode == c_key_down) && !(event.keyCode == c_key_s);
			isKeyUp &&= !(event.keyCode == c_key_up) && !(event.keyCode == c_key_w);
			isKeyRight &&= !(event.keyCode == c_key_right) && !(event.keyCode == c_key_d);
			isKeyLeft &&= !(event.keyCode == c_key_left) && !(event.keyCode == c_key_a);
			isKeyZoomIn &&= !(event.keyCode == c_key_1);
			isKeyZoomOut &&= !(event.keyCode == c_key_2);
			
			/*
			if (event.keyCode == c_key_n) {
				nextWorldLevel();
			} else if (event.keyCode == c_key_m) {
				previousWorldLevel();
			}
			*/
			
			if (event.keyCode == c_key_n) {
				myViewer.GrowViewer(5, 5);
			} else if (event.keyCode == c_key_m) {
				myViewer.ShrinkViewer(5, 5);
			}
			
			if (event.keyCode == c_key_j) {
				myViewer.MoveViewer(-5, 0);
			} else if (event.keyCode == c_key_k) {
				myViewer.MoveViewer(5, 0);
			}
		}
		
		public function resetKeys():void {
			isKeyDown = false;
			isKeyUp = false;
			isKeyRight = false;
			isKeyLeft = false;
			isKeyZoomIn = false;
			isKeyZoomOut = false;
		}
		
		/* World Level */
		public function nextWorldLevel():void {
			currentLevel++;
			if (currentLevel > myLevels.length) {
				currentLevel = myLevels.length-1;
			}
			myWorldMap = myLevels[currentLevel];
			myGrid.myWorldMap = myWorldMap;
			myBackground.updateSpecialObjects( myWorldMap.mySpecialObjects );
			myTextHandler.updateNewWorldMap_TextObjects();
			
		}
		
		public function previousWorldLevel():void {
			currentLevel--;
			if (currentLevel < 0) {
				currentLevel = 0;
			}
			myWorldMap = myLevels[currentLevel];
			myGrid.myWorldMap = myWorldMap;
			myBackground.updateSpecialObjects( myWorldMap.mySpecialObjects );
			myTextHandler.updateNewWorldMap_TextObjects();
			
		}
		
		
		/* Background */
		public function updateBackground():void {
			myBackground.updateBackground();
		}
		
		public static function changeBackground(bg:uint):void {
			myBackground.m_current_background = bg;
		}
		
		public static function unregisterSpecial(special_object:Object):void {
			myBackground.unregisterSpecial(special_object);
		}
		
		
		/* Text */
		public static function addNewText_Player(texts:Array, text_type:uint, is_repeat:Boolean = false):void {
			
			myTextHandler.attachNewTextToPlayer(texts, text_type, is_repeat);
			
		}
		
		public static function addNewText_GridObject(go:GridObject, texts:Array, text_type:uint, is_repeat:Boolean = false):void {
			
			myTextHandler.attachNewTextToObject(go, texts, text_type, is_repeat);
			
		}
		
		public static function addNewText_MapEntry(map_entry:Object, texts:Array, text_type:uint, is_repeat:Boolean = false):void {
			
			myTextHandler.attachNewTextToMapEntry(map_entry, texts, text_type, is_repeat);
			
		}
		
		/* Death */
		public function handleDeathReset():void {
			if (isDeathReset) {
				switch (m_death_reset_state) {
					case c_death_reset_init:
						// remove keys
						stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
						stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
						resetKeys();
						
						// background
						myBackground.m_current_background = CellBackground.c_background_gold;
						
						// store locals for later
						var local_point:Point = myCell.myGridObject.getLocalPoint();
						var col:int = myCell.myGridObject.getGridCol();
						var row:int = myCell.myGridObject.getGridRow();
						
						
						// remove player
						myGrid.removeAllAttached( myCell.myGridObject );
						
						// clear world map
						myWorldMap.clearMap();
						
						// clear grid
						myGrid.clearGrid();
						
						// init to move our player
						myWorldMap.loadPlayerTransition_Init( myCell, col, row, local_point, myGrid );
						
						m_death_reset_state = c_death_reset_update;
						m_death_reset_count = c_death_reset_count * c_fps / 1000;
						break;
					case c_death_reset_update:
						if (m_death_reset_count > 0) {
							myWorldMap.loadPlayerTransition_Update( myCell, myGrid );
							--m_death_reset_count;
						} else {
							m_death_reset_state = c_death_reset_end;
						}
						break;
					case c_death_reset_end:
					default:
						// again remove player
						myGrid.removeAllAttached( myCell.myGridObject );
						
						// add player
						myWorldMap.loadPlayerTransition_End( myCell, myGrid) ;
						
						// fill map
						CellWorldMap.fillWorldMap( myWorldMap, myGrid );
						
						// fill grid
						myGrid.fillGrid();
						
						// background
						myBackground.m_current_background = myCell.myGridObject.myGridHandler.background;
						
						// keys
						stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
						stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
						
						m_death_reset_state = c_death_reset_init;
						isDeathReset = false;
						break;
				}
			}
		}
		
		/* Number Rollups */
		public static function changeEnergy(rollup_type:uint, rollup_index:int, go:GridObject, energy:int, is_player_status:Boolean = false):void {
			if (go.is_removed) {
				return;
			}
			
			var rollups:Array = go.rollups;
			var sprite:Sprite = go.sprite;
			if (is_player_status) {
				rollups = go.cell.myCellStatus.rollups;
				sprite = go.cell.myCellStatus.cell;
			}
			
			var rollup:Object = rollups[rollup_index];
			
			if (!rollup) {
				// create new rollup
				rollup = newRollup(go, sprite, rollup_type, rollups, rollup_index, energy);
				myRollups.push(rollup);
				rollups[rollup_index] = rollup;
			} else {
				rollup.value += energy;
				if (rollup.textBox.alpha < 0.50) {
					rollup.textBox.alpha = 0.50;
				}
				
				switch (rollup_type) {
					case c_rollup_energy_full:
						rollup.textBox.text = "FULL";
						break;
					case c_rollup_energy_empty:
						rollup.textBox.text = "EMPTY";
						break;
					case c_rollup_energy_dead:
						rollup.textBox.text = "DEAD";
						break;
					case c_rollup_energy_increase:
					default:
						rollup.textBox.text = "+" + rollup.value;
						break;
					case c_rollup_energy_decrease:
						rollup.textBox.text = "-" + rollup.value;
						break;
				}
			}
			
			if ( (!is_player_status) && (go.type == GridObject.c_type_cell) && (go.cell.m_is_player) ) {
				changeEnergy(rollup_type, rollup_index, go, energy, true);
			}			
		}
		
		public static function newRollup(go:GridObject, sprite:Sprite, rollup_type:uint, rollups:Array, rollup_index:int, value:int = 0):Object {
			var phys_rollup:PhysNumberRollup = new PhysNumberRollup();
			phys_rollup.gotoAndStop(1);
			phys_rollup.x = 0.0;
			phys_rollup.y = 0.0;
			phys_rollup.visible = false;
			phys_rollup.mouseEnabled = false;
			phys_rollup.mouseChildren = false;
			sprite.addChild(phys_rollup);
			
			var new_rollup = new Object();
			new_rollup.object = go;
			new_rollup.sprite = sprite;
			new_rollup.rollups = rollups;
			new_rollup.index = rollup_index;
			new_rollup.phys_rollup = PhysNumberRollup(phys_rollup);
			new_rollup.textBox = TextField(phys_rollup.textBox);
			new_rollup.textBox.alpha = 1.0;
			new_rollup.value = value;
			
			var text_format:TextFormat = new_rollup.textBox.defaultTextFormat;
			var text_value:String = String(new_rollup.value);
			
			switch (rollup_type) {
				case c_rollup_energy_dead:
					text_format.color = 0x733D26;
					text_format.size = 30;
					text_value = "DEAD";
					break;
				case c_rollup_energy_empty:
					text_format.color = 0x733D26;
					text_format.size = 20;
					text_value = "EMPTY";
					break;
				case c_rollup_energy_full:
					text_format.color = 0x26732E;
					text_format.size = 20;
					text_value = "FULL";
					break;
				case c_rollup_energy_increase:
				default:
					text_format.color = 0x26732E;
					text_format.size = 20;
					text_value = "+" + text_value;
					break;
				case c_rollup_energy_decrease:
					text_format.color = 0x733D26;
					text_format.size = 20;
					text_value = "-" + text_value;
					break;
			}
			
			new_rollup.textBox.defaultTextFormat = text_format;
			new_rollup.textBox.text = text_value;
			
			new_rollup.textBox.blendMode = BlendMode.LAYER;
			new_rollup.state = c_rollup_stop;
			
			return new_rollup;
		}
		
		public function handleRollups():void {
			if (myRollups.length == 0) {
				return;
			}
			
			var remove:Array = new Array();
			var i:int = 0;
			for each (var rollup:Object in myRollups) {
				handleRollup(rollup);
				
				if (rollup.state == c_rollup_stop) {
					remove.push(i);
				}
				++i;
			}
			
			while(remove.length > 0) {
				i = remove.pop();
				rollup = myRollups[i];
				if (rollup.sprite) {
					rollup.sprite.removeChild(rollup.phys_rollup);
				}
				rollup.rollups[rollup.index] = null;
				rollup.rollups = null;
				rollup.object = null;
				rollup.sprite = null;
				myRollups.splice(i, 1);
			}
		}
		
		public function handleRollup(rollup:Object):void {
			if (rollup.object.is_removed) {
				rollup.state = c_rollup_stop; // flag for removal
				return;
			}
			
			if (rollup.state == c_rollup_running) {
				rollup.textBox.alpha -= c_rollup_alpha_step;
				
				if (rollup.textBox.alpha < Number.MIN_VALUE) {
					// stop
					rollup.phys_rollup.visible = false;
					rollup.phys_rollup.y = 0.0;
					rollup.textBox.alpha = 1.0;
					rollup.value = 0;
					rollup.state = c_rollup_stop;
				}
			} else {
				// start
				rollup.state = c_rollup_running;
				rollup.phys_rollup.visible = true;
			}
		}

	}
}