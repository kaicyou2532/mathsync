<template>
  <div class="left-sidebar">
    <div class="sidebar-header">
      <h3>プロジェクト設定</h3>
      <button @click="$emit('toggle')" class="close-btn">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="18" y1="6" x2="6" y2="18"></line>
          <line x1="6" y1="6" x2="18" y2="18"></line>
        </svg>
      </button>
    </div>

    <div class="sidebar-content">
      <!-- プロジェクト情報 -->
      <div class="section">
        <h4>プロジェクト情報</h4>
        <div class="input-group">
          <label>プロジェクト名</label>
          <input v-model="projectName" type="text" placeholder="無題のプロジェクト">
        </div>
        <div class="input-group">
          <label>説明</label>
          <textarea v-model="projectDescription" placeholder="プロジェクトの説明を入力"></textarea>
        </div>
      </div>

      <!-- ファイル管理 -->
      <div class="section">
        <h4>ファイル管理</h4>
        <div class="file-actions">
          <button @click="newProject" class="action-btn new">
            <svg class="icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
              <polyline points="14,2 14,8 20,8"></polyline>
              <line x1="16" y1="13" x2="8" y2="13"></line>
              <line x1="16" y1="17" x2="8" y2="17"></line>
              <polyline points="10,9 9,9 8,9"></polyline>
            </svg>
            新規作成
          </button>
          <button @click="openProject" class="action-btn open">
            <svg class="icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2v11z"></path>
            </svg>
            開く
          </button>
          <button @click="saveProject" class="action-btn save">
            <svg class="icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path>
              <polyline points="17,21 17,13 7,13 7,21"></polyline>
              <polyline points="7,3 7,8 15,8"></polyline>
            </svg>
            保存
          </button>
          <button @click="exportProject" class="action-btn export">
            <svg class="icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
              <polyline points="7,10 12,15 17,10"></polyline>
              <line x1="12" y1="15" x2="12" y2="3"></line>
            </svg>
            エクスポート
          </button>
        </div>
      </div>

      <!-- レイヤー管理 -->
      <div class="section">
        <h4>レイヤー</h4>
        <div class="layer-list">
          <div v-for="layer in layers" :key="layer.id" 
               :class="['layer-item', { active: layer.active }]"
               @click="selectLayer(layer.id)">
            <span class="layer-visibility" @click.stop="toggleLayerVisibility(layer.id)">
              <svg v-if="layer.visible" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                <circle cx="12" cy="12" r="3"></circle>
              </svg>
              <svg v-else width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="m9.88 9.88a3 3 0 1 0 4.24 4.24"></path>
                <path d="M10.73 5.08A10.43 10.43 0 0 1 12 5c7 0 11 8 11 8a13.16 13.16 0 0 1-1.67 2.68"></path>
                <path d="M6.61 6.61A13.526 13.526 0 0 0 1 12s4 8 11 8a9.74 9.74 0 0 0 5.39-1.61"></path>
                <line x1="2" y1="2" x2="22" y2="22"></line>
              </svg>
            </span>
            <span class="layer-name">{{ layer.name }}</span>
            <span class="layer-opacity">{{ layer.opacity }}%</span>
          </div>
        </div>
        <button @click="addLayer" class="add-layer-btn">
          <svg class="icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          レイヤーを追加
        </button>
      </div>

      <!-- グリッド設定 -->
      <div class="section">
        <h4>グリッド設定</h4>
        <div class="grid-settings">
          <label class="checkbox-label">
            <input v-model="showGrid" type="checkbox">
            <span class="checkmark"></span>
            グリッドを表示
          </label>
          <div class="input-group">
            <label>グリッドサイズ</label>
            <input v-model="gridSize" type="range" min="10" max="50" :disabled="!showGrid">
            <span class="value">{{ gridSize }}px</span>
          </div>
          <div class="input-group">
            <label>グリッド色</label>
            <input v-model="gridColor" type="color" :disabled="!showGrid">
          </div>
        </div>
      </div>

      <!-- 背景設定 -->
      <div class="section">
        <h4>背景設定</h4>
        <div class="background-settings">
          <div class="background-type">
            <label class="radio-label">
              <input v-model="backgroundType" type="radio" value="solid">
              <span class="radio-mark"></span>
              単色
            </label>
            <label class="radio-label">
              <input v-model="backgroundType" type="radio" value="gradient">
              <span class="radio-mark"></span>
              グラデーション
            </label>
            <label class="radio-label">
              <input v-model="backgroundType" type="radio" value="pattern">
              <span class="radio-mark"></span>
              パターン
            </label>
          </div>
          <div v-if="backgroundType === 'solid'" class="color-picker-group">
            <input v-model="backgroundColor" type="color">
          </div>
          <div v-if="backgroundType === 'gradient'" class="gradient-picker">
            <input v-model="gradientStart" type="color" title="開始色">
            <input v-model="gradientEnd" type="color" title="終了色">
          </div>
        </div>
      </div>

      <!-- 履歴 -->
      <div class="section">
        <h4>履歴</h4>
        <div class="history-actions">
          <button @click="undo" :disabled="!canUndo" class="history-btn">
            <span class="icon">↶</span>
            元に戻す
          </button>
          <button @click="redo" :disabled="!canRedo" class="history-btn">
            <span class="icon">↷</span>
            やり直し
          </button>
        </div>
        <div class="history-count">
          {{ historyPosition }} / {{ historyLength }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

defineEmits(['toggle'])

// プロジェクト情報
const projectName = ref('無題のプロジェクト')
const projectDescription = ref('')

// レイヤー管理
const layers = ref([
  { id: 1, name: 'レイヤー 1', visible: true, active: true, opacity: 100 },
  { id: 2, name: '背景', visible: true, active: false, opacity: 50 }
])

// グリッド設定
const showGrid = ref(false)
const gridSize = ref(20)
const gridColor = ref('#e0e0e0')

// 背景設定
const backgroundType = ref('solid')
const backgroundColor = ref('#ffffff')
const gradientStart = ref('#ffffff')
const gradientEnd = ref('#f0f0f0')

// 履歴管理
const historyPosition = ref(0)
const historyLength = ref(0)

const canUndo = computed(() => historyPosition.value > 0)
const canRedo = computed(() => historyPosition.value < historyLength.value)

// ファイル操作
const newProject = () => {
  if (confirm('新しいプロジェクトを作成しますか？未保存の変更は失われます。')) {
    // 新規プロジェクト作成ロジック
    console.log('新規プロジェクト作成')
  }
}

const openProject = () => {
  // ファイル選択ダイアログを開く
  const input = document.createElement('input')
  input.type = 'file'
  input.accept = '.json'
  input.onchange = (e) => {
    const file = e.target.files[0]
    if (file) {
      // ファイル読み込みロジック
      console.log('プロジェクトを開く:', file.name)
    }
  }
  input.click()
}

const saveProject = () => {
  // プロジェクト保存ロジック
  const projectData = {
    name: projectName.value,
    description: projectDescription.value,
    layers: layers.value,
    settings: {
      grid: { show: showGrid.value, size: gridSize.value, color: gridColor.value },
      background: { type: backgroundType.value, color: backgroundColor.value }
    }
  }
  console.log('プロジェクト保存:', projectData)
}

const exportProject = () => {
  // エクスポートオプション
  const formats = ['PNG', 'SVG', 'PDF', 'JSON']
  const format = prompt(`エクスポート形式を選択してください:\n${formats.join(', ')}`)
  if (format && formats.includes(format.toUpperCase())) {
    console.log(`${format}形式でエクスポート`)
  }
}

// レイヤー操作
const selectLayer = (layerId) => {
  layers.value.forEach(layer => {
    layer.active = layer.id === layerId
  })
}

const toggleLayerVisibility = (layerId) => {
  const layer = layers.value.find(l => l.id === layerId)
  if (layer) {
    layer.visible = !layer.visible
  }
}

const addLayer = () => {
  const newId = Math.max(...layers.value.map(l => l.id)) + 1
  layers.value.unshift({
    id: newId,
    name: `レイヤー ${newId}`,
    visible: true,
    active: false,
    opacity: 100
  })
}

// 履歴操作
const undo = () => {
  if (canUndo.value) {
    historyPosition.value--
    console.log('元に戻す')
  }
}

const redo = () => {
  if (canRedo.value) {
    historyPosition.value++
    console.log('やり直し')
  }
}
</script>

<style scoped>
.left-sidebar {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, rgba(30, 41, 59, 0.95), rgba(51, 65, 85, 0.95));
  backdrop-filter: blur(20px);
  border-right: 1px solid rgba(100, 181, 246, 0.2);
}

