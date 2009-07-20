package CellStuff {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	
	public class CellPrit_Question extends CellPrit{
		
		public static const c_radius_area_text:Number = 20.0;
		
		public function CellPrit_Question(grid:CellGridDisplay, map_entry:Object) {
			
			super(grid, map_entry);
		}
		
		public override function physPrit():MovieClip {
			var prit:MovieClip = new PhysPrit_Question();
			prit.gotoAndPlay(1);
			return prit;
		}
		
		
		/* World Map */
		/*
		public override function createAreaMapEntry():Object {
			return CellArea_TextDisplay.updateMapEntry_New( new Object(), c_radius_area_text, "Question!!!" );
		}
		*/
		
		public static function updateMapEntry_New(map_entry:Object):Object {
			map_entry = CellPrit.updateMapEntry_New(map_entry);
			
			map_entry.prit_type = c_type_question;
			
			map_entry.mass = 1.1;
			map_entry.radius = 9.0;
			
			map_entry.can_be_attacked = false;
			
			return map_entry;
		}
		
	}
}