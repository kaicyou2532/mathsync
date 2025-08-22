<template>
  <div class="bottom-toolbar" :class="{ collapsed: !isExpanded }">
    <!-- ハンバーガーボタン -->
    <button 
      @click="toggleToolbar" 
      class="hamburger-button"
      :class="{ active: isExpanded }"
    >
      <svg class="hamburger-icon" :class="{ expanded: isExpanded }" viewBox="0 0 24 24">
        <line class="hamburger-line" x1="3" y1="6" x2="21" y2="6"></line>
        <line class="hamburger-line" x1="3" y1="12" x2="21" y2="12"></line>
        <line class="hamburger-line" x1="3" y1="18" x2="21" y2="18"></line>
      </svg>
    </button>

    <!-- ツールバーコンテンツ -->
    <div class="toolbar-content" :class="{ collapsed: !isExpanded }">
      <!-- 描画ツール -->
      <div class="tool-group">
        <button 
          v-for="tool in drawingTools" 
          :key="tool.id"
          @click="selectTool(tool.id)"
          :class="['tool-button', { active: currentTool === tool.id }]"
          :title="tool.name"
        >
          <div v-html="tool.icon"></div>
        </button>
      </div>

      <!-- 図形ツール -->
      <div class="tool-group">
        <button 
          v-for="shape in shapes" 
          :key="shape.id"
          @click="selectTool(shape.id)"
          :class="['tool-button', { active: currentTool === shape.id }]"
          :title="shape.name"
        >
          <div v-html="shape.icon"></div>
        </button>
      </div>

      <!-- 線の設定 -->
      <div class="tool-group">
        <span class="toolbar-label">線種</span>
        <div class="line-type-selector">
          <button 
            v-for="type in lineTypes"
            :key="type.value"
            @click="setLineType(type.value)"
            :class="['line-type-button', { active: lineType === type.value }]"
          >
            {{ type.name }}
          </button>
        </div>
      </div>

      <!-- 線の太さ -->
      <div class="tool-group">
        <span class="toolbar-label">太さ</span>
        <input 
          v-model="strokeWidth" 
          type="range" 
          min="1" 
          max="20" 
          @input="updateSettings"
          class="width-slider"
        >
        <span class="toolbar-label">{{ strokeWidth }}px</span>
      </div>

      <!-- 色設定 -->
      <div class="tool-group">
        <span class="toolbar-label">線色</span>
        <input 
          v-model="strokeColor" 
          type="color" 
          @change="updateSettings"
          class="color-input"
        >
      </div>

      <!-- 塗りつぶし設定 -->
      <div class="tool-group">
        <span class="toolbar-label">塗り</span>
        <div class="fill-controls">
          <input 
            v-model="enableFill" 
            type="checkbox"
            @change="updateSettings"
            class="fill-checkbox"
            id="enableFill"
          >
          <input 
            v-model="fillColor" 
            type="color" 
            @change="updateSettings"
            class="color-input"
            :disabled="!enableFill"
          >
          <input 
            v-model="fillOpacity" 
            type="range" 
            min="0" 
            max="100" 
            @input="updateSettings"
            class="opacity-slider"
            :disabled="!enableFill"
          >
          <span class="toolbar-label">{{ fillOpacity }}%</span>
        </div>
      </div>

      <!-- 特殊ツール -->
      <div class="tool-group">
        <button 
          v-for="tool in specialTools" 
          :key="tool.id"
          @click="selectTool(tool.id)"
          :class="['tool-button', { active: currentTool === tool.id }]"
          :title="tool.name"
        >
          <div v-html="tool.icon"></div>
        </button>
      </div>

      <!-- アクション -->
      <div class="tool-group">
        <button @click="clearCanvas" class="action-button clear">
          クリア
        </button>
        <button @click="saveImage" class="action-button save">
          保存
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  currentTool: String,
  strokeColor: String,
  strokeWidth: Number,
  fillColor: String
})

const emit = defineEmits(['tool-select', 'settings-update'])

// ツールバーの展開状態
const isExpanded = ref(false)

// 内部状態
const lineType = ref('solid')
const enableFill = ref(false)
const fillOpacity = ref(50)

// 線の種類オプション
const lineTypes = ref([
  { value: 'solid', name: '実線' },
  { value: 'dashed', name: '破線' },
  { value: 'dotted', name: '点線' },
  { value: 'dash-dot', name: '一点鎖線' }
])