.sidebar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 1.5rem 1rem;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

.sidebar-header h3 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 700;
  background: linear-gradient(135deg, #64b5f6, #42a5f5, #1e88e5);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.close-btn {
  background: transparent;
  border: 1px solid rgba(0, 0, 0, 0.1);
  color: rgba(0, 0, 0, 0.6);
  padding: 0.5rem;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: rgba(220, 38, 38, 0.1);
  color: #ef4444;
  border-color: rgba(220, 38, 38, 0.3);
  transform: scale(1.05);
}

.sidebar-content {
  flex: 1;
  overflow-y: auto;
  padding: 0 1.5rem 1.5rem;
}

.section {
  margin-bottom: 2rem;
}

.section h4 {
  margin: 0 0 1rem 0;
  font-size: 1rem;
  font-weight: 600;
  color: rgba(0, 0, 0, 0.8);
  border-bottom: 2px solid rgba(100, 181, 246, 0.3);
  padding-bottom: 0.5rem;
}

.input-group {
  margin-bottom: 1rem;
}

.input-group label {
  display: block;
  font-size: 0.875rem;
  font-weight: 500;
  color: rgba(0, 0, 0, 0.7);
  margin-bottom: 0.5rem;
}

.input-group input,
.input-group textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid rgba(0, 0, 0, 0.2);
  border-radius: 0.5rem;
  background: rgba(255, 255, 255, 0.9);
  color: rgba(0, 0, 0, 0.87);
  transition: all 0.2s ease;
}

