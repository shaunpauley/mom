package CellStuff {
	
	import flash.geom.Point;
	
	public class CellArea_Report extends CellArea {
		
		public function CellArea_Report(grid:CellGridDisplay, map_entry:Object) {
			super(grid, map_entry);
		}
		
		/* Perform Area Action */
		public override function performAreaAction_Enter(go:GridObject):void {
			myGridObject.attach_source.report(GridObject.c_report_type_enter, {go:go});
		}
		
		public override function performAreaAction_Update(go:GridObject, overlap:Point):void {
			myGridObject.attach_source.report(GridObject.c_report_type_update, {go:go, overlap:overlap});
		}
		
		public override function performAreaAction_Leave(go:GridObject):void {
			myGridObject.attach_source.report(GridObject.c_report_type_leave, {go:go});
		}
		
		/* World Map */
		public override function updateMapEntry(map_entry:Object):Object {
			map_entry = super.updateMapEntry(map_entry);
			return map_entry;
		}
		
		public static function updateMapEntry_New(map_entry:Object, radius:Number):Object {
			map_entry = CellArea.updateMapEntry_New(map_entry);
			
			map_entry.area_type = c_type_report;
			map_entry.radius = radius;
			
			return map_entry;
		}
		
	}
}