// シンプルな図形ベースのツール定義
const drawingTools = ref([
  { 
    id: 'pen', 
    name: 'ペン', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="m12 19 7-7 3 3-7 7-3-3z"></path>
      <path d="m18 13-1.5-7.5L2 2l3.5 14.5L13 18l5-5z"></path>
      <path d="m2 2 7.586 7.586"></path>
      <circle cx="11" cy="11" r="2"></circle>
    </svg>` 
  },
  { 
    id: 'brush', 
    name: 'ブラシ', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="m9.06 11.9 8.07-8.06a2.85 2.85 0 1 1 4.03 4.03l-8.06 8.08"></path>
      <path d="m21 15-6-6m-6 6v4a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-1a2 2 0 0 1 2-2h4z"></path>
    </svg>` 
  },
  { 
    id: 'pencil', 
    name: '鉛筆', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <line x1="18" y1="2" x2="22" y2="6"></line>
      <path d="m7.5 20.5 6-6 4-4L21 7l-3-3-1.5 1.5-4 4-6 6v3h3z"></path>
    </svg>` 
  },
  { 
    id: 'eraser', 
    name: '消しゴム', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M20 5H9l-7 7 7 7h11a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2Z"></path>
      <line x1="12" x2="12" y1="9" y2="15"></line>
      <line x1="9" x2="15" y1="12" y2="12"></line>
    </svg>` 
  },
  { 
    id: 'select', 
    name: '選択', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="m3 3 7.07 16.97 2.51-7.39 7.39-2.51L3 3z"></path>
      <path d="m13 13 6 6"></path>
    </svg>` 
  }
])

const shapes = ref([
  { 
    id: 'rectangle', 
    name: '四角形', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <rect width="18" height="12" x="3" y="6" rx="2"></rect>
    </svg>` 
  },
  { 
    id: 'circle', 
    name: '円', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <circle cx="12" cy="12" r="8"></circle>
    </svg>` 
  },
  { 
    id: 'triangle', 
    name: '三角形', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M13.73 4a2 2 0 0 0-3.46 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"></path>
    </svg>` 
  },
  { 
    id: 'line', 
    name: '直線', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M3 3l18 18"></path>
    </svg>` 
  },
  { 
    id: 'arrow', 
    name: '矢印', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M5 12h14"></path>
      <path d="m12 5 7 7-7 7"></path>
    </svg>` 
  }
])

const specialTools = ref([
  { 
    id: 'text', 
    name: 'テキスト', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <polyline points="4,7 4,4 20,4 20,7"></polyline>
      <line x1="9" y1="20" x2="15" y2="20"></line>
      <line x1="12" y1="4" x2="12" y2="20"></line>
    </svg>` 
  },
  { 
    id: 'measure', 
    name: '定規', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M21.3 8.7 8.7 21.3c-.4.4-1 .4-1.4 0l-5.6-5.6c-.4-.4-.4-1 0-1.4L14.3 2.7c.4-.4 1-.4 1.4 0l5.6 5.6c.4.4.4 1 0 1.4Z"></path>
      <path d="m9 12 2 2"></path>
      <path d="m11 10 2 2"></path>
      <path d="m13 8 2 2"></path>
    </svg>` 
  },
  { 
    id: 'protractor', 
    name: '分度器', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <circle cx="12" cy="12" r="10"></circle>
      <path d="m12 2 0 10 5.39 7.39"></path>
      <path d="M12 12h8"></path>
    </svg>` 
  },
  { 
    id: 'grid', 
    name: 'グリッド', 
    icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <rect width="18" height="18" x="3" y="3" rx="2"></rect>
      <path d="M9 3v18"></path>
      <path d="M15 3v18"></path>
      <path d="M3 9h18"></path>
      <path d="M3 15h18"></path>
    </svg>` 
  }
])

// 親からのプロパティを監視
const strokeColor = ref(props.strokeColor)
const strokeWidth = ref(props.strokeWidth)
const fillColor = ref(props.fillColor)
const currentTool = ref(props.currentTool)

watch(() => props.strokeColor, (newValue) => {
  strokeColor.value = newValue
})

watch(() => props.strokeWidth, (newValue) => {
  strokeWidth.value = newValue
})

watch(() => props.fillColor, (newValue) => {
  fillColor.value = newValue
})

watch(() => props.currentTool, (newValue) => {
  currentTool.value = newValue
})

// ツールバーの表示切り替え
const toggleToolbar = () => {
  isExpanded.value = !isExpanded.value
}

