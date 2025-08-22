<script setup>
import { ref, onMounted } from 'vue'
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
  LineElement,
  PointElement
} from 'chart.js'
import { Bar, Line } from 'vue-chartjs'

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
  LineElement,
  PointElement
)

const chartType = ref('bar')
const chartData = ref({
  labels: ['項目1', '項目2', '項目3', '項目4', '項目5'],
  datasets: [
    {
      label: 'データセット1',
      backgroundColor: '#42A5F5',
      borderColor: '#1E88E5',
      data: [40, 39, 10, 40, 39]
    }
  ]
})

const chartOptions = ref({
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    title: {
      display: true,
      text: 'データビジュアライゼーション'
    },
    legend: {
      position: 'top'
    }
  },
  scales: {
    y: {
      beginAtZero: true
    }
  }
})

// サンプルデータのパターン
const sampleDatasets = {
  linear: {
    labels: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
    datasets: [{
      label: '線形関数 y=2x+1',
      backgroundColor: '#42A5F5',
      borderColor: '#1E88E5',
      data: [3, 5, 7, 9, 11, 13, 15, 17, 19, 21]
    }]
  },
  quadratic: {
    labels: ['-4', '-3', '-2', '-1', '0', '1', '2', '3', '4'],
    datasets: [{
      label: '二次関数 y=x²',
      backgroundColor: '#66BB6A',
      borderColor: '#43A047',
      data: [16, 9, 4, 1, 0, 1, 4, 9, 16]
    }]
  },
  sin: {
    labels: ['0', 'π/4', 'π/2', '3π/4', 'π', '5π/4', '3π/2', '7π/4', '2π'],
    datasets: [{
      label: '三角関数 sin(x)',
      backgroundColor: '#FF7043',
      borderColor: '#F4511E',
      data: [0, 0.7, 1, 0.7, 0, -0.7, -1, -0.7, 0]
    }]
  }
}

const loadSampleData = (type) => {
  chartData.value = { ...sampleDatasets[type] }
}

// スプレッドシートからデータを取得する関数（将来の機能）
const importFromSpreadsheet = () => {
  // 将来的にはスプレッドシートコンポーネントからデータを取得
  console.log('スプレッドシートからデータをインポート')
}

const addDataPoint = () => {
  const newLabel = `項目${chartData.value.labels.length + 1}`
  const newValue = Math.floor(Math.random() * 50) + 10
  
  chartData.value.labels.push(newLabel)
  chartData.value.datasets[0].data.push(newValue)
}

const clearData = () => {
  chartData.value = {
    labels: [],
    datasets: [{
      label: 'データセット1',
      backgroundColor: '#42A5F5',
      borderColor: '#1E88E5',
      data: []
    }]
  }
}
</script>

<template>
  <div class="chart-viewer">
    <div class="chart-header">
      <h3>グラフビューワー</h3>
      <div class="chart-controls">
        <select v-model="chartType" class="chart-type-select">
          <option value="bar">棒グラフ</option>
          <option value="line">線グラフ</option>
        </select>
      </div>
    </div>

    <div class="chart-container">
      <Bar
        v-if="chartType === 'bar'"
        :data="chartData"
        :options="chartOptions"
      />
      <Line
        v-else-if="chartType === 'line'"
        :data="chartData"
        :options="chartOptions"
      />
    </div>

    <div class="data-controls">
      <h4>データ操作</h4>
      <div class="control-buttons">
        <button @click="addDataPoint" class="control-btn">データ追加</button>
        <button @click="clearData" class="control-btn danger">クリア</button>
      </div>
      
      <div class="sample-data">
        <h5>サンプルデータ</h5>
        <div class="sample-buttons">
          <button @click="loadSampleData('linear')" class="sample-btn">線形関数</button>
          <button @click="loadSampleData('quadratic')" class="sample-btn">二次関数</button>
          <button @click="loadSampleData('sin')" class="sample-btn">三角関数</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.chart-viewer {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 1.5rem;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9) 0%, rgba(248, 250, 252, 0.9) 100%);
  position: relative;
}

.chart-viewer::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 25% 25%, rgba(239, 68, 68, 0.05) 0%, transparent 50%),
    radial-gradient(circle at 75% 75%, rgba(245, 158, 11, 0.05) 0%, transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  position: relative;
  z-index: 2;
}

.chart-header h3 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 700;
  background: linear-gradient(135deg, #ef4444, #f59e0b);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.chart-type-select {
  padding: 0.75rem 1rem;
  border: 1px solid rgba(239, 68, 68, 0.2);
  border-radius: 0.75rem;
  font-size: 0.875rem;
  font-weight: 500;
  background: rgba(255, 255, 255, 0.9);
  color: #374151;
  cursor: pointer;
  transition: all 0.3s ease;
  backdrop-filter: blur(5px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.chart-type-select:focus {
  outline: none;
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}

.chart-container {
  flex: 1;
  min-height: 200px;
  margin-bottom: 1.5rem;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 1rem;
  padding: 1rem;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  box-shadow: 
    0 20px 40px rgba(0, 0, 0, 0.1),
    inset 0 1px 0 rgba(255, 255, 255, 0.8);
  position: relative;
  z-index: 1;
}

.data-controls {
  border-top: 1px solid rgba(229, 231, 235, 0.5);
  padding-top: 1.5rem;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 1rem;
  padding: 1.5rem;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  z-index: 2;
}

.data-controls h4 {
  margin: 0 0 1rem 0;
  font-size: 1rem;
  font-weight: 700;
  color: #374151;
}

.data-controls h5 {
  margin: 1.5rem 0 0.75rem 0;
  font-size: 0.875rem;
  font-weight: 600;
  color: #6b7280;
}

.control-buttons,
.sample-buttons {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.control-btn,
.sample-btn {
  padding: 0.75rem 1.25rem;
  border: none;
  border-radius: 0.75rem;
  cursor: pointer;
  font-size: 0.875rem;
  font-weight: 600;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  position: relative;
  overflow: hidden;
}

.control-btn::before,
.sample-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.5s;
}

.control-btn:hover::before,
.sample-btn:hover::before {
  left: 100%;
}

.control-btn {
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
  color: white;
  box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
}

.control-btn:hover {
  transform: translateY(-2px) scale(1.05);
  box-shadow: 0 8px 25px rgba(59, 130, 246, 0.4);
}

.control-btn.danger {
  background: linear-gradient(135deg, #ef4444, #dc2626);
  box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
}

.control-btn.danger:hover {
  box-shadow: 0 8px 25px rgba(239, 68, 68, 0.4);
}

.sample-btn {
  background: linear-gradient(135deg, #10b981, #059669);
  color: white;
  box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
}

.sample-btn:hover {
  transform: translateY(-2px) scale(1.05);
  box-shadow: 0 8px 25px rgba(16, 185, 129, 0.4);
}
</style>