.input-group input::placeholder,
.input-group textarea::placeholder {
  color: rgba(0, 0, 0, 0.5);
}

.input-group input:focus,
.input-group textarea:focus {
  outline: none;
  border-color: #64b5f6;
  box-shadow: 0 0 0 3px rgba(100, 181, 246, 0.2);
  background: rgba(255, 255, 255, 1);
}

.input-group textarea {
  resize: vertical;
  min-height: 60px;
}

.file-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.75rem;
}

.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem;
  border: 1px solid rgba(100, 181, 246, 0.2);
  border-radius: 0.75rem;
  background: rgba(51, 65, 85, 0.8);
  color: rgba(255, 255, 255, 0.8);
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  font-size: 0.875rem;
  font-weight: 500;
  position: relative;
  overflow: hidden;
}

.action-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(100, 181, 246, 0.1), rgba(66, 165, 245, 0.1));
  opacity: 0;
  transition: opacity 0.3s ease;
}

.action-btn:hover {
  transform: translateY(-2px) scale(1.02);
  box-shadow: 0 8px 25px rgba(30, 136, 229, 0.3);
  border-color: rgba(100, 181, 246, 0.4);
  color: #64b5f6;
}

.action-btn:hover::before {
  opacity: 1;
}

.action-btn .icon {
  position: relative;
  z-index: 1;
}

.layer-list {
  max-height: 200px;
  overflow-y: auto;
  border: 1px solid rgba(100, 181, 246, 0.15);
  border-radius: 0.5rem;
  background: rgba(15, 23, 42, 0.6);
}

.layer-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  border-bottom: 1px solid rgba(100, 181, 246, 0.1);
  cursor: pointer;
  transition: all 0.2s ease;
  color: rgba(255, 255, 255, 0.8);
}

