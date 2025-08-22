<script setup>
import { ref, onMounted, watch } from 'vue'

const props = defineProps({
  currentTool: String,
  strokeColor: String,
  strokeWidth: Number,
  fillColor: String
})

const canvasRef = ref(null)
const isDrawing = ref(false)

let ctx = null
let lastX = 0
let lastY = 0

onMounted(() => {
  const canvas = canvasRef.value
  ctx = canvas.getContext('2d')
  
  // キャンバスのサイズ設定
  const resizeCanvas = () => {
    const container = canvas.parentElement
    if (container) {
      const rect = container.getBoundingClientRect()
      canvas.width = rect.width - 40
      canvas.height = rect.height - 40
      // 背景を白に設定
      ctx.fillStyle = 'white'
      ctx.fillRect(0, 0, canvas.width, canvas.height)
    }
  }
  
  resizeCanvas()
  window.addEventListener('resize', resizeCanvas)
  
  // 描画設定
  ctx.lineCap = 'round'
  ctx.lineJoin = 'round'
})

// プロパティの変更を監視
watch(() => props.strokeColor, (newColor) => {
  if (ctx) {
    ctx.strokeStyle = newColor
  }
})

watch(() => props.strokeWidth, (newWidth) => {
  if (ctx) {
    ctx.lineWidth = newWidth
  }
})

watch(() => props.currentTool, (newTool) => {
  if (newTool === 'clear') {
    clearCanvas()
  } else if (newTool === 'save') {
    saveCanvas()
  }
})

const startDrawing = (e) => {
  if (!props.currentTool || ['select', 'measure', 'protractor'].includes(props.currentTool)) return
  
  isDrawing.value = true
  const rect = canvasRef.value.getBoundingClientRect()
  lastX = e.clientX - rect.left
  lastY = e.clientY - rect.top
  
  // ツールに応じた開始処理
  if (props.currentTool === 'pen' || props.currentTool === 'brush' || props.currentTool === 'pencil') {
    ctx.beginPath()
    ctx.moveTo(lastX, lastY)
  }
}

const draw = (e) => {
  if (!isDrawing.value) return
  
  const rect = canvasRef.value.getBoundingClientRect()
  const currentX = e.clientX - rect.left
  const currentY = e.clientY - rect.top
  
  ctx.strokeStyle = props.strokeColor || '#000000'
  ctx.lineWidth = props.strokeWidth || 2
  
  switch (props.currentTool) {
    case 'pen':
    case 'brush':
    case 'pencil':
      ctx.lineTo(currentX, currentY)
      ctx.stroke()
      break
      
    case 'eraser':
      ctx.globalCompositeOperation = 'destination-out'
      ctx.beginPath()
      ctx.arc(currentX, currentY, props.strokeWidth * 2, 0, 2 * Math.PI)
      ctx.fill()
      ctx.globalCompositeOperation = 'source-over'
      break
  }
  
  lastX = currentX
  lastY = currentY
}

const stopDrawing = (e) => {
  if (!isDrawing.value) return
  
  const rect = canvasRef.value.getBoundingClientRect()
  const currentX = e.clientX - rect.left
  const currentY = e.clientY - rect.top
  
  // 図形描画の完了処理
  switch (props.currentTool) {
    case 'rectangle':
      drawRectangle(lastX, lastY, currentX - lastX, currentY - lastY)
      break
    case 'circle':
      const radius = Math.sqrt(Math.pow(currentX - lastX, 2) + Math.pow(currentY - lastY, 2))
      drawCircle(lastX, lastY, radius)
      break
    case 'triangle':
      drawTriangle(lastX, lastY, currentX, currentY)
      break
    case 'line':
      drawLine(lastX, lastY, currentX, currentY)
      break
    case 'arrow':
      drawArrow(lastX, lastY, currentX, currentY)
      break
  }
  
  isDrawing.value = false
}

const drawRectangle = (x, y, width, height) => {
  ctx.strokeStyle = props.strokeColor || '#000000'
  ctx.lineWidth = props.strokeWidth || 2
  
  if (props.fillColor && props.fillColor !== '#ffffff') {
    ctx.fillStyle = props.fillColor
    ctx.fillRect(x, y, width, height)
  }
  ctx.strokeRect(x, y, width, height)
}

const drawCircle = (x, y, radius) => {
  ctx.strokeStyle = props.strokeColor || '#000000'
  ctx.lineWidth = props.strokeWidth || 2
  
  ctx.beginPath()
  ctx.arc(x, y, radius, 0, 2 * Math.PI)
  
  if (props.fillColor && props.fillColor !== '#ffffff') {
    ctx.fillStyle = props.fillColor
    ctx.fill()
  }
  ctx.stroke()
}

