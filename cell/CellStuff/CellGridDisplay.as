package CellStuff {
	
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.display.Sprite;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class CellGridDisplay extends MovieClip {
		
		public var myBackground:CellBackground;
		
		public var myGrids:Array;
		
		public var myWorldMap:CellWorldMap;
		
		public static var gridWidthPixel:Number;
		public static var gridHeightPixel:Number;
		
		public static var currentFirstGridPoint:Point;
		public static var currentLastEndPoint:Point;
		public static var currentWorldCenter:Point;
		
		public static const c_grid_width:Number = 50;
		public static const c_grid_height:Number = 50;
		
		public static const c_grid_cols:int = 11;
		public static const c_grid_rows:int = 11;
		
		public static const c_view_grids_wide:int = 3;
		public static const c_view_grids_high:int = 3;
		
		public static const c_view_start_col:int = 50;
		public static const c_view_start_row:int = 50;
		
		public static const c_max_grids_wide:int = 200;
		public static const c_max_grids_high:int = 200;
		
		public static const c_center_x:Number = 550/2;
		public static const c_center_y:Number = 550/2;
		
		public static const c_collision_threshold:int = 30;
		public static const c_recursion_threshold:int = 5;
		
		public var DebugText:TextField;
		
		public function CellGridDisplay(bg:CellBackground) {
			
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
			DebugText.text = "okay";
			if (CellWorld.c_debug) {
				addChild(DebugText);
			}
			
			// background
			myBackground = bg;
			
			// set defaults
			gridWidthPixel = (c_grid_width * c_grid_cols);
			gridHeightPixel = (c_grid_height * c_grid_rows);
			
			// create grids
			myGrids = new Array();			
			for (var c:int = 0; c < c_view_grids_wide; c++) {
				for (var r:int = 0; r < c_view_grids_high; r++) {
					createGrid(c, r);
				}
			}
			
			var grid:Object = getGrid(0, 0);
			currentFirstGridPoint = new Point(grid.sprite.x, grid.sprite.y);
			grid = getGrid(c_view_grids_wide-1, c_view_grids_high-1);
			currentLastEndPoint = new Point(grid.sprite.x + gridWidthPixel, grid.sprite.y + gridHeightPixel);
			
			currentWorldCenter = new Point( (currentLastEndPoint.x - currentFirstGridPoint.x)/2, (currentLastEndPoint.y - currentFirstGridPoint.y)/2 );
		}
		
		/* Reset */
		public function clearGrid():void {
			
			// empty grids
			for (var c:int = 0; c < c_view_grids_wide; c++) {
				for (var r:int = 0; r < c_view_grids_high; r++) {
					emptyGrid(c, r, false);
				}
			}
			
			// remove grids
			for (c = 0; c < c_view_grids_wide; c++) {
				for (r = 0; r < c_view_grids_high; r++) {
					removeGrid(c, r);
				}
			}
			
			// create grids
			for (c = 0; c < c_view_grids_wide; c++) {
				for (r = 0; r < c_view_grids_high; r++) {
					createGrid(c, r);
				}
			}
		}
		
		public function fillGrid():void {
			// fill grids
			for (var c:int = 0; c < c_view_grids_wide; c++) {
				for (var r:int = 0; r < c_view_grids_high; r++) {
					myWorldMap.updateGrid(this, getGrid(c, r) );
				}
			}
		}
		
		public function setWorldMap(world_map:CellWorldMap):void {
			myWorldMap = world_map;
			
			for each (var grid_handler:Object in myGrids) {
				myWorldMap.updateGrid(this, grid_handler);
			}
		}
		
		public function createGrid(c:int, r:int):Object {
			var grid_handler:Object = new Object();
			myGrids[c+r*c_view_grids_wide] = grid_handler;
			
			grid_handler.sprite = new Sprite();
			grid_handler.sprite.x = ( gridWidthPixel*c ) - ( gridWidthPixel*int(c_view_grids_wide/2) );
			grid_handler.sprite.y = ( gridHeightPixel*r ) - ( gridHeightPixel*int(c_view_grids_high/2) );
			addChild(grid_handler.sprite);
			
			grid_handler.col = c;
			grid_handler.row = r;
			grid_handler.grid = new Array();
			
			grid_handler.background = CellBackground.c_background_normal;
			grid_handler.explosions = new Array();
			
			if (CellWorld.c_debug) {
				drawGridView(c, r, false);
			}
			
			for (var j:int = 0; j < c_grid_rows; j++) {
				for (var k:int = 0; k < c_grid_cols; k++) {
					grid_handler.grid[j+k*c_grid_cols] = new Array();
				}
			}
			
			return grid_handler;
		}
		
		public function getGrid(c:int, r:int):Object {
			if ( (c < 0) || (c >= c_view_grids_wide) ||
				 (r < 0) || (r >= c_view_grids_high) ) {
				return null;
			}
			
			if (myGrids[c+r*c_view_grids_wide] == null) {
				throw( new Error("myGrids[" + c + "+" + r + "*" + c_view_grids_wide + "]" +  myGrids[c+r*c_view_grids_wide] + " is null") );
			}
			return Object(myGrids[c+r*c_view_grids_wide]);
		}
		
		public function getGridFromObject(go:GridObject):Object {
			var grid_handler:Object = go.myGridHandler;
			if (grid_handler == null) {
				trace( go.toString() );
				throw( new Error("getGridFromObject: grid_handler is null: go: " + getLocalFromObject(go)) );
			}
			return grid_handler;
		}
		
		public function getGridFromColRow(grid_col:int, grid_row:int):Object {
			var grid_handler:Object = getGrid(grid_col, grid_row);
			if (grid_handler == null) {
				throw( new Error("getGridFromColRow: grid_handler is null: " + grid_col + " , " + grid_row) );
			}
			return grid_handler;
		}
		
		public function drawGridView(c:int, r:int, smallgrid:Boolean = true):void {
			var grid_handler:Object = getGrid(c, r);
			if (grid_handler == null) {
				throw( new Error("drawGridView: null grid: " + c + ", " + r) );
				return;
			}
			
			var lines:Sprite = grid_handler.sprite;
			lines.graphics.lineStyle(1, uint(0xFFCCFF * Math.random()) );
			if (smallgrid) {
				for (var j:int = 0; j < c_grid_rows; j++) {
					for (var k:int = 0; k < c_grid_cols; k++) {
						lines.graphics.drawRect(c_grid_width*j, c_grid_height*k, c_grid_width-1, c_grid_height-1);
					}
				}
			} else {
				lines.graphics.drawRect(0, 0, c_grid_width*c_grid_rows-1, c_grid_height*c_grid_cols-1);
			}
		}
		
		public function makeGridObjectLocal(go_x:Number, go_y:Number,
											go_type:uint, bR:Number, mass:Number, max_speed:Number,
											wm_level:int = -1):GridObject 
		{					
			var go:GridObject = makeGridObject(go_type, bR, mass, max_speed, wm_level);
			// todo: remove stupid locals
			go.initLocationLocal( new Point(go_x, go_y) );
			
			return go;
		}
		
		public function makeGridObject(go_type:uint, bR:Number,	mass:Number, max_speed:Number, wm_level:int = -1):GridObject {
			return new GridObject(go_type, bR, mass, max_speed, wm_level);
		}
		
		public function destroyGridObject(go:GridObject):void {
			myWorldMap.handlePersistantObject(go);
			
			removeAllAttached(go);
		}
		
		public function removeAllAttached(go:GridObject):void {
			while(go.attached.length > 0) {
				removeAllAttached(go.attached.pop());
			}
			
			if (go.is_attached) {
				go.attach_source.sprite.removeChild(go.attach_socket);
			}
			
			if (!go.is_removed) {
				removeFromGrid(go);
			}
			
			/*
			if (go.type == GridObject.c_type_area) {
				removeAreaObject(go);
			}
			*/
			
			go.removeObject();
		}		
		public function attachRotatingObject(go:GridObject, to_go:GridObject):void {
			
			// get world point
			var world_point:Point = getWorldFromObject(go);
			// remove the grid box
			removeFromGrid(go);
			
			// add a sprite
			var new_sprite:Sprite = new Sprite();
			new_sprite.x = 0;
			new_sprite.y = 0;
			
			// attach our sprite
			new_sprite.addChild(go.sprite);
			to_go.sprite.addChild(new_sprite);
			
			go.is_attached = true;
			go.attach_source = to_go;
			go.attach_socket = new_sprite;
			
			to_go.attached.push(go);
			
			addToGrid(go, world_point);
			
			updateSpritePosition(go);
			
			var dv:Point = getDistance(go, to_go);
			go.setTargetDistance(dv.length);
		}
		
		
		public function attachAreaObject(area_go:GridObject, to_go:GridObject):void {
			attachRotatingObject(area_go, to_go);
			to_go.areas_attached.push(area_go);
		}
		
		/*
		public function removeAreaObject(area_go:GridObject):void {
			removeFromGrid(area_go);
			var go:GridObject = area_go.attach_source;
			go.sprite.removeChild(area_go.attach_socket);
			
			var i:int = go.areas_attached.indexOf(area_go);
			if (i >= 0) {
				go.areas_attached.splice(i, 1);
			}
			
			area_go.is_attached = false;
			area_go.attach_source = null;
			area_go.attach_socket = null;
		}
		*/
		
		public function getWorldFromObject(go:GridObject):Point {
			var grid_handler:Object = getGridFromObject(go);
			if (!grid_handler) {
				throw ( new Error("getWorldFromObject error: grid_handler is null") );
			}
			
			return localToWorld(grid_handler, go.getLocalPoint());
		}
		
		public function getWorldFromLocal(c:int, r:int, local_point:Point):Point {
			var p:Point = getGridPointFromColRow(c, r);
			p.x += local_point.x;
			p.y += local_point.y;
			
			return p;
		}
		
		public function getLocalFromObject(go:GridObject):Point {
			return go.getLocalPoint();
		}
		
		public function getViewFromObject(go:GridObject):Point {
			return localToView(getGridFromObject(go), getLocalFromObject(go) );
		}
		
		public function localToView(grid_handler:Object, p:Point):Point {
			return worldToView( localToWorld(grid_handler, p) );
		}
		
		public function worldToLocal(grid_handler:Object, p:Point):Point {
			return new Point(p.x - (grid_handler.sprite.x - currentFirstGridPoint.x), p.y - (grid_handler.sprite.y - currentFirstGridPoint.y));
		}
		
		public function localToWorld(grid_handler:Object, p:Point):Point {
			return new Point(p.x + (grid_handler.sprite.x - currentFirstGridPoint.x), p.y + (grid_handler.sprite.y - currentFirstGridPoint.y));
		}
		
		public function worldToView(p:Point):Point {
			return new Point(p.x + (x + currentFirstGridPoint.x), p.y + (y + currentFirstGridPoint.y) );
		}
		
		public function viewToWorld(p:Point):Point {
			return new Point(p.x - (x + currentFirstGridPoint.x), p.y - (y + currentFirstGridPoint.y) );
		}
		
		public function viewToLocal(grid_handler:Object, p:Point):Point {
			var gridp:Point = viewToWorld(p);
			return new Point(gridp.x - grid_handler.sprite.x, gridp.y - grid_handler.sprite.y);
		}
		
		// we are going to try to handle "outside" bcs and brs, in this case we will just grab another grid
		public function getGridBox(c:int, r:int, bc:int, br:int):Array {
			if (bc < 0) {
				bc += c_grid_cols;
				c -= 1;
			} else if (bc >= c_grid_cols) {
				bc -= c_grid_cols;
				c += 1;
			}
			
			if (br < 0) {
				br += c_grid_rows;
				r -= 1;
			} else if (br >= c_grid_rows) {
				br -= c_grid_rows;
				r += 1;
			}
			
			if ( (bc < 0) || (bc >= c_grid_cols) || (br < 0) || (br >= c_grid_rows) ) {
				throw( new Error("getGridBox: problem outside of bounds: bc: " + bc + " br: " + br + " max: " + c_grid_cols + ", " + c_grid_rows) );
			}
			
			var grid_handler:Object = getGrid(c, r);
			if (!grid_handler) {
				// note, we will get here sometimes because of a case where the object is at the very side
				return null;
			}
			
			return grid_handler.grid[bc+br*c_grid_rows];
		}
		
		public function addToGrid(go:GridObject, world_point:Point):void {
			var gc:int = getGridColFromWorld(world_point);
			var gr:int = getGridRowFromWorld(world_point);
			var grid_handler:Object = getGridFromColRow(gc, gr);
			
			var local_point:Point = worldToLocal(grid_handler, world_point);
			
			addToGridLocal( go, grid_handler, local_point );
			
			for (var i:int = 0; i < go.attached.length; ++i) {
				addToGridLocal( go.attached[i], getGridFromObject(go), getLocalFromObject(go) );
			}
		}
		
		public function addToGridLocal(go:GridObject, grid_handler:Object, local_point:Point):void {
			var bcol:int = local_point.x / c_grid_width;
			var brow:int = local_point.y / c_grid_height;
			
			go.setLocalPoint(local_point);
			
			addToGridBoxes(go, grid_handler, bcol, brow);
			
		}
		
		// note, we assume the grid object is not added as a child to the grid
		public function addToGridBoxes(go:GridObject, grid_handler:Object, bc:int, br:int):void {
			go.myGridHandler = grid_handler;
			
			go.is_removed = false;
			
			if (!go.is_attached) {
				grid_handler.sprite.addChild(go.sprite);
			}
			
			for (var j:int = -1; j < 2; j++) {
				for (var k:int = -1; k < 2; k++) {
					var grid_box:Array = getGridBox(grid_handler.col, grid_handler.row, bc+j, br+k);
					go.addToGridBox(grid_box);
				}
			}
		}
		
		public function removeFromGrid(go:GridObject, attach_source_remove:Boolean = true):void {
			// remove from the linked objects if any
			removeFromGridBoxes(go);
			
			if (go.is_attached && attach_source_remove) {
				// remove from source
				var i:int = go.attach_source.attached.indexOf(go);
				if (i >= 0) {
					go.attach_source.attached.splice(i, 1);
				}
			}
			
			// remove the attached, but don't remove from source
			for (i = 0; i < go.attached.length; ++i) {
				removeFromGrid(go.attached[i], false);
			}
		}
		
		// removes from a grid also
		public function removeFromGridBoxes(go:GridObject):void {
			var grid_handler:Object = getGridFromObject(go);
			
			if (!go.is_attached) {
				grid_handler.sprite.removeChild(go.sprite);
			}
			
			go.removeFromGridBoxes();
			
			go.myGridHandler = null;
			
			go.is_removed = true;
		}
		
		// Coord System
		// ViewCoords -> WorldCoords -> LocalCoords
		
		// local coords
		public function moveObjectWorldTo(go:GridObject, world_point:Point, is_update_sprite:Boolean = true):void {
			var world_point2:Point = getWorldFromObject(go);
			moveObject(go, world_point.subtract(world_point2), is_update_sprite);
		}
		
		// world coords
		public function moveObject(go:GridObject, dv:Point, is_update_sprite:Boolean = true):void {
			// don't do anything if we don't move
			if (dv.length == 0) {
				return;
			}
			
			// get our source grid
			var world_point:Point = getWorldFromObject(go);
			var grid_handler_s:Object = getGridFromWorld(world_point);
			var scol:int = -1;
			var srow:int = -1;
			if (grid_handler_s) {
				
				var local_point:Point = getLocalFromObject(go);
				scol = int(local_point.x / c_grid_width);
				srow = int(local_point.y / c_grid_height);
			}
			
			// update world
			world_point = world_point.add(dv);
			
			// init are new vars
			var new_local_point:Point = getLocalFromObject(go);
			
			// get our destination grid using new point
			var grid_handler_d:Object = getGridFromWorld(world_point);
			var dcol:int = -1;
			var drow:int = -1;
			
			if (grid_handler_d) {
				new_local_point = worldToLocal(grid_handler_d, world_point);
				dcol = int(new_local_point.x / c_grid_width);
				drow = int(new_local_point.y / c_grid_height);
			} 
			
			// check if we crossed a grid box or grid:
			if ((scol != dcol) || (srow != drow) || (grid_handler_s != grid_handler_d)) {
				// 1) check if we need to remove from grid boxes.
				if (grid_handler_s) {
					// remove from grid boxes
					removeFromGridBoxes(go);
					
					if (!grid_handler_d) {
						// update grid object to point off grid
						var new_grid_col:int = getGridColFromWorld(world_point);
						var new_grid_row:int = getGridRowFromWorld(world_point);
						
						var grid_world_point:Point = getGridPointFromColRow(new_grid_col, new_grid_row);
						new_local_point = world_point.subtract(grid_world_point);
						
						// we fell off the grid so attempt to make an entry
						// note: we don't make entries for attached objects, unless the source falls off too
						leaveObjectFromGridWorld(go, new_local_point, new_grid_col, new_grid_row);
					}
				}
				
				// 1) check if we need to add to new grid boxes.
				if (grid_handler_d) {
					// update grid object
					go.setLocalPoint(new_local_point);
					
					// add to grid boxes
					addToGridBoxes(go, grid_handler_d, dcol, drow);
					
					if (grid_handler_d != grid_handler_s) {
						go.checkGridUnder(grid_handler_d);
					}
				}
			} else {
				// just move
				go.setLocalPoint(new_local_point);
			}
			
			if (is_update_sprite) {
				// update our sprites
				updateSpritePosition(go);
			}
			
			
			for (var i:int = 0; i < go.attached.length; ++i) {
				updateAttachedPosition(go.attached[i]);
			}
			for (i = 0; i < go.attached.length; ++i) {
				checkAttachedCollision(go.attached[i]);
			}
			
		}
		
		public function updateSpritePosition(go:GridObject):void {
			if (!go.is_attached && isObjectOnWorld(go)) {
				var local_point:Point = getLocalFromObject(go);
				go.sprite.x = local_point.x;
				go.sprite.y = local_point.y;
				
			} else if (go.is_attached) {
				var dv:Point = getDistance(go.attach_source, go);
				var angle:Number = Math.atan2(dv.y, dv.x) * 180/Math.PI - 90;
				
				go.sprite.x = 0;
				go.sprite.y = dv.length;
				go.attached_point = dv;
				go.attach_socket.rotation = angle;
			}
		}
		
		
		public function updateAttachedPosition(go:GridObject):void {
			if (go.is_attached) {
				var world_point_to:Point = getWorldFromObject(go.attach_source).add(go.attached_point);
				moveObjectWorldTo(go, world_point_to, false);
			}
		}
		
		public function checkAttachedCollision(go:GridObject):void {
			if (go.checkAreaEnabled()) {
				getCollisionResult_Circle(go, new Point(0, 0), go.mass);
			}
		}
		
		
		public function getGridObjectsFromObject(go:GridObject):Array {
			return go.getGridObjectsSet();
		}
		
		public function getGridBoxFromObject(go:GridObject):Array {
			var local_point:Point = getLocalFromObject(go);
			var col:int = local_point.x / c_grid_width;
			var row:int = local_point.y / c_grid_height;
			
			var gobjects:Array = getGridBox(go.getGridCol(), go.getGridRow(), col, row);
			if (gobjects == null) {
				throw( new Error("getGridBoxFromObject: gobjects null: " + col + ", " + row) );
			}
			
			return gobjects;
		}
		
		public function handleTooClose(go:GridObject):void {
			getCollisionResult_Circle(go, new Point(0, 0));
		}
		
		public function updateBoundingRadius(go:GridObject, bR:Number):void {
			go.boundingRadius = bR;
			handleTooClose(go);
		}
		
		public function updateMass(go:GridObject, m:Number):void {
			go.mass = m;
		}
		
		public function updateMoveMaxSpeed(go:GridObject, ms:Number):void {
			go.move_max_speed = ms;
		}
		
		public function canMoveToWorldWithoutCollision(go:GridObject, world_point:Point):Boolean {
			var grid_handler:Object = getGridFromWorld(world_point);
			if (grid_handler == null) {
				trace("canMoveToWorldWithoutCollision: grid_handler is null: " + world_point);
				return false;
			}
			
			var local_point:Point = worldToLocal(grid_handler, world_point);
			var row:int = local_point.x / c_grid_width;
			var col:int = local_point.y / c_grid_height;
			var gobjects:Array = getGridBox(grid_handler.col, grid_handler.row, row, col);
			if (gobjects == null) {
				trace("canMoveToWorldWithoutCollision: gobjects null: " + grid_handler.col + ", " + grid_handler.row + ", " + row + ", " + col);
				return false;
			}
			
			for (var i:int = 0; i < gobjects.length; i++) {
				var go2:GridObject = gobjects[i];
				if ( (go != go2) && (go2.type == GridObject.c_type_prot) ) {
					var world_point2:Point = getWorldFromObject(go2);
					var dv:Point = world_point2.subtract(world_point);
					
					if (dv.length <= go.boundingRadius + go2.boundingRadius) {
						return false;
					}
				}
			}
			return true;
		}
		
		// rotate in arc distance
		public function getRotateCollisionResult_Circle(go:GridObject, ad:Number):Point {
			var rv:Point = new Point(-go.attached_point.y, go.attached_point.x);
			rv.normalize(ad);
			rv = rv.add(go.attached_point);
			
			var angle1:Number = Math.atan2(go.attached_point.y, go.attached_point.x) * 180/Math.PI - 90;
			var angle2:Number = Math.atan2(rv.y, rv.x) * 180/Math.PI - 90; 
			var dr:Number = angle2 - angle1;
			
			var trans:Matrix = new Matrix();
			trans.rotate(dr * Math.PI/180);
			var new_attached_point:Point = trans.transformPoint(go.attached_point);
			
			var world_point1:Point = getWorldFromObject(go.attach_source).add(go.attached_point);
			var world_point2:Point = getWorldFromObject(go.attach_source).add(new_attached_point);
			var dv:Point = world_point2.subtract(world_point1);
			
			return getCollisionResult_Circle(go, dv);
		}
		
		public function getDistance(go:GridObject, go2:GridObject):Point {
			var world_point1:Point = getWorldFromObject(go);
			var world_point2:Point = getWorldFromObject(go2);
			
			return world_point2.subtract(world_point1);
		}
		
		public function getCollisionResult_Circle(go:GridObject, dv:Point, amass:Number = 0, rcount:int = 0):Point {
			var new_dv:Point = dv; // resulting displacement
			
			go.is_moving = true; // used to prevent crazy situations
			
			// get our grid objects around the object
			var gobjects:Array = getGridObjectsFromObject(go);
			
			var contact:Object = getNextContact(gobjects, go, new_dv);
			while(contact) {
				new_dv = new_dv.add( calculateDistribution(contact, amass, rcount) );
				contact = getNextContact(gobjects, go, new_dv, contact.index+1);
			}
			
			if (new_dv.length > Number.MIN_VALUE) {
				// move our object
				
				moveObject(go, new_dv);
				if (go.is_attached) {
					go.checkMoved();
				}
			}
			
			go.is_moving = false; // reset our flag
			
			return new_dv;
		}
		
		public function calculateDistribution(contact:Object, amass:Number, rcount:int):Point {
			var go:GridObject = contact.object1;
			var go2:GridObject = contact.object2;
			var distv:Point = contact.overlap;
			
			if ( (go2.mass < GridObject.c_max_mass) && 
				(go.attach_source != go2) &&
				(rcount <= c_recursion_threshold) ) {
				
				// distribute weight
				if (go2.mass <= GridObject.c_min_mass) {
					distv = new Point(0, 0);
				} else {
					distv = distributeCollisionWeight(contact, amass);
				}
				
				// apply to object2 and get actual value
				var dv_applied:Point = distv.subtract(contact.overlap);
				if (dv_applied.length > Number.MIN_VALUE) {
					dv_applied = getCollisionResult_Circle(go2, dv_applied, amass + go.mass, rcount+1);
					distv = dv_applied.add(contact.overlap);
				}
			}
			
			return distv;
		}
		
		public function distributeCollisionWeight(contact:Object, amass:Number):Point {
			var w1:Number = contact.object1.mass + amass;
			var w2:Number = contact.object2.mass;
			
			var r:Number = 1.0;
			if ( (w1 + w2) > Number.MIN_VALUE ) {
				r = w1/(w1+w2);
			}
			
			return Point.interpolate( new Point(0,0), contact.overlap, r );
		} 
		
		public function getNextContact(gobjects:Array, go:GridObject, dv:Point, start_index:int = 0):Object {
			if (gobjects == null) {
				return null;
			}
			
			var world_point:Point = getWorldFromObject(go).add(dv);
			
			for (var i:int = start_index; i < gobjects.length; ++i) {
				var go2:GridObject = gobjects[i];
				if ( (go != go2) && (!go2.is_removed) && (!go2.is_moving) && (go2.checkAreaEnabled()) ) {
					var contact:Object = calculateContact(go, world_point, go2, getWorldFromObject(go2), i);
					if (contact != null) {
						if ( !handleArea(go, go2) && !handleAbsorb(go, go2) ) {
							return contact;
						}
					}
				}
			}
			
			return null;
		}
		
		public function calculateContact(go:GridObject, world_point1:Point, go2:GridObject, world_point2:Point, index:int = -1):Object {
			var dv:Point = world_point2.subtract(world_point1);
			var ds:Number = dv.x * dv.x + dv.y * dv.y;
			var sr:Number = go.boundingRadius + go2.boundingRadius;
			
			if ( (ds > Number.MIN_VALUE) && (ds <= sr * sr) ) {
				// we hit!
				var dist:Number = Math.sqrt(ds);
				
				var a:Number = 1.0 / dist;
				var ndv:Point = new Point(a * dv.x, a * dv.y);
				var s:Number = dist - sr;
				
				// make sure it's not a weak hit (too small to care)
				if (s <= -Number.MIN_VALUE) {
					var contact:Object = new Object();
					contact.overlap = new Point(s * ndv.x, s * ndv.y);
					contact.object1 = go;
					contact.object2 = go2;
					contact.dv = dv;
					contact.index = index;
					
					return contact;
				}
			}
			
			return null;
		}
		
		public function getReverseContact(contact:Object):Object {
			var rcontact:Object = new Object();
			rcontact.object1 = contact.object2;
			rcontact.object2 = contact.object1;
			rcontact.overlap = new Point(0, 0);
			rcontact.overlap = rcontact.overlap.subtract(contact.overlap);
			rcontact.index = contact.index;
			return rcontact;
		}
		
		public function handleArea(go:Object, go2:Object, second_call:Boolean = false):Boolean {
			if ( (go.type != GridObject.c_type_area) && (go2.type == GridObject.c_type_area) && 
			!go.isAlreadyInArea(go2.area) && (go != go2.attach_source) ) {
				go2.area.addGridObjectEnter(go);
				return true;
			} else if (!second_call) {
				return handleArea(go2, go, true);
			}
			return (go.type == GridObject.c_type_area) || (go2.type == GridObject.c_type_area);
		}
		
		public function handleAbsorb(go:GridObject, go2:GridObject, second_call:Boolean = false):Boolean {
			if ( go.canAbsorbObject(go2) ) {
				go.absorb(go2);
				return true;
			} else if (!second_call) {
				return handleAbsorb(go2, go, true);
			}
			
			return false;
		}
		
		// View Coords -> World Coords -> Local Coords
		public function getGridFromView(p:Point):Object {
			return getGridFromWorld( viewToWorld(p) );
		}
		
		public function getGridFromWorld(p:Point):Object {
			if (isPointOnWorld(p)) {
				var grid_col:int = p.x / gridWidthPixel;
				var grid_row:int = p.y / gridHeightPixel;
				
				return getGrid(grid_col, grid_row);
			}
			
			return null;
		}
		
		public function getGridFromSprite(s:Sprite):Object {
			var sp:* = s.parent;
			var spp:* = sp.parent;
			return getGridFromWorld(new Point(s.x + sp.x + spp.x, s.y + sp.y + spp.y));
		}
		
		public function getGridColFromWorld(p:Point):int {
			return int(p.x / gridWidthPixel);
		}
		
		public function getGridRowFromWorld(p:Point):int {
			return int(p.y / gridHeightPixel);
		}
		
		public function getGridPointFromColRow(gc:int, gr:int):Point {
			return new Point(gc * gridWidthPixel, gr * gridHeightPixel);
		}
		
		public function isObjectOnWorld(go:GridObject):Boolean {
			return (go.myGridHandler != null)
		}
		
		public function isPointOnWorld(p:Point):Boolean {
			return ( (p.x >= 0) && (p.x < (currentLastEndPoint.x - currentFirstGridPoint.x) ) && 
			(p.y >= 0) && (p.y < (currentLastEndPoint.y - currentFirstGridPoint.y)) );
		}
		
		public function isObjectOnGrid(go:GridObject, grid_handler:Object):Boolean {
			return ( grid_handler == getGridFromObject(go) );
		}
		
		// get a grid object within a radius at a world point
		public function getNearestObjectInRadius(go:GridObject, radius:Number, object_type:uint, second_type:uint):GridObject {
			// first get grid boxes in radius
			var world_point:Point = getWorldFromObject(go);
			var grid_handler:Object = getGridFromObject(go);
			var gcol:int = grid_handler.col;
			var grow:int = grid_handler.row;
			
			var local_point:Point = go.getLocalPoint();
			var bcol:int = int(local_point.x/c_grid_width);
			var brow:int = int(local_point.y/c_grid_height);
			
			var bcol_width:int = int(radius/c_grid_width);
			var brow_height:int = int(radius/c_grid_height);
			
			var tl_bcol:int = bcol - bcol_width;
			var tl_brow:int = brow - brow_height;
			
			var br_bcol:int = bcol + bcol_width;
			var br_brow:int = brow + brow_height;
			
			var gridBoxes:Array = new Array();
			while ( (tl_bcol != br_bcol) || (tl_brow != br_brow) ) {
				var gridBox:Array = getGridBox(gcol, grow, tl_bcol, tl_brow);
				if (gridBox) {
					gridBoxes.push(gridBox);
				}
				tl_bcol++;
				if (tl_bcol > br_bcol) {
					tl_bcol = bcol - bcol_width;
					tl_brow++;
				}
			}
			
			// second check each object in each box
			var checked_objects:Array = new Array();
			var min_radius:Number = radius;
			var nearest_object:GridObject = null;
			while (gridBoxes.length > 0) {
				gridBox = gridBoxes.pop();
				for (var i:int = 0; i < gridBox.length; ++i) {
					var go2:GridObject = gridBox[i];
					
					if ( !go2.temp_grid_box_selected && !go2.is_removed && 
					(go2.type == object_type) && (go2.getSecondaryType() == second_type) ) {
						go2.temp_grid_box_selected = true;
						checked_objects.push(go2);
						
						var dv:Point = getDistance(go, go2);
						if (dv.length <= min_radius) {
							min_radius = dv.length;
							nearest_object = go2;
						}
					}
				}
			}
			
			// reset checked objects
			while(checked_objects.length > 0) {
				checked_objects.pop().temp_grid_box_selected = false;
			}
			
			return nearest_object;
		}
		
		// from a vector
		public function moveGrids(dv:Point):void {
			x = x + dv.x;
			y = y + dv.y;
			
			myBackground.updateMove(dv);
		}
		
		public function checkGridShiftFromObject(go:GridObject):Array {
			return checkGridShiftFromWorld( getWorldFromObject(go) );
		}
		
		public function checkGridShiftFromWorld(world_point:Point):Array {
			// we need a point from the center to the world_point
			var focus_point:Point = world_point.subtract(currentWorldCenter);
			
			var new_grids:Array = new Array();
			
			var shift_grids:Point = new Point(0, 0);
			if (focus_point.x >= gridWidthPixel) {
				x += gridWidthPixel;
				new_grids = new_grids.concat(shiftGridsLeft());
			} else if (focus_point.x < -gridWidthPixel) {
				x -= gridWidthPixel;
				new_grids = new_grids.concat(shiftGridsRight());
			}
			
			if (focus_point.y >= gridHeightPixel) {
				y += gridHeightPixel;
				new_grids = new_grids.concat(shiftGridsUp());
			} else if (focus_point.y < -gridHeightPixel) {
				y -= gridHeightPixel;
				new_grids = new_grids.concat(shiftGridsDown());
			}
			
			for (var i:int = 0; i < new_grids.length; i++) {
				var grid_handler:Object = new_grids[i];
				myWorldMap.updateGrid(this, grid_handler);
			}
			
			return new_grids;
		}
		
		// shifts the grids left and returns any new grids created
		public function shiftGridsLeft():Array {
			var new_grids:Array = new Array();
			
			// empty grids before we shift
			for (var r:int = 0; r < c_view_grids_high; r++) {
				emptyGrid(0, r);
			}
			
			// remove grids
			for (r = 0; r < c_view_grids_high; r++) {
				removeGrid(0, r);
			}
			
			// shift grid objects
			myWorldMap.moveCurrentCol(1);
			for (r = 0; r < c_view_grids_high; r++) {
				for (var i:int = 0; i < c_view_grids_wide-1; i++) {
					var pos:int = i+r*c_view_grids_wide;
					var old_pos:int = (i+1)+r*c_view_grids_wide;
					myGrids[pos] = myGrids[old_pos];
					myGrids[pos].sprite.x -= gridWidthPixel;
					myGrids[pos].col -= 1;
				}
				
				var first_pos:int = (c_view_grids_wide-1);
				var new_grid:Object = createGrid(first_pos, r);
				myGrids[first_pos+r*c_view_grids_wide] = new_grid;
				new_grids.push(new_grid);
			}
			
			return new_grids;
		}
		
		public function shiftGridsRight():Array {
			var new_grids:Array = new Array();
			
			// remove grids before we shift
			for (var r:int = 0; r < c_view_grids_high; r++) {
				emptyGrid((c_view_grids_wide-1), r);
			}
			
			// remove grids before we shift
			for (r = 0; r < c_view_grids_high; r++) {
				removeGrid((c_view_grids_wide-1), r);
			}
			
			// shift all grids one to the right
			myWorldMap.moveCurrentCol(-1);
			for (r = 0; r < c_view_grids_high; r++) {
				for (var i:int = c_view_grids_wide-1; i > 0; i--) {
					var pos:int = i+r*c_view_grids_wide;
					var old_pos:int = (i-1)+r*c_view_grids_wide;
					myGrids[pos] = myGrids[old_pos];
					myGrids[pos].sprite.x += gridWidthPixel;
					myGrids[pos].col += 1;
				}
				var first_pos:int = 0;
				var new_grid:Object = createGrid(first_pos, r);
				myGrids[first_pos+r*c_view_grids_wide] = new_grid;
				new_grids.push(new_grid);
			}
			
			return new_grids;
		}
		
		public function shiftGridsUp():Array {
			var new_grids:Array = new Array();
			
			// remove grids before we shift
			for (var c:int = 0; c < c_view_grids_wide; c++) {
				emptyGrid(c, 0);
			}
			for (c = 0; c < c_view_grids_wide; c++) {
				removeGrid(c, 0);
			}
			
			// shift all grids up one row
			myWorldMap.moveCurrentRow(1);
			for (c = 0; c < c_view_grids_wide; c++) {
				for (var i:int = 0; i < c_view_grids_high-1; i++) {
					var pos:int = c+i*c_view_grids_wide;
					var old_pos:int = c+(i+1)*c_view_grids_wide;
					myGrids[pos] = myGrids[old_pos];
					myGrids[pos].sprite.y -= gridHeightPixel;
					myGrids[pos].row -= 1;
				}
				var first_pos:int = c_view_grids_high-1;
				var new_grid:Object = createGrid(c, first_pos);
				myGrids[c+first_pos*c_view_grids_wide] = new_grid;
				new_grids.push(new_grid);
			}
			
			return new_grids;
		}
		
		public function shiftGridsDown():Array {
			var new_grids:Array = new Array();
			
			// remove grids before we shift
			for (var c:int = 0; c < c_view_grids_wide; c++) {
				emptyGrid(c, c_view_grids_high-1);
			}
			for (c = 0; c < c_view_grids_wide; c++) {
				removeGrid(c, c_view_grids_high-1);
			}
			
			// shift all grids up one row
			myWorldMap.moveCurrentRow(-1);
			for (c = 0; c < c_view_grids_wide; c++) {
				for (var i:int = c_view_grids_high-1; i > 0; i--) {
					var pos:int = c+i*c_view_grids_wide;
					var old_pos:int = c+(i-1)*c_view_grids_wide;
					myGrids[pos] = myGrids[old_pos];
					myGrids[pos].sprite.y += gridHeightPixel;
					myGrids[pos].row += 1;
				}
				// add new grids
				var first_pos:int = 0;
				var new_grid:Object = createGrid(c, first_pos);
				myGrids[c+first_pos*c_view_grids_wide] = new_grid;
				new_grids.push(new_grid);
			}
			
			return new_grids;
		}
		
		public function emptyGrid(c:int, r:int, is_add_world_map:Boolean = true):void {
			var grid_handler:Object = getGrid(c, r);
			if (grid_handler == null) {
				throw( new Error("removeGrid: grid_handler is null: " + c + ", " + r) );
				return;
			}
			
			for (var i:int = 0; i < grid_handler.grid.length; i++) {
				for (var j:int = 0; j < grid_handler.grid[i].length; j++) {
					var go:GridObject = grid_handler.grid[i][j];
					if ( !go.is_removed && isObjectOnGrid(go, grid_handler) ) {
						leaveObjectFromGridWorld( go, getLocalFromObject(go), go.getGridCol(), go.getGridRow(), is_add_world_map );
					}
				}
			}
			
			// explosions
			while (grid_handler.explosions.length > 0) {
				grid_handler.sprite.removeChild( grid_handler.explosions.pop() );
			}
		}
		
		public function removeGrid(c:int, r:int):void {
			var grid_handler:Object = getGrid(c, r);
			if (grid_handler == null) {
				throw( new Error("removeGrid: grid_handler is null: " + c + ", " + r) );
				return;
			}
			
			// here we don't really remove all objects, just the containers
			for (var i:int = 0; i < grid_handler.grid.length; i++) {
				delete(grid_handler.grid[i]);
			}
			delete(grid_handler.grid);
			removeChild(grid_handler.sprite);
			delete(myGrids[ grid_handler.col + (grid_handler.row * c_view_grids_wide) ]);
		}
		
		/*******************************
		* This function should remove the object from the grid world.
		* Note: We can't remove an object that is attached until the parent leaves.
		* Also, we have to make sure of the location of the object if it moves some distance off the grid
		********************************/
		public function leaveObjectFromGridWorld(go:GridObject, local_point:Point, gc:int, gr:int, is_add_world_map:Boolean = true):void {
			if (!go.is_attached) {
				if (is_add_world_map && go.isWorldMapLevel(myWorldMap)) {
					myWorldMap.addGridObject(go, local_point, gc, gr);
				}
				
				// remove all, even attached
				removeAllAttached(go);
			}
		}
		
		public function addExplosion(gc:int, gr:int, local_point:Point, radius:Number = 9.0):void {
			var explosion_socket:Sprite = new Sprite();
			explosion_socket.x = local_point.x;
			explosion_socket.y = local_point.y;
			
			var phys_explosion:PhysExplosion = new PhysExplosion();
			phys_explosion.scaleX = radius/9.0;
			phys_explosion.scaleY = radius/9.0;
			phys_explosion.gotoAndPlay(1);
			explosion_socket.addChild(phys_explosion);
			
			var grid_handler:Object = getGrid(gc, gr);
			grid_handler.sprite.addChild(explosion_socket);
			
			grid_handler.explosions.push(explosion_socket);
		}
		
	}
}