.layer-item:last-child {
  border-bottom: none;
}

.layer-item:hover {
  background: rgba(100, 181, 246, 0.1);
  color: #64b5f6;
}

.layer-item.active {
  background: linear-gradient(135deg, rgba(30, 136, 229, 0.2), rgba(66, 165, 245, 0.2));
  color: #64b5f6;
  border-color: rgba(100, 181, 246, 0.3);
}

.layer-visibility {
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 0.25rem;
  transition: all 0.2s ease;
  color: rgba(255, 255, 255, 0.6);
}

.layer-visibility:hover {
  background: rgba(100, 181, 246, 0.1);
  color: #64b5f6;
}

.layer-name {
  flex: 1;
  font-weight: 500;
}

.layer-opacity {
  font-size: 0.75rem;
  color: rgba(255, 255, 255, 0.6);
}

.add-layer-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem;
  margin-top: 0.75rem;
  border: 2px dashed rgba(100, 181, 246, 0.3);
  border-radius: 0.5rem;
  background: transparent;
  color: rgba(255, 255, 255, 0.7);
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
}

.add-layer-btn:hover {
  background: rgba(100, 181, 246, 0.1);
  border-color: rgba(100, 181, 246, 0.5);
  color: #64b5f6;
  transform: translateY(-1px);
}

.checkbox-label,
.radio-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  font-size: 0.875rem;
  color: rgba(255, 255, 255, 0.8);
  margin-bottom: 0.5rem;
}

.checkmark,
.radio-mark {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(100, 181, 246, 0.3);
  border-radius: 0.25rem;
  background: rgba(51, 65, 85, 0.8);
  transition: all 0.2s ease;
  position: relative;
}

.radio-mark {
  border-radius: 50%;
}

input[type="checkbox"]:checked + .checkmark,
input[type="radio"]:checked + .radio-mark {
  background: linear-gradient(135deg, #1e88e5, #42a5f5);
  border-color: #64b5f6;
}

input[type="checkbox"]:checked + .checkmark::after {
  content: '✓';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 10px;
  font-weight: bold;
}

input[type="radio"]:checked + .radio-mark::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 6px;
  height: 6px;
  background: white;
  border-radius: 50%;
}

input[type="checkbox"],
input[type="radio"] {
  display: none;
}

.value {
  font-size: 0.75rem;
  color: rgba(255, 255, 255, 0.6);
  font-weight: 500;
  min-width: 35px;
  text-align: center;
}

/* スライダーのスタイル */
input[type="range"] {
  width: 100%;
  height: 4px;
  background: rgba(51, 65, 85, 0.8);
  border-radius: 2px;
  outline: none;
  cursor: pointer;
  -webkit-appearance: none;
  appearance: none;
}

input[type="range"]::-webkit-slider-thumb {
  appearance: none;
  width: 16px;
  height: 16px;
  background: linear-gradient(135deg, #1e88e5, #42a5f5);
  border-radius: 50%;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(30, 136, 229, 0.4);
  transition: all 0.3s ease;
}

input[type="range"]::-webkit-slider-thumb:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(30, 136, 229, 0.5);
}