// ツール選択
const selectTool = (toolId) => {
  emit('tool-select', toolId)
}

// 線の種類設定
const setLineType = (type) => {
  lineType.value = type
  updateSettings()
}

// 設定更新
const updateSettings = () => {
  emit('settings-update', {
    strokeColor: strokeColor.value,
    strokeWidth: strokeWidth.value,
    fillColor: fillColor.value,
    lineType: lineType.value,
    enableFill: enableFill.value,
    fillOpacity: fillOpacity.value
  })
}

// アクション
const clearCanvas = () => {
  if (confirm('キャンバスをクリアしますか？')) {
    emit('tool-select', 'clear')
  }
}

const saveImage = () => {
  emit('tool-select', 'save')
}
</script>

<style scoped>
.bottom-toolbar {
  position: fixed;
  bottom: 24px;
  left: 50%;
  transform: translateX(-50%);
  background: linear-gradient(135deg, rgba(30, 41, 59, 0.95), rgba(51, 65, 85, 0.95));
  backdrop-filter: blur(20px);
  border: 1px solid rgba(100, 181, 246, 0.2);
  border-radius: 20px;
  padding: 12px;
  box-shadow: 
    0 8px 32px rgba(0, 0, 0, 0.3),
    0 2px 8px rgba(30, 136, 229, 0.2);
  z-index: 1000;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  gap: 12px;
  max-width: calc(100vw - 48px);
}

.bottom-toolbar.collapsed {
  padding: 8px;
  border-radius: 50px;
  background: linear-gradient(135deg, rgba(30, 41, 59, 0.9), rgba(51, 65, 85, 0.9));
}

.hamburger-button {
  background: transparent;
  border: none;
  border-radius: 50%;
  width: 44px;
  height: 44px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  color: rgba(255, 255, 255, 0.8);
  flex-shrink: 0;
}

.hamburger-button:hover {
  background: rgba(100, 181, 246, 0.1);
  transform: scale(1.05);
  color: #64b5f6;
}

.hamburger-button.active {
  background: rgba(100, 181, 246, 0.15);
  color: #64b5f6;
}

.hamburger-icon {
  width: 20px;
  height: 20px;
  transition: all 0.3s ease;
}

.hamburger-icon.expanded {
  transform: rotate(90deg);
}

.hamburger-line {
  fill: none;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  transition: all 0.3s ease;
}

