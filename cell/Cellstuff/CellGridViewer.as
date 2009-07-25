/*
 *
 * @author Shaun Pauley
 * @version 1.0
 */
package CellStuff {
	
	import flash.display.Sprite;
	
	import flash.geom.Point;
	
	public class CellGridViewer extends Sprite {
		
		private var m_viewCover:CellViewCover;
		
		/* Constructor
		*/
		public function CellGridViewer(viewerData:Object):void {
			
			x = 0;
			y = 0;
			
			viewerData.coverData.viewer = this;
			
			m_viewCover = new CellViewCover(viewerData.coverData);
			
		}
		
		public function GrowViewer(dx:Number, dy:Number):void {
			m_viewCover.GrowCover(dx, dy);
		}
		
		public function ShrinkViewer(dx:Number, dy:Number):void {
			m_viewCover.ShrinkCover(dx, dy);
		}
		
		public function MoveViewer(dx:Number, dy:Number):void {
			m_viewCover.MoveCover(dx, dy);
		}
		
		public function ToString():String {
			return m_viewCover.ToString();
		}
		
		/* CreateViewerDataObject
		*/
		public static function CreateViewerData():Object {
			return {coverData:CellViewCover.CreateViewCoverData()};
		}
		
		// unit tests
		public static function UnitTest(sprite:Sprite):void {
			trace("***BEGIN CellGridViewer UNIT TEST***");
			var testViewer:CellGridViewer = new CellGridViewer( CreateViewerData() );
			sprite.addChild(testViewer);
			trace("TEST 1) INIT");
			trace(testViewer.ToString());
			trace("***END CellGridViewer UNIT TEST***");
		}
	}
}