const drawTriangle = (x1, y1, x2, y2) => {
  const x3 = x1 - (x2 - x1)
  const y3 = y2
  
  ctx.strokeStyle = props.strokeColor || '#000000'
  ctx.lineWidth = props.strokeWidth || 2
  
  ctx.beginPath()
  ctx.moveTo(x1, y1)
  ctx.lineTo(x2, y2)
  ctx.lineTo(x3, y3)
  ctx.closePath()
  
  if (props.fillColor && props.fillColor !== '#ffffff') {
    ctx.fillStyle = props.fillColor
    ctx.fill()
  }
  ctx.stroke()
}

const drawLine = (x1, y1, x2, y2) => {
  ctx.strokeStyle = props.strokeColor || '#000000'
  ctx.lineWidth = props.strokeWidth || 2
  
  ctx.beginPath()
  ctx.moveTo(x1, y1)
  ctx.lineTo(x2, y2)
  ctx.stroke()
}

const drawArrow = (x1, y1, x2, y2) => {
  const headlen = 15
  const dx = x2 - x1
  const dy = y2 - y1
  const angle = Math.atan2(dy, dx)
  
  ctx.strokeStyle = props.strokeColor || '#000000'
  ctx.lineWidth = props.strokeWidth || 2
  
  // 矢印の線
  ctx.beginPath()
  ctx.moveTo(x1, y1)
  ctx.lineTo(x2, y2)
  ctx.stroke()
  
  // 矢印の頭
  ctx.beginPath()
  ctx.moveTo(x2, y2)
  ctx.lineTo(x2 - headlen * Math.cos(angle - Math.PI / 6), y2 - headlen * Math.sin(angle - Math.PI / 6))
  ctx.moveTo(x2, y2)
  ctx.lineTo(x2 - headlen * Math.cos(angle + Math.PI / 6), y2 - headlen * Math.sin(angle + Math.PI / 6))
  ctx.stroke()
}

const clearCanvas = () => {
  const canvas = canvasRef.value
  ctx.fillStyle = 'white'
  ctx.fillRect(0, 0, canvas.width, canvas.height)
}

const saveCanvas = () => {
  const canvas = canvasRef.value
  const link = document.createElement('a')
  link.download = 'whiteboard.png'
  link.href = canvas.toDataURL()
  link.click()
}

// テキスト追加（クリック時）
const addText = (e) => {
  if (props.currentTool !== 'text') return
  
  const rect = canvasRef.value.getBoundingClientRect()
  const x = e.clientX - rect.left
  const y = e.clientY - rect.top
  
  const text = prompt('テキストを入力してください:')
  if (text) {
    ctx.fillStyle = props.strokeColor || '#000000'
    ctx.font = `${props.strokeWidth * 8}px Arial`
    ctx.fillText(text, x, y)
  }
}

const handleCanvasClick = (e) => {
  if (props.currentTool === 'text') {
    addText(e)
  }
}

const getCursor = () => {
  switch (props.currentTool) {
    case 'pen':
    case 'brush':
    case 'pencil':
      return 'crosshair'
    case 'eraser':
      return 'grab'
    case 'text':
      return 'text'
    case 'select':
      return 'pointer'
    case 'measure':
      return 'crosshair'
    default:
      return 'crosshair'
  }
}
</script>

<template>
  <div class="whiteboard">
    <div class="canvas-container">
      <canvas 
        ref="canvasRef"
        @mousedown="startDrawing"
        @mousemove="draw"
        @mouseup="stopDrawing"
        @mouseleave="stopDrawing"
        @click="handleCanvasClick"
        :style="{ cursor: getCursor() }"
      ></canvas>
    </div>
  </div>
</template>

<style scoped>
.whiteboard {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9) 0%, rgba(248, 250, 252, 0.9) 100%);
  position: relative;
}

.whiteboard::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 20% 30%, rgba(100, 181, 246, 0.02) 0%, transparent 50%),
    radial-gradient(circle at 80% 70%, rgba(142, 68, 173, 0.02) 0%, transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.canvas-container {
  flex: 1;
  margin: 20px;
  border-radius: 1.5rem;
  overflow: hidden;
  position: relative;
  background: white;
  box-shadow: 
    0 20px 40px rgba(0, 0, 0, 0.08),
    inset 0 1px 0 rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(10px);
  z-index: 1;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.canvas-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    linear-gradient(45deg, transparent 48%, rgba(102, 126, 234, 0.015) 49%, rgba(102, 126, 234, 0.015) 51%, transparent 52%),
    linear-gradient(-45deg, transparent 48%, rgba(118, 75, 162, 0.015) 49%, rgba(118, 75, 162, 0.015) 51%, transparent 52%);
  background-size: 30px 30px;
  pointer-events: none;
  z-index: 0;
  opacity: 0.5;
}

canvas {
  display: block;
  position: relative;
  z-index: 1;
  width: 100%;
  height: 100%;
}

/* ツールカーソルのスタイル調整 */
canvas[style*="cursor: crosshair"] {
  cursor: crosshair;
}

canvas[style*="cursor: grab"] {
  cursor: grab;
}

canvas[style*="cursor: text"] {
  cursor: text;
}

canvas[style*="cursor: pointer"] {
  cursor: pointer;
}
</style>
