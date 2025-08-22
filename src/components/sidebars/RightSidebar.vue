<template>
  <div class="right-sidebar">
    <div class="sidebar-header">
      <button @click="$emit('toggle')" class="close-btn">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="18" y1="6" x2="6" y2="18"></line>
          <line x1="6" y1="6" x2="18" y2="18"></line>
        </svg>
      </button>
    </div>

    <div class="function-buttons">
      <button 
        v-for="func in functions" 
        :key="func.id"
        @click="selectFunction(func.id)"
        :class="['function-btn', { active: activeFunction === func.id }]"
        :title="func.name"
      >
        <div class="function-icon" v-html="func.icon"></div>
        <span class="function-label">{{ func.label }}</span>
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const emit = defineEmits(['toggle', 'function-select'])

const activeFunction = ref(null)

const functions = ref([
  { 
    id: 'spreadsheet', 
    name: '表計算・数式エンジン', 
    icon: `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <rect width="18" height="18" x="3" y="3" rx="2"></rect>
      <path d="M9 3v18"></path>
      <path d="M15 3v18"></path>
      <path d="M3 9h18"></path>
      <path d="M3 15h18"></path>
    </svg>`, 
    label: '表計算' 
  },
  { 
    id: 'chart', 
    name: 'データビジュアライゼーション', 
    icon: `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M3 3v18h18"></path>
      <path d="m19 9-5 5-4-4-3 3"></path>
    </svg>`, 
    label: 'グラフ' 
  },
  { 
    id: 'communication', 
    name: 'オンライン通話・コミュニケーション', 
    icon: `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
    </svg>`, 
    label: '通話' 
  }
])

const selectFunction = (functionId) => {
  if (activeFunction.value === functionId) {
    // 同じ機能をクリックした場合は無効化
    activeFunction.value = null
    emit('function-select', null)
  } else {
    activeFunction.value = functionId
    emit('function-select', functionId)
  }
}
</script>

<style scoped>
.right-sidebar {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-left: 1px solid rgba(0, 0, 0, 0.1);
}

.sidebar-header {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
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

.function-buttons {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1rem;
}

.function-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 0.5rem;
  background: rgba(240, 240, 240, 0.8);
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 1rem;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  position: relative;
  overflow: hidden;
  backdrop-filter: blur(5px);
}

.function-btn::before {
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

.function-btn:hover {
  transform: translateY(-2px) scale(1.02);
  box-shadow: 0 8px 25px rgba(30, 136, 229, 0.3);
  border-color: rgba(100, 181, 246, 0.4);
}

.function-btn:hover::before {
  opacity: 1;
}

.function-btn.active {
  background: linear-gradient(135deg, #1e88e5, #42a5f5);
  border-color: rgba(100, 181, 246, 0.8);
  box-shadow: 
    0 8px 25px rgba(30, 136, 229, 0.4),
    inset 0 1px 0 rgba(255, 255, 255, 0.2);
}

.function-btn.active::before {
  opacity: 0;
}

.function-icon {
  color: rgba(0, 0, 0, 0.7);
  position: relative;
  z-index: 1;
  transition: all 0.3s ease;
}

.function-btn:hover .function-icon {
  color: #64b5f6;
}

.function-btn.active .function-icon {
  color: white;
}

.function-icon svg {
  width: 24px;
  height: 24px;
  stroke-width: 2;
}

.function-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: rgba(0, 0, 0, 0.7);
  text-align: center;
  line-height: 1.2;
  position: relative;
  z-index: 1;
  transition: all 0.3s ease;
}

.function-btn:hover .function-label {
  color: #64b5f6;
}

.function-btn.active .function-label {
  color: white;
}

/* レスポンシブ対応 */
@media (max-width: 768px) {
  .right-sidebar {
    width: 60px;
  }
  
  .function-btn {
    padding: 0.75rem 0.25rem;
    gap: 0.25rem;
  }
  
  .function-icon svg {
    width: 20px;
    height: 20px;
  }
  
  .function-label {
    font-size: 0.6rem;
  }
}

.function-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
}

.function-btn:hover::before {
  opacity: 1;
}

.function-btn:hover {
  transform: translateY(-3px) scale(1.05);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border-color: rgba(102, 126, 234, 0.3);
}

.function-btn.active {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.2), rgba(118, 75, 162, 0.2));
  border-color: rgba(102, 126, 234, 0.5);
  box-shadow: 
    0 0 20px rgba(102, 126, 234, 0.3),
    inset 0 1px 0 rgba(255, 255, 255, 0.3);
}

.function-icon {
  font-size: 2rem;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
  position: relative;
  z-index: 1;
}

.function-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: #374151;
  text-align: center;
  line-height: 1.2;
  position: relative;
  z-index: 1;
}

.function-btn.active .function-label {
  color: #667eea;
}

@media (max-width: 768px) {
  .function-btn {
    padding: 0.75rem 0.25rem;
  }
  
  .function-icon {
    font-size: 1.5rem;
  }
  
  .function-label {
    font-size: 0.625rem;
  }
}
</style>
