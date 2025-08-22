<script setup>
import { ref } from 'vue'
import Whiteboard from './components/whiteboard/Whiteboard.vue'
import Spreadsheet from './components/spreadsheet/Spreadsheet.vue'
import ChartViewer from './components/charts/ChartViewer.vue'
import CommunicationPanel from './components/communication/CommunicationPanel.vue'
import LeftSidebar from './components/sidebars/LeftSidebar.vue'
import RightSidebar from './components/sidebars/RightSidebar.vue'
import BottomToolbar from './components/toolbars/BottomToolbar.vue'

const showLeftSidebar = ref(true)
const showRightSidebar = ref(true)
const showSpreadsheet = ref(false)
const showChart = ref(false)
const showCommunication = ref(false)

const currentTool = ref('pen')
const strokeColor = ref('#000000')
const strokeWidth = ref(2)
const fillColor = ref('#ffffff')

// ツール選択のハンドラー
const handleToolSelect = (tool) => {
  currentTool.value = tool
}

// サイドバー表示切り替え
const toggleLeftSidebar = () => {
  showLeftSidebar.value = !showLeftSidebar.value
}

const toggleRightSidebar = () => {
  showRightSidebar.value = !showRightSidebar.value
}

// 右サイドバーの機能切り替え
const handleRightSidebarFunction = (func) => {
  // 全ての機能をまず非表示に
  showSpreadsheet.value = false
  showChart.value = false
  showCommunication.value = false
  
  // 選択された機能のみ表示
  switch (func) {
    case 'spreadsheet':
      showSpreadsheet.value = true
      break
    case 'chart':
      showChart.value = true
      break
    case 'communication':
      showCommunication.value = true
      break
  }
}

// 描画設定の更新
const handleDrawingSettingsUpdate = (settings) => {
  strokeColor.value = settings.strokeColor || strokeColor.value
  strokeWidth.value = settings.strokeWidth || strokeWidth.value
  fillColor.value = settings.fillColor || fillColor.value
}
</script>

<template>
  <div class="app">
    <!-- ヘッダー -->
    <header class="app-header">
      <div class="header-left">
        <button @click="toggleLeftSidebar" class="sidebar-toggle">
          <svg class="icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="3" y1="6" x2="21" y2="6"></line>
            <line x1="3" y1="12" x2="21" y2="12"></line>
            <line x1="3" y1="18" x2="21" y2="18"></line>
          </svg>
        </button>
        <h1>MathSync</h1>
      </div>
      
      <div class="header-center">
        <span class="subtitle">オンライン数学ワークスペース</span>
      </div>
      
      <div class="header-right">
        <button @click="toggleRightSidebar" class="sidebar-toggle">
          <svg class="icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="3"></circle>
            <path d="M12 1v6m0 6v6"></path>
            <path d="m21 12-6-6m6 6-6 6"></path>
            <path d="m3 12 6 6m-6-6 6-6"></path>
          </svg>
        </button>
      </div>
    </header>

    <!-- メインコンテンツエリア -->
    <main class="app-main">
      <!-- 左サイドバー -->
      <LeftSidebar 
        v-if="showLeftSidebar"
        class="left-sidebar"
        @toggle="toggleLeftSidebar"
      />

      <!-- ホワイトボードエリア -->
      <div class="whiteboard-area">
        <Whiteboard 
          :current-tool="currentTool"
          :stroke-color="strokeColor"
          :stroke-width="strokeWidth"
          :fill-color="fillColor"
        />
      </div>

      <!-- 右サイドバー -->
      <RightSidebar 
        v-if="showRightSidebar"
        class="right-sidebar"
        @toggle="toggleRightSidebar"
        @function-select="handleRightSidebarFunction"
      />

      <!-- 右サイドバーのコンテンツパネル -->
      <div v-if="showRightSidebar && (showSpreadsheet || showChart || showCommunication)" class="right-panel">
        <Spreadsheet v-if="showSpreadsheet" />
        <ChartViewer v-if="showChart" />
        <CommunicationPanel v-if="showCommunication" />
      </div>
    </main>

    <!-- 下部フローティングツールバー -->
    <BottomToolbar 
      :current-tool="currentTool"
      :stroke-color="strokeColor"
      :stroke-width="strokeWidth"
      :fill-color="fillColor"
      @tool-select="handleToolSelect"
      @settings-update="handleDrawingSettingsUpdate"
    />
  </div>
