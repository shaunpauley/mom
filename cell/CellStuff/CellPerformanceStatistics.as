package CellStuff {
	
	import flash.display.Sprite;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import flash.utils.getTimer;
   
	import flash.events.Event;

	public class CellPerformanceStatistics extends Sprite {
		
		// grid
		public var m_numGridCells:int;
		public var m_numGridCellsOccupiedByObjects:int;
		public var m_numGridCellsOccupiedByCovers:int;
		public var m_numGridColumns:int;
		public var m_numGridRows:int;
		public var m_numActiveCovers:int;
		public var m_numActiveCoverCells:int;
		public var m_numStockGridCells:int;
		public var m_numStockCovers:int;
		public var m_numStockCoverCells:int;
		
		// grid locations
		public var m_gridCellWidth:Number;
		public var m_gridCellHeight:Number;
		public var m_gridWidth:Number;
		public var m_gridHeight:Number;
		
		// physics
		public var m_numStackContacts:int;
		public var m_numStackPoints:int;
		
		// viewCover
		public var m_numStockTiles:int;
		public var m_numViewTiles:int;
		public var m_numViewGridObjects:int;
		
		// bitmap manager
		public var m_numBitmapLibraryEntries:int;
		public var m_numMovieClips:int;
		public var m_numMovieClipsIssues:int;
		
		// world worker
		public var m_numWorkingGridObjects:int;
		public var m_numWorkingFullTimers:int;
		
		// private
		private var m_physics:CellPhysics;
		private var m_viewer:CellGridViewer;
		private var m_worker:CellWorldWorker;
		
		private var m_firstTime:uint;
		private var m_secondTime:uint;
		private var m_fps:Number;
		private var m_frameCount:uint;
		
		private var m_data:String;
		private var m_textField:TextField;
		
		/* Constructor
		*/
		public function CellPerformanceStatistics(physics:CellPhysics, viewer:CellGridViewer, worker:CellWorldWorker):void {
			m_physics = physics;
			m_viewer = viewer;
			m_worker = worker;
			
			m_data = new String();
			
			m_textField = new TextField();
			m_textField.x = 0;
			m_textField.y = 0;
			m_textField.autoSize = TextFieldAutoSize.LEFT;
			var format:TextFormat = new TextFormat();
			format.font = "Courier New";
			format.color = 0x000000;
			format.size = 10;
			m_textField.defaultTextFormat = format;
			m_textField.selectable = false;
			m_textField.text = m_data;
			addChild(m_textField);
			
			m_firstTime = getTimer();
			m_secondTime = m_firstTime + 1000; // plus 1 second
			m_frameCount = 0;
			
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
		}
		
		public function Update(event:Event):void {
			m_firstTime = getTimer();
			if (m_firstTime > m_secondTime) {
				m_fps = m_frameCount / (m_firstTime - m_secondTime + 1000)*1000;
				m_frameCount = 0;
				m_secondTime = m_firstTime + 1000;
				
				if (m_physics) {
					m_physics.UpdatePerformanceStatistics(this);
				}
				if (m_viewer) {
					m_viewer.UpdatePerformanceStatistics(this);
				}
				if (m_worker) {
					m_worker.UpdatePerformanceStatistics(this);
				}
				
				UpdateData();
			}
			++m_frameCount;
			
		}
		
		public function UpdateData():void {
			m_data = "";
			m_data += "fps: " + m_fps.toFixed(1) + "\n";
			m_data += "statistics:\n";
			m_data += "grid:\n";
			m_data += "\tnum grid cells: " + m_numGridCells + "\n";
			m_data += "\tnum objects occupying grid cells: " + m_numGridCellsOccupiedByObjects + "\n";
			m_data += "\tnum covers occupying grid cells: " + m_numGridCellsOccupiedByCovers + "\n";
			m_data += "\tnum grid columns: " + m_numGridColumns + "\n";
			m_data += "\tnum grid rows: " + m_numGridRows + "\n";
			m_data += "\tnum active cover cells: " + m_numActiveCoverCells + "\n";
			m_data += "\tnum stock grid cells: " + m_numStockGridCells + "\n";
			m_data += "\tnum stock cover cells: " + m_numStockCoverCells + "\n";
			
			m_data += "grid locations:\n";
			m_data += "\tgrid cell width: " + m_gridCellWidth.toFixed(1) + "\n";
			m_data += "\tgrid cell height: " + m_gridCellHeight.toFixed(1) + "\n";
			m_data += "\tgrid width: " + m_gridWidth.toFixed(1) + "\n";
			m_data += "\tgrid height: " + m_gridHeight.toFixed(1) + "\n";
			
			m_data += "physics:\n";
			m_data += "\tnum stack contacts: " + m_numStackContacts + "\n";
			m_data += "\tnum stack points: " + m_numStackPoints + "\n";
			m_data += "\tnum active covers: " + m_numActiveCovers + "\n";
			m_data += "\tnum stock covers: " + m_numStockCovers + "\n";
			
			m_data += "view cover:\n";
			m_data += "\tnum stock tiles: " + m_numStockTiles + "\n";
			m_data += "\tnum view tiles: " + m_numViewTiles + "\n";
			m_data += "\tnum view grid objects: " + m_numViewGridObjects + "\n";
			
			m_data += "bitmap manager:\n";
			m_data += "\tnum bitmap library entries: " + m_numBitmapLibraryEntries + "\n";
			m_data += "\tnum movie clips: " + m_numMovieClips + "\n";
			m_data += "\tnum movie clips issued: " + m_numMovieClipsIssues + "\n";
			
			m_data += "world worker:\n";
			m_data += "\tnum grid objects under work cover: " + m_numWorkingGridObjects + "\n";
			m_data += "\tnum full time workers: " + m_numWorkingFullTimers + "\n";
			
			m_textField.text = m_data;
		}
		
	}
	
}