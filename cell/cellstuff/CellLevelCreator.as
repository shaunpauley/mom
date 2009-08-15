package CellStuff {
	
	public class CellLevelCreator {
		
		private var m_currentLevel:int;
		
		private var m_nextLevelData:Object;
		
		/* Constructor
		*/
		public function CellLevelCreator():void {
			m_nextLevelData = GenerateLevelData( CreateEmptyLevelData(), 1 );
		}
		
		/* CreateEmptyLevelData
		* create an empty level data object
		*/
		private function CreateEmptyLevelData():Object {
			return {gridData:{}, 
			objectData:{ level:1, defaultObjects:new Array(), specialObjects:new Array() },
			playerData:{}};
		}
		
		/* GenerateLevelData
		* generates the new level data based on the level given
		*/
		private function GenerateLevelData(levelData:Object, level:int):Object {
			var gridData:Object = levelData.gridData;
			
			var objectData:Object = levelData.objectData;
			while (objectData.defaultObjects.length) {
				objectData.defaultObjects.pop();
			}
			while (objectData.specialObjects.length) {
				objectData.specialObjects.pop();
			}
			
			switch (level) {
				case 2:
					gridData = CellGridLocations.GenerateGridLocationsDataDefaults( gridData );
					gridData.cols = 50;
					gridData.rows = 50;
					
					gridData.defaultDrawType = CellGrid.c_drawTypeFlat;
					gridData.defaultColorHigh = uint(0x444444*Math.random() + 0x999999);
					
					var goDefault:Object = {numCopies:300,
					randomRadius:true,
					radiusHigh:22,
					radiusLow:2,
					randomMass:true,
					massHigh:10,
					massLow:0,
					randomLocation:true,
					colHigh:30,
					colLow:10,
					rowHigh:40,
					rowLow:10};
					
					objectData.defaultObjects.push(goDefault);
					
					var goStart:Object = {numCopies:1,
					radius:10,
					mass:10,
					col:10,
					row:10,
					isDrawn:true}
					
					objectData.defaultObjects.push(goStart);
					
					break;
				default:
					gridData = CellGridLocations.GenerateGridLocationsDataDefaults( gridData );
					gridData.cols = 20;
					gridData.rows = 20;
					gridData.defaultDrawType = CellGrid.c_drawTypeFlat;
					gridData.defaultColorHigh = 0x987654;
					
					
					break;
			}
			
			levelData.level = level;
			
			return levelData;
		}
		
		/* GetLevelData 
		* generates the new level data and return it
		*/
		public function GetLevelData(level:int):Object {
			if (level == m_nextLevelData.level) {
				return m_nextLevelData;
			}
			
			return GenerateLevelData(m_nextLevelData, level);
		}
		
	}
}