</template>

<style scoped>
.app {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, 
    rgba(15, 23, 42, 1) 0%, 
    rgba(30, 41, 59, 1) 25%, 
    rgba(51, 65, 85, 1) 50%, 
    rgba(71, 85, 105, 1) 75%, 
    rgba(100, 116, 139, 1) 100%);
  overflow: hidden;
  position: relative;
}

.app::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 20% 30%, rgba(100, 181, 246, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 80% 70%, rgba(66, 165, 245, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 40% 80%, rgba(30, 136, 229, 0.05) 0%, transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.app-header {
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  color: white;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 8px 32px rgba(0,0,0,0.3);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(255,255,255,0.1);
  position: relative;
  z-index: 1000;
  height: 70px;
}

.header-left,
.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.sidebar-toggle {
  background: rgba(100, 181, 246, 0.1);
  border: 1px solid rgba(100, 181, 246, 0.2);
  color: rgba(255, 255, 255, 0.9);
  padding: 0.75rem;
  border-radius: 0.75rem;
  cursor: pointer;
  transition: all 0.3s ease;
  backdrop-filter: blur(5px);
  display: flex;
  align-items: center;
  justify-content: center;
}

.sidebar-toggle:hover {
  background: rgba(100, 181, 246, 0.2);
  transform: scale(1.05);
  color: #64b5f6;
  border-color: rgba(100, 181, 246, 0.4);
}

.sidebar-toggle .icon {
  width: 20px;
  height: 20px;
}

.app-header h1 {
  margin: 0;
  font-size: 1.8rem;
  font-weight: 700;
  background: linear-gradient(45deg, #64b5f6, #42a5f5, #1e88e5);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.header-center .subtitle {
  font-size: 0.9rem;
  opacity: 0.8;
  font-weight: 300;
}

.app-main {
  flex: 1;
  display: flex;
  overflow: hidden;
  position: relative;
  background: rgba(15, 23, 42, 0.05);
  backdrop-filter: blur(5px);
  margin: 8px;
  border-radius: 16px;
  border: 1px solid rgba(100, 181, 246, 0.1);
}

.left-sidebar {
  width: 300px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-right: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 2px 0 20px rgba(0, 0, 0, 0.1);
  z-index: 100;
  transition: all 0.3s ease;
  border-radius: 16px 0 0 16px;
}

.whiteboard-area {
  flex: 1;
  position: relative;
  overflow: hidden;
  background: rgba(30, 41, 59, 0.1);
}

.right-sidebar {
  width: 80px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-left: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: -2px 0 20px rgba(0, 0, 0, 0.1);
  z-index: 100;
  transition: all 0.3s ease;
  border-radius: 0 16px 16px 0;
}

.right-panel {
  width: 400px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-left: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: -2px 0 20px rgba(0, 0, 0, 0.1);
  z-index: 99;
  transition: all 0.3s ease;
  border-radius: 0 16px 16px 0;
  color: rgba(0, 0, 0, 0.87);
}

/* レスポンシブ対応 */
@media (max-width: 768px) {
  .left-sidebar {
    width: 250px;
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    transform: translateX(-100%);
    transition: transform 0.3s ease;
  }
  
  .left-sidebar.show {
    transform: translateX(0);
  }
  
  .right-sidebar {
    width: 60px;
  }
  
  .right-panel {
    width: 300px;
  }
}
</style>
