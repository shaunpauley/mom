package CellStuff {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	import flash.geom.Point;
	
	import flash.events.Event;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	
	public class CellTextHandler extends MovieClip{
		
		public var myGrid:CellGridDisplay;
		public var myWorldMap:CellWorldMap;
		public var myCell:CellSingle_Player;
		
		public var myTexts:Array;
		
		public var m_middle_x:Number;
		public var m_middle_y:Number;
		
		
		public static const c_text_type_normal:uint		= 0x000000;
		public static const c_text_type_red_large:uint		= 0x000001;
		
		public static const c_text_min_count:int = 2500;  // milliseconds
		
		public static const c_min_text_radius:Number = 230;
		
		public function CellTextHandler(grid:CellGridDisplay, map:CellWorldMap, cell_player:CellSingle_Player, middle_x:Number, middle_y:Number) {
			myGrid = grid;
			myWorldMap = map;
			myCell = cell_player;
			
			myTexts = new Array();
			
			m_middle_x = middle_x;
			m_middle_y = middle_y;
			
			x = m_middle_x;
			y = m_middle_y;
		}
		
		public function attachNewTextToPlayer(texts:Array, text_type:uint, is_repeat:Boolean = false):void {
			attachNewTextToObject(myCell.myGridObject, texts, text_type, is_repeat);
		}
		
		public function attachNewTextToObject(go:GridObject, texts:Array, text_type:uint, is_repeat:Boolean = false):void {
			if (go.is_removed) {
				return;
			}
			
			if (go.text_object) {
				if (go.text_object.texts == texts) {
					// we are already displaying these texts
					return;
				}
				
				// remove first
				var i:int = myTexts.indexOf(go.text_object);
				if (i >= 0) {
					removeTextIndex(i);
				}
			}
			
			// create our text object
			var text_object:Object = newTextObject(texts, text_type, is_repeat);
			text_object.grid_object = go;
			text_object.map_entry = null;
			addChild(text_object.socket);
			
			// location
			var view_point1:Point = new Point(0, 0);
			var view_point2:Point = myGrid.worldToView( myGrid.getWorldFromObject(go) );
			var dv:Point = view_point2.subtract( view_point1 );
			
			updateTextLocation(text_object, dv);
			
			text_object.text_field.text = text_object.texts[text_object.text_index];
			
			go.text_object = text_object;
			
			myTexts.push(text_object);
		}
		
		public function attachNewTextToMapEntry(map_entry:Object, texts:Array, text_type:uint, is_repeat:Boolean = false):void {
			
			if (map_entry.text_object) {
				if (map_entry.text_object.texts == texts) {
					// we are already displaying these texts
					return;
				}
				
				// remove first
				var i:int = myTexts.indexOf(map_entry.text_object);
				if (i >= 0) {
					removeTextIndex(i);
				}
			}
			
			// create our text object
			var text_object:Object = newTextObject(texts, text_type, is_repeat);
			text_object.grid_object = null;
			text_object.map_entry = map_entry;
			addChild(text_object.socket);
			
			// location
			
			var view_point1:Point = new Point(0, 0);
			
			var col:int = map_entry.col - myWorldMap.m_current_col;
			var row:int = map_entry.row - myWorldMap.m_current_row;
			var world_point:Point = myGrid.getWorldFromLocal(col, row, text_object.map_entry.local_point);
			var view_point2:Point = myGrid.worldToView(world_point);
			
			var dv:Point = view_point2.subtract( view_point1 );
			
			updateTextLocation(text_object, dv);
			
			// set text
			text_object.text_field.text = text_object.texts[text_object.text_index];
			
			map_entry.text_object = text_object;
			
			myTexts.push(text_object);
		}
		
		public function newTextObject(texts:Array, text_type:uint, is_repeat:Boolean = false):Object {
			
			var text_object:Object = new Object();
			text_object.texts = texts;
			text_object.text_type = text_type;
			text_object.text_index = 0;
			text_object.next_count = getNewCount();
			text_object.is_repeat = is_repeat;
			text_object.is_removed = false;
			text_object.text_field = newTextField(text_type);
			text_object.socket = new Sprite();
			text_object.socket.addChild(text_object.text_field);
			
			return text_object;
		}
		
		public function getNewCount():int {
			return int(c_text_min_count * (CellWorld.c_fps/1000));
		}
		
		public function newTextField(text_type:uint):TextField {
			var text_field:TextField = new TextField();
			text_field.x = 0;
			text_field.y = 0;
			text_field.autoSize = TextFieldAutoSize.CENTER;
			text_field.antiAliasType = AntiAliasType.ADVANCED;
			text_field.blendMode = BlendMode.LAYER;
			
			updateTextFormat(text_field, text_type);
			
			text_field.selectable = false;
			text_field.text = "";
			
			return text_field;
		}
		
		public function updateTextFormat(text_field:TextField, text_type:uint):void {
			var tf:TextFormat = text_field.defaultTextFormat;
			
			switch (text_type) {
				case c_text_type_red_large:
					tf.font = "Arial";
					tf.bold = true;
					tf.align = "center";
					tf.color = 0x760101;
					tf.size = 30;
					break;
				case c_text_type_normal:
				default:
					tf.font = "Arial";
					tf.bold = true;
					tf.align = "center";
					tf.color = 0x000000;
					tf.size = 20;
					break;
			}
			text_field.defaultTextFormat = tf;
			
		}
		
		public function updateTextLocation(text_object:Object, dv:Point):void {
			
			// check if too far
			var d:Number = dv.length;
			if (d > c_min_text_radius) {
				
				var a:Number = c_min_text_radius/d;
				if (a < 0.2) {
					a = 0.2;
				}
				text_object.text_field.alpha = a;
				text_object.text_field.scaleX = a;
				text_object.text_field.scaleY = a;
				
				dv.normalize(c_min_text_radius);
				d = c_min_text_radius;
				
			} else {
				
				a = 1.0;
				text_object.text_field.alpha = a;
				text_object.text_field.scaleX = a;
				text_object.text_field.scaleY = a;
				
			}
			
			text_object.socket.x = dv.x;
			text_object.socket.y = dv.y;
			
		}
		
		public function handleTexts():void {
			var remove:Array = new Array();
			var i:int = 0;
			for each (var text_object:Object in myTexts) {
				if (text_object.is_removed) {
					remove.push(i);
				} else {
					updateText(text_object);
				}
				++i;
			}
			
			//throw ( new Error("here") );
			
			while (remove.length > 0) {
				removeTextIndex( remove.pop() );
			}
		}
		
		public function updateText(text_object:Object):void {
			
			// text
			if (text_object.next_count <= 0) {
				++text_object.text_index;
				if (text_object.text_index < text_object.texts.length) {
					
				} else if (text_object.is_repeat) {
					text_object.text_index = 0;
				} else {
					// remove texts
					text_object.is_removed = true;
					return;
				}
				
				text_object.text_field.text = text_object.texts[text_object.text_index];
				text_object.next_count = getNewCount();
			} else {
				--text_object.next_count;
			}
			
			// location
			var view_point2:Point = null;
			if ( (text_object.grid_object) && (!text_object.grid_object.is_removed) ) {
				
				view_point2 = myGrid.worldToView( myGrid.getWorldFromObject(text_object.grid_object) );
				
			} else if (text_object.map_entry) {
				
				// find view point from map and note that the object is outside of the grid
				var col:int = text_object.map_entry.col - myWorldMap.m_current_col;
				var row:int = text_object.map_entry.row - myWorldMap.m_current_row;
				var world_point:Point = myGrid.getWorldFromLocal(col, row, text_object.map_entry.local_point);
				view_point2 = myGrid.worldToView(world_point);
				
			} else {
				// remove this thing that has no source
				text_object.is_removed = true;
				return;
				
			}
			
			var view_point1:Point = new Point(0, 0);
			var dv:Point = view_point2.subtract( view_point1 );
			
			updateTextLocation(text_object, dv);
		}
		
		public function updateNewWorldMap_TextObjects():void {
			// remove old map entries first
			var remove:Array = new Array();
			var i:int = 0;
			for each (var text_object:Object in myTexts) {
				if (text_object.map_entry) {
					remove.push(i);
				}
				++i;
			}
			
			while (remove.length > 0) {
				removeTextIndex(remove.pop());
			}
			
			// add new
			for each (var text_record:Object in myWorldMap.myTextRecords) {
				if (text_record.grid_object) {
					attachNewTextToObject(text_record.grid_object, text_record.texts, text_record.text_type, text_record.text_repeat);
				} else {
					attachNewTextToMapEntry(text_record.map_entry, text_record.texts, text_record.text_type, text_record.text_repeat);
				}
			}
			
		}
		
		
		public function removeTextIndex(i:int):void {
			
			var text_object:Object = myTexts[i];
			
			removeChild(text_object.socket);
			
			if (text_object.grid_object) {
				text_object.grid_object.text_object = null;
			}
			text_object.grid_object = null;
			
			if (text_object.map_entry) {
				text_object.map_entry.text_object = null;
			}
			text_object.map_entry = null;
			
			text_object.is_removed = true;
			
			myTexts.splice(i, 1);
		}
	}
	
}