.toolbar-content {
  display: flex;
  align-items: center;
  gap: 16px;
  opacity: 1;
  max-width: none;
  overflow: hidden;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.toolbar-content.collapsed {
  opacity: 0;
  max-width: 0;
  margin: 0;
  padding: 0;
  gap: 0;
}

.tool-group {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: rgba(15, 23, 42, 0.6);
  border-radius: 12px;
  border: 1px solid rgba(100, 181, 246, 0.15);
  min-height: 44px;
  flex-shrink: 0;
}

.tool-group:not(:last-child) {
  border-right: none;
}

.tool-button {
  background: rgba(51, 65, 85, 0.8);
  border: 1px solid rgba(100, 181, 246, 0.2);
  border-radius: 8px;
  padding: 8px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(255, 255, 255, 0.8);
  position: relative;
  overflow: hidden;
}

.tool-button::before {
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

.tool-button:hover {
  transform: translateY(-1px) scale(1.02);
  box-shadow: 0 4px 12px rgba(30, 136, 229, 0.3);
  border-color: rgba(100, 181, 246, 0.4);
  color: #64b5f6;
}

.tool-button:hover::before {
  opacity: 1;
}

.tool-button.active {
  background: linear-gradient(135deg, #1e88e5, #42a5f5);
  color: white;
  border-color: rgba(100, 181, 246, 0.8);
  box-shadow: 
    0 4px 16px rgba(30, 136, 229, 0.4),
    inset 0 1px 0 rgba(255, 255, 255, 0.2);
}

.tool-button svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
  position: relative;
  z-index: 1;
}

.toolbar-label {
  color: rgba(255, 255, 255, 0.6);
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
  margin-right: 6px;
}

.line-type-selector {
  display: flex;
  gap: 4px;
}

.line-type-button {
  background: rgba(51, 65, 85, 0.8);
  border: 1px solid rgba(100, 181, 246, 0.2);
  border-radius: 6px;
  padding: 4px 8px;
  color: rgba(255, 255, 255, 0.7);
  font-size: 11px;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
  font-weight: 500;
}

.line-type-button:hover {
  background: rgba(100, 181, 246, 0.1);
  color: #64b5f6;
  border-color: rgba(100, 181, 246, 0.3);
}

.line-type-button.active {
  background: linear-gradient(135deg, #1e88e5, #42a5f5);
  color: white;
  border-color: rgba(100, 181, 246, 0.8);
  box-shadow: 0 2px 8px rgba(30, 136, 229, 0.3);
}

.width-slider,
.opacity-slider {
  width: 80px;
  height: 4px;
  background: rgba(51, 65, 85, 0.8);
  border-radius: 2px;
  outline: none;
  cursor: pointer;
  -webkit-appearance: none;
  appearance: none;
}

.width-slider::-webkit-slider-thumb,
.opacity-slider::-webkit-slider-thumb {
  appearance: none;
  width: 16px;
  height: 16px;
  background: linear-gradient(135deg, #1e88e5, #42a5f5);
  border-radius: 50%;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(30, 136, 229, 0.4);
  transition: all 0.3s ease;
}

.width-slider::-webkit-slider-thumb:hover,
.opacity-slider::-webkit-slider-thumb:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(30, 136, 229, 0.5);
}

.width-slider::-moz-range-thumb,
.opacity-slider::-moz-range-thumb {
  width: 16px;
  height: 16px;
  background: linear-gradient(135deg, #1e88e5, #42a5f5);
  border-radius: 50%;
  cursor: pointer;
  border: none;
  box-shadow: 0 2px 8px rgba(30, 136, 229, 0.4);
}

.color-input {
  width: 32px;
  height: 32px;
  border: 2px solid rgba(100, 181, 246, 0.3);
  border-radius: 8px;
  cursor: pointer;
  padding: 0;
  overflow: hidden;
  transition: all 0.3s ease;
}

.color-input:hover {
  border-color: rgba(100, 181, 246, 0.6);
  transform: scale(1.05);
  box-shadow: 0 2px 8px rgba(30, 136, 229, 0.3);
}

.color-input::-webkit-color-swatch-wrapper {
  padding: 0;
}

.color-input::-webkit-color-swatch {
  border: none;
  border-radius: 6px;
}

.fill-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.fill-checkbox {
  width: 16px;
  height: 16px;
  accent-color: #1e88e5;
  cursor: pointer;
}

.action-button {
  background: linear-gradient(135deg, #1e88e5, #42a5f5);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 8px 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
  box-shadow: 0 2px 8px rgba(30, 136, 229, 0.3);
}

.action-button:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 16px rgba(30, 136, 229, 0.4);
}

.action-button.clear {
  background: linear-gradient(135deg, #dc2626, #b91c1c);
  box-shadow: 0 2px 8px rgba(220, 38, 38, 0.3);
}

.action-button.clear:hover {
  box-shadow: 0 4px 16px rgba(220, 38, 38, 0.4);
}

.action-button.save {
  background: linear-gradient(135deg, #059669, #047857);
  box-shadow: 0 2px 8px rgba(5, 150, 105, 0.3);
}

.action-button.save:hover {
  box-shadow: 0 4px 16px rgba(5, 150, 105, 0.4);
}

/* アニメーション */
@keyframes slideInUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.toolbar-content:not(.collapsed) {
  animation: slideInUp 0.4s ease-out;
}

/* モバイル対応 */
@media (max-width: 768px) {
  .bottom-toolbar {
    bottom: 16px;
    left: 16px;
    right: 16px;
    transform: none;
    max-width: none;
    flex-wrap: wrap;
  }
  
  .bottom-toolbar.collapsed {
    left: 50%;
    right: auto;
    transform: translateX(-50%);
    width: 60px;
  }
  
  .toolbar-content {
    flex-wrap: wrap;
    gap: 8px;
  }
  
  .tool-group {
    padding: 6px 8px;
    gap: 6px;
    min-height: 36px;
  }
  
  .tool-button {
    width: 32px;
    height: 32px;
    padding: 6px;
  }
  
  .tool-button svg {
    width: 16px;
    height: 16px;
  }
  
  .hamburger-button {
    width: 36px;
    height: 36px;
  }
  
  .hamburger-icon {
    width: 18px;
    height: 18px;
  }
  
  .width-slider,
  .opacity-slider {
    width: 60px;
  }
  
  .color-input {
    width: 28px;
    height: 28px;
  }
  
  .toolbar-label {
    font-size: 10px;
  }
}
</style>
