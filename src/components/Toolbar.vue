<script setup>
import { ref } from 'vue'

const emit = defineEmits(['tool-select'])

const tools = ref([
  { id: 'pen', name: 'ペン', icon: '✏️' },
  { id: 'eraser', name: '消しゴム', icon: '🗑️' },
  { id: 'shapes', name: '図形', icon: '◯' },
  { id: 'spreadsheet', name: '表計算', icon: '📊' },
  { id: 'chart', name: 'グラフ', icon: '📈' },
  { id: 'communication', name: '通話', icon: '📞' },
])

const activeTool = ref('pen')

const selectTool = (toolId) => {
  activeTool.value = toolId
  emit('tool-select', toolId)
}
</script>

<template>
  <div class="toolbar">
    <div class="tool-group">
      <button
        v-for="tool in tools"
        :key="tool.id"
        :class="['tool-btn', { active: activeTool === tool.id }]"
        @click="selectTool(tool.id)"
        :title="tool.name"
      >
        <span class="tool-icon">{{ tool.icon }}</span>
        <span class="tool-name">{{ tool.name }}</span>
      </button>
    </div>
  </div>
</template>

<style scoped>
.toolbar {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.tool-group {
  display: flex;
  gap: 0.25rem;
  background: rgba(255, 255, 255, 0.1);
  padding: 0.5rem;
  border-radius: 1rem;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  position: relative;
  overflow: hidden;
}

.tool-group::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: conic-gradient(transparent, rgba(255, 255, 255, 0.1), transparent);
  animation: rotate 4s linear infinite;
  z-index: -1;
}

@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.tool-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 0.75rem;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  position: relative;
  overflow: hidden;
  backdrop-filter: blur(5px);
}

.tool-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.tool-btn:hover::before {
  left: 100%;
}

.tool-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  border-color: rgba(255, 255, 255, 0.4);
  transform: translateY(-2px) scale(1.05);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.tool-btn.active {
  background: linear-gradient(135deg, rgba(100, 181, 246, 0.3), rgba(142, 68, 173, 0.3));
  border-color: rgba(255, 255, 255, 0.6);
  box-shadow: 
    0 0 20px rgba(100, 181, 246, 0.4),
    inset 0 1px 0 rgba(255, 255, 255, 0.3);
}

.tool-icon {
  font-size: 1.2rem;
  filter: drop-shadow(0 0 5px rgba(255, 255, 255, 0.3));
}

.tool-name {
  font-size: 0.875rem;
  white-space: nowrap;
  font-weight: 500;
  text-shadow: 0 0 10px rgba(255, 255, 255, 0.2);
}

@media (max-width: 768px) {
  .tool-name {
    display: none;
  }
  
  .tool-btn {
    padding: 0.75rem;
    border-radius: 50%;
    width: 48px;
    height: 48px;
    justify-content: center;
  }
  
  .tool-group {
    border-radius: 2rem;
  }
}
</style>
