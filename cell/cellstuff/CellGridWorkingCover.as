package CellStuff {
	
	public class CellGridWorkingCover extends CellGridCover {
		
		private var m_level:int;
		
		private var m_isChangingLevel:Boolean;
		private var m_hasChangedLevel:Boolean;
		
		/* Constructor
		*/
		public function CellGridWorkingCover(cellGrid:CellGridLocations, coverData:Object):void {
			super(cellGrid, coverData);
			
			m_level = 0;
			
			m_isChangingLevel = false;
			m_hasChangedLevel = false;
		}
		
		/* GridObjectLeave
		* overrided to remove objects that are flagged for removal
		*/
		public override function GridObjectLeave(coverCell:Object, go:CellGridObject):void {
			if (m_gridObjectSet[go]) {
				
				m_gridObjectSet[go] -= 1;
				
				if (m_gridObjectSet[go] <= 0) {
					
					delete m_gridObjectSet[go];
					m_isGridObjectListChanged = true;
					
					go.m_isMarkedForDeletion = m_level && go.m_level && (go.m_level != m_level);
				}
			}
		}
		
		/* ChangeLevel
		* Changes the working level,
		* marks objects that should be deleted according to their level
		*/
		public function ChangeLevelStart(levelData:Object):void {
			m_level = levelData.level;
			m_isChangingLevel = true;
			m_hasChangedLevel = false;
		}
		
		public function ChangeLevelFinish():void {
			m_isChangingLevel = false;
			m_hasChangedLevel = false;
		}
		
		/* AddColumn
		* overrided to create new tiles when a level is changed
		*/
		protected override function AddColumn(current:Object, isLeft:Boolean = true):void {
			super.AddColumn(current, isLeft);
			
			if (m_isChangingLevel) {
				while (current && m_isChangingLevel) {
					m_isChangingLevel = m_cellGrid.UpdateGridCell(current.cell);
					if (!m_isChangingLevel) {
						m_hasChangedLevel = true;
					}
					current = current.bottom;
				}
			}
		}
		
		/* AddRow
		* overrided to create new tiles when a level is changed
		*/
		protected override function AddRow(current:Object, isTop:Boolean = true):void {
			super.AddRow(current, isTop);
			
			if (m_isChangingLevel) {
				while (current && m_isChangingLevel) {
					m_isChangingLevel = m_cellGrid.UpdateGridCell(current.cell);
					if (!m_isChangingLevel) {
						m_hasChangedLevel = true;
					}
					current = current.right;
				}
			}
		}
		
		/* Shrinks the cellgrid to the gird cover
		* note, that covers and objects need to be reset after calling this.
		*/
		public function ShrinkGridToCover():void {
			m_cellGrid.ShrinkGrid(m_topLeft.cell, m_bottomRight.cell);
		}
		
		public function ShiftGridToCover():void {
			m_cellGrid.ShiftGrid(m_topLeft.cell);
		}
		
		public function IsChangeLevelComplete():Boolean {
			return m_hasChangedLevel;
		}
		
	}
}