package CellStuff {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	import flash.geom.Point;
	
	import flash.events.Event;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class CellBackground extends MovieClip {
		
		
		public var mySoundList:Array;
		
		public var myBackground_new:PhysBackground;
		public var myBackground_old:PhysBackground;
		
		public var myBackgroundSound_new:Sound;
		public var myBackgroundSound_old:Sound;
		public var mySoundChannel_new:SoundChannel;
		public var mySoundChannel_old:SoundChannel;
		
		public var myGrid:CellGridDisplay;
		public var myWorldMap:CellWorldMap;
		public var myCell:CellSingle_Player;
		
		public var myDirectors:Array;
		public var mySpecialObjects:Array;
		
		public var myBackgroundObjects:Array;
		
		public var m_grid_col:int;
		public var m_grid_row:int;
		
		public var m_middle_x:int;
		public var m_middle_y:int;
		
		public var m_current_background:uint;
		public var m_new_background:uint;
		public var m_old_background:uint;
		public var m_forced_background:uint;
		
		public var m_is_changing:Boolean;
		public var m_is_forcing_background:Boolean;
		public var m_is_changing_sound:Boolean;
		
		public static const c_background_normal:uint 	= 0x000000;
		public static const c_background_gold:uint 		= 0x000001;
		public static const c_background_trees:uint 	= 0x000002;
		public static const c_background_bubbles:uint 	= 0x000003;
		public static const c_background_fire:uint 		= 0x000004;
		
		public static const c_alpha_step:Number = 0.10;
		public static const c_volume_step:Number = 0.10;
		
		public static const c_special_type_none:uint		= 0x000000;
		public static const c_special_type_light:uint		= 0x000001;  // display a light
		
		public static const c_background_object_tree:uint	= 0x000000;
		public static const c_background_object_bubble:uint	= 0x000001;
		
		public static const c_special_radius:Number = 250.0;
		
		public function CellBackground(middle_x:Number, middle_y:Number) {
			m_grid_col = 0;
			m_grid_row = 0;
			
			m_middle_x = middle_x;
			m_middle_y = middle_y;
			
			m_new_background = c_background_normal;
			myBackground_new = new PhysBackground();
			myBackground_new.gotoAndStop("normal");
			//myBackground_new.cacheAsBitmap = true;
			addChild(myBackground_new);
			
			m_old_background = c_background_normal;
			myBackground_old = new PhysBackground();
			myBackground_old.gotoAndStop("normal");
			myBackground_old.visible = false;
			//myBackground_old.cacheAsBitmap = true;
			addChild(myBackground_old);
			
			// my directors
			myDirectors = new Array();
			
			// my registered special objects
			mySpecialObjects = new Array();
			
			// background objects
			myBackgroundObjects = new Array();
			
			// others
			
			m_is_changing = false;
			m_is_forcing_background = false;
			m_is_changing_sound = false;
			
			
			mouseEnabled = false;
			mouseChildren = false;
			
			m_current_background = c_background_normal;
			m_forced_background = c_background_gold;
			
			// music
			mySoundList = new Array();
			mySoundList.push(new PhysBGSound_Default());
			mySoundList.push(new PhysBGSound_Gold());
			
			myBackgroundSound_new = new PhysBGSound_Default();
			mySoundChannel_new = myBackgroundSound_new.play(0, int.MAX_VALUE);
			var st:SoundTransform = mySoundChannel_new.soundTransform;
			st.volume = 1.0;
			mySoundChannel_new.soundTransform = st;
		}
		
		public function setGridMapCell(grid:CellGridDisplay, map:CellWorldMap, cell:CellSingle_Player):void {
			myGrid = grid;
			myWorldMap = map;
			myCell = cell;
			
		}
		
		
		public function changeBackground_old(b:uint):void {
			changeBackground(myBackground_old, b);
			m_old_background = b;
		}
		
		public function changeBackground_new(b:uint):void {
			changeBackground(myBackground_new, b, true);
			m_new_background = b;
		}
		
		public function changeBackground(pb:PhysBackground, b:uint, remove_background_objects:Boolean = false):void {
			if (remove_background_objects) {
				// remove background objects
				removeAllBackgroundObjects();
			}
			
			switch(b) {
				case c_background_fire:
					pb.gotoAndStop("fire");
					break;
				case c_background_bubbles:
					pb.gotoAndStop("bubbles");
					
					if (remove_background_objects) {
						// set background objects
						/*addBackgroundObject(c_background_object_bubble, 2.0, -0.75);
						addBackgroundObject(c_background_object_bubble, 4.0, 0.25, 750, 550);
						addBackgroundObject(c_background_object_bubble, 1.0, -0.5, 550, 750);
						addBackgroundObject(c_background_object_bubble, 0.5, 2.0, 600, 600);
						*/
					}
					break;
				case c_background_trees:
					pb.gotoAndStop("trees");
					
					if (remove_background_objects) {
						// set background objects
						//addBackgroundObject(c_background_object_tree, 10.0);
					}
					break;
				case c_background_gold:
					pb.gotoAndStop("black");
					break;
				case c_background_normal:
				default:
					pb.gotoAndStop("normal");
					break;
			}
		}
		
		public function addBackgroundObject(type:uint, scale:Number, move_scale:Number = 0.75, start_x:Number = 550, start_y:Number = 550):void {
			var phys_bg_object:MovieClip = null;
			var bg_object_width:Number = 10;
			var bg_object_height:Number = 10;
			
			switch (type) {
				case c_background_object_tree:
				default:
					phys_bg_object = new PhysBackground_Tree();
					phys_bg_object.scaleX = scale;
					phys_bg_object.scaleY = scale;
					phys_bg_object.gotoAndStop("grey");
					
					bg_object_width = 10*9.0 * scale;
					bg_object_height = 14*9.0 * scale;
					break;
				case c_background_object_bubble:
					phys_bg_object = new PhysBackground_Bubble();
					phys_bg_object.scaleX = scale;
					phys_bg_object.scaleY = scale;
					phys_bg_object.gotoAndStop(1);
					
					bg_object_width = 2*9.0 * scale;
					bg_object_height = 2*9.0 * scale;
					break;
			}
			
			var bg_socket:Sprite = new Sprite();
			bg_socket.addChild(phys_bg_object);
			bg_socket.x = start_x + bg_object_width;
			bg_socket.y = start_y + bg_object_height;
			myBackground_new.addChild(bg_socket);
			
			var bg_object:Object = {socket:bg_socket, width:bg_object_width, height:bg_object_height, source:myBackground_new, move_scale:move_scale};
			myBackgroundObjects.push(bg_object);
		} 
		
		public function removeAllBackgroundObjects():void {
			while (myBackgroundObjects.length > 0) {
				var bg_object:Object = myBackgroundObjects.pop();
				bg_object.source.removeChild(bg_object.socket);
			}
		}
		
		public function updateMove(dv:Point):void {
			for each (var bg_object:Object in myBackgroundObjects) {
				var socket:Sprite = bg_object.socket;
				socket.x += dv.x * bg_object.move_scale;
				socket.y += dv.y * bg_object.move_scale;
				
				if (socket.x < -bg_object.width) {
					socket.x = 550 + bg_object.width;
				} else if (socket.x > 550 + bg_object.width) {
					socket.x = -bg_object.width;
				}
				
				if (socket.y < -bg_object.height) {
					socket.y = 550 + bg_object.height;
				} else if (socket.y > 550 + bg_object.height) {
					socket.y = -bg_object.height;
				}
			}
		}
		
		public function	changeBackgroundMusic_new(b:uint):void {
			switch(b) {
				case c_background_gold:
					myBackgroundSound_new = mySoundList[1];
					break;
				case c_background_normal:
				default:
					myBackgroundSound_new = mySoundList[0];
					break;
			}
			
			// swap and set new volume to 0.0
			mySoundChannel_old = mySoundChannel_new;
			mySoundChannel_new = myBackgroundSound_new.play(0, int.MAX_VALUE);
			var st:SoundTransform = mySoundChannel_new.soundTransform;
			st.volume = 0.0;
			mySoundChannel_new.soundTransform = st;
		}
		
		/* Update Background */
		public function updateBackground():void {
			if (m_is_changing) {
				myBackground_old.alpha -= c_alpha_step;
				
				if (m_is_changing_sound) {
					// old decrease
					var st:SoundTransform = mySoundChannel_old.soundTransform;
					st.volume -= c_volume_step;
					if (st.volume < 0.0) {
						st.volume = 0.0;
					}
					mySoundChannel_old.soundTransform = st;
					
					// new increase
					st = mySoundChannel_new.soundTransform;
					st.volume += c_volume_step;
					if (st.volume > 1.0) {
						st.volume = 1.0;
					}
					mySoundChannel_new.soundTransform = st;
				}
				
				if (myBackground_old.alpha < Number.MIN_VALUE) {
					myBackground_old.visible = false;
					changeBackground_old(m_new_background);
					myBackground_old.alpha = 1.0;
					m_is_changing = false;
					
					handleRemovingDirectors();
					
					if (m_is_changing_sound) {
						mySoundChannel_old.stop();
						
						st = mySoundChannel_new.soundTransform;
						st.volume = 1.0;
						mySoundChannel_new.soundTransform = st;
						
						m_is_changing_sound = false;
					}
				}
				
			} else if (m_is_forcing_background) {
				if (m_new_background != m_forced_background) {
					switchBackgrounds();
					changeBackground_new(m_forced_background);
					changeBackgroundMusic_new(m_new_background);
				}
			} else if (m_new_background != m_current_background) { 
				switchBackgrounds();
				changeBackground_new(m_current_background);
				changeBackgroundMusic_new(m_new_background);
			}
			
			handleSpecialObjects();
		}
		
		public function handleSpecialObjects():void {
			m_is_forcing_background = false;
			
			for (var i:int = 0; i < mySpecialObjects.length; i++) {
				var so:Object = mySpecialObjects[i];
				
				var world_point1:Point = myGrid.viewToWorld(new Point(0, 0));
				var world_point2:Point = null;
				if (so.object && so.object.is_removed) {
					so.object = null;
				}
				
				if (so.object && !so.object.is_removed) {
					// we have a grid object so get the second point directly
					world_point2 = myGrid.getWorldFromObject(so.object);
					
					// update our special object location
					so.col = so.object.getGridCol() + myGrid.myWorldMap.m_current_col;
					so.row = so.object.getGridRow() + myGrid.myWorldMap.m_current_row;
					so.local_point = so.object.getLocalPoint();
				} else {
					// find world point from map and note that the object is outside of the grid
					world_point2 = myGrid.getWorldFromLocal(so.col - myGrid.myWorldMap.m_current_col, so.row - myGrid.myWorldMap.m_current_row, so.local_point);
				}
				var dv:Point = world_point2.subtract(world_point1);
				
				switch (so.type) {
					case c_special_type_none:
						break;
					case c_special_type_light:
					default:
						updateSpecialObject_Light(so, dv);
						break;
				}
				
			}
		}
		
		public function updateSpecialObject_Light(so:Object, dv:Point):void {
			var d:Number = dv.length;
			
			if (d > c_special_radius) {
				so.director.director.alpha =  c_special_radius/d;
				dv.normalize(c_special_radius);
				d = c_special_radius;
			} else {
				m_is_forcing_background = true;
				so.director.director.alpha = 1.0;
			}
			
			so.director.director.x = dv.x;
			so.director.director.y = dv.y;
			
			so.director.director.scaleX = d/20+3;
			so.director.director.scaleY = d/20+3;
		}
		
		public function handleRemovingDirectors():void {
			
			var remove:Array = new Array();
			for (var i:int = 0; i < myDirectors.length; ++i) {
				var director_handler:Object = myDirectors[i];
				if (director_handler.is_removing) {
					myBackground_new.removeChild(director_handler.socket);
					remove.push(i);
				}
			}
			
			while (remove.length > 0) {
				myDirectors.splice( remove.pop(), 1);
			}
		}
		
		public function switchBackgrounds(is_change_sound:Boolean = true):void {
			m_is_changing = true;
			myBackground_old.visible = true;
			
			// sound
			m_is_changing_sound = is_change_sound;
		}
		
		public function exchangeSounds(pos:int, new_sound:Sound):void {
			mySoundList[pos] = new_sound;
			switchBackgrounds(true);
			changeBackground_new(m_current_background);
			changeBackgroundMusic_new(m_new_background);
		}
		
		/* register/unregister */
		public function registerSpecial(special_object:Object):void {
			var i:int = mySpecialObjects.indexOf(special_object);
			if (i > -1) {
				// already registered so unregister first
				unregisterSpecial(special_object);
			}
			
			mySpecialObjects.push(special_object);
			
			var director_socket:MovieClip = new MovieClip();
			director_socket.x = m_middle_x;
			director_socket.y = m_middle_y;
			myBackground_new.addChild(director_socket);
			
			var director:MovieClip = null;
			var director_handler:Object = new Object();
			
			switch (special_object.type) {
				case c_special_type_light:
				default:
					director = new PhysLights();
					director.gotoAndStop(1);
					break;
			}
			director_socket.addChild(director);
			
			director_handler.director = director;
			director_handler.socket = director_socket;
			director_handler.is_removing = false;
			
			myDirectors.push(director_handler);
			special_object.director = director_handler;
			
			switchBackgrounds(false);
		}
		
		public function unregisterSpecial(special_object:Object):void {
			var i:int = mySpecialObjects.indexOf(special_object);
			if (i < 0) {
				// not registered so get out of here
				return;
			}
			
			var special_object:Object = mySpecialObjects[i];
			special_object.director.is_removing = true;
			
			mySpecialObjects.splice(i, 1);
			switchBackgrounds(false);
		}
		
		public function updateSpecialObjects(special_objects:Array):void {
			// unregister all first
			while (mySpecialObjects.length > 0) {
				unregisterSpecial( mySpecialObjects.pop() );
			}
			
			for (var i:int = 0; i < special_objects.length; ++i) {
				registerSpecial( special_objects[i] );
			}
			
		}
		
	}
}