input[type="range"]::-moz-range-thumb {
  width: 16px;
  height: 16px;
  background: linear-gradient(135deg, #1e88e5, #42a5f5);
  border-radius: 50%;
  cursor: pointer;
  border: none;
  box-shadow: 0 2px 8px rgba(30, 136, 229, 0.4);
}

/* カラーピッカーのスタイル */
input[type="color"] {
  width: 100%;
  height: 40px;
  border: 2px solid rgba(100, 181, 246, 0.3);
  border-radius: 0.5rem;
  cursor: pointer;
  background: rgba(51, 65, 85, 0.8);
  transition: all 0.3s ease;
}

input[type="color"]:hover {
  border-color: rgba(100, 181, 246, 0.6);
  transform: scale(1.02);
  box-shadow: 0 2px 8px rgba(30, 136, 229, 0.3);
}

input[type="color"]::-webkit-color-swatch-wrapper {
  padding: 0;
}

input[type="color"]::-webkit-color-swatch {
  border: none;
  border-radius: 6px;
}

/* レスポンシブ対応 */
@media (max-width: 768px) {
  .left-sidebar {
    width: 250px;
  }
  
  .sidebar-header {
    padding: 1rem;
  }
  
  .sidebar-content {
    padding: 0 1rem 1rem;
  }
  
  .file-actions {
    grid-template-columns: 1fr;
    gap: 0.5rem;
  }
  
  .action-btn {
    padding: 0.5rem;
    font-size: 0.75rem;
  }
}

.layer-item {
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  position: relative;
  overflow: hidden;
}

.action-btn.new {
  background: linear-gradient(135deg, #10b981, #059669);
  color: white;
  box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
}

.action-btn.open {
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
  color: white;
  box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
}

.action-btn.save {
  background: linear-gradient(135deg, #f59e0b, #d97706);
  color: white;
  box-shadow: 0 4px 15px rgba(245, 158, 11, 0.3);
}

.action-btn.export {
  background: linear-gradient(135deg, #8b5cf6, #7c3aed);
  color: white;
  box-shadow: 0 4px 15px rgba(139, 92, 246, 0.3);
}

.action-btn:hover {
  transform: translateY(-2px) scale(1.05);
}

.layer-list {
  max-height: 200px;
  overflow-y: auto;
  border: 1px solid rgba(229, 231, 235, 0.5);
  border-radius: 0.5rem;
  background: rgba(255, 255, 255, 0.5);
}

.layer-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  cursor: pointer;
  transition: all 0.2s ease;
  border-bottom: 1px solid rgba(229, 231, 235, 0.3);
}

.layer-item:hover {
  background: rgba(102, 126, 234, 0.05);
}

.layer-item.active {
  background: rgba(102, 126, 234, 0.1);
  border-left: 3px solid #667eea;
}

.layer-visibility {
  cursor: pointer;
  font-size: 1rem;
}

.layer-name {
  flex: 1;
  font-weight: 500;
}

.layer-opacity {
  font-size: 0.75rem;
  color: #6b7280;
}

.add-layer-btn {
  width: 100%;
  margin-top: 0.75rem;
  padding: 0.75rem;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
  border: 1px dashed rgba(102, 126, 234, 0.3);
  border-radius: 0.5rem;
  color: #667eea;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.add-layer-btn:hover {
  background: rgba(102, 126, 234, 0.1);
  border-color: #667eea;
}

.checkbox-label,
.radio-label {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
  cursor: pointer;
  font-size: 0.875rem;
  color: #374151;
}

.checkmark,
.radio-mark {
  width: 18px;
  height: 18px;
  border: 2px solid #d1d5db;
  background: white;
  transition: all 0.2s ease;
}

.checkmark {
  border-radius: 0.25rem;
}

.radio-mark {
  border-radius: 50%;
}

input[type="checkbox"]:checked + .checkmark,
input[type="radio"]:checked + .radio-mark {
  background: #667eea;
  border-color: #667eea;
}

input[type="checkbox"],
input[type="radio"] {
  display: none;
}

.background-type {
  margin-bottom: 1rem;
}

.color-picker-group,
.gradient-picker {
  display: flex;
  gap: 0.5rem;
}

.gradient-picker input {
  flex: 1;
}

.history-actions {
  display: flex;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.history-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem;
  background: linear-gradient(135deg, #6b7280, #4b5563);
  color: white;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 0.875rem;
}

.history-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.history-btn:not(:disabled):hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(107, 114, 128, 0.3);
}

.history-count {
  text-align: center;
  font-size: 0.75rem;
  color: #6b7280;
  background: rgba(243, 244, 246, 0.8);
  padding: 0.5rem;
  border-radius: 0.25rem;
}

.value {
  font-size: 0.75rem;
  color: #6b7280;
  margin-left: 0.5rem;
}
</style>
