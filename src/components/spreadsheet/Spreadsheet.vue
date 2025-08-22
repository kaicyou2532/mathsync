<script setup>
import { ref, computed } from 'vue'
import { evaluate } from 'mathjs'

const rows = ref(10)
const cols = ref(6)

// スプレッドシートデータを初期化
const initializeData = () => {
  const data = {}
  for (let row = 0; row < rows.value; row++) {
    for (let col = 0; col < cols.value; col++) {
      const cellId = `${String.fromCharCode(65 + col)}${row + 1}`
      data[cellId] = { formula: '', value: '', display: '' }
    }
  }
  return data
}

const spreadsheetData = ref(initializeData())
const selectedCell = ref(null)
const formulaInput = ref('')

// セルの選択
const selectCell = (cellId) => {
  selectedCell.value = cellId
  formulaInput.value = spreadsheetData.value[cellId]?.formula || ''
}

// セルの値を更新
const updateCell = (cellId, formula) => {
  if (!spreadsheetData.value[cellId]) return

  spreadsheetData.value[cellId].formula = formula
  
  try {
    if (formula.startsWith('=')) {
      // 数式の場合
      const expression = formula.substring(1)
      const result = evaluateFormula(expression)
      spreadsheetData.value[cellId].value = result
      spreadsheetData.value[cellId].display = result.toString()
    } else {
      // 通常の値の場合
      spreadsheetData.value[cellId].value = formula
      spreadsheetData.value[cellId].display = formula
    }
  } catch (error) {
    spreadsheetData.value[cellId].value = '#ERROR'
    spreadsheetData.value[cellId].display = '#ERROR'
  }
}

// 数式の評価
const evaluateFormula = (expression) => {
  // セル参照を値に置換
  let processedExpression = expression
  
  // A1形式のセル参照を置換
  const cellRegex = /([A-Z])(\d+)/g
  processedExpression = processedExpression.replace(cellRegex, (match, col, row) => {
    const cellId = `${col}${row}`
    const cellValue = spreadsheetData.value[cellId]?.value || 0
    return isNaN(cellValue) ? 0 : cellValue
  })

  // Math.jsで評価
  return evaluate(processedExpression)
}

// フォーミュラ入力の処理
const handleFormulaSubmit = () => {
  if (selectedCell.value) {
    updateCell(selectedCell.value, formulaInput.value)
  }
}

// グリッドのヘッダー
const columnHeaders = computed(() => {
  return Array.from({ length: cols.value }, (_, i) => String.fromCharCode(65 + i))
})

const rowHeaders = computed(() => {
  return Array.from({ length: rows.value }, (_, i) => i + 1)
})

// サンプルデータの設定
const setSampleData = () => {
  updateCell('A1', '10')
  updateCell('A2', '20')
  updateCell('A3', '30')
  updateCell('B1', '=A1*2')
  updateCell('B2', '=A2*2')
  updateCell('B3', '=A3*2')
  updateCell('C1', '=sum([10, 20, 30])')
}
</script>

<template>
  <div class="spreadsheet">
    <div class="spreadsheet-header">
      <h3>表計算・数式エンジン</h3>
      <button @click="setSampleData" class="sample-btn">サンプルデータ</button>
    </div>

    <div class="formula-bar">
      <label>数式:</label>
      <input
        v-model="formulaInput"
        @keyup.enter="handleFormulaSubmit"
        placeholder="=A1+B1 または 値を入力"
        class="formula-input"
      />
      <button @click="handleFormulaSubmit" class="apply-btn">適用</button>
    </div>

    <div class="grid-container">
      <div class="grid">
        <!-- ヘッダー行 -->
        <div class="cell header-cell"></div>
        <div v-for="col in columnHeaders" :key="col" class="cell header-cell">
          {{ col }}
        </div>

        <!-- データ行 -->
        <template v-for="row in rowHeaders" :key="row">
          <div class="cell header-cell">{{ row }}</div>
          <div
            v-for="col in columnHeaders"
            :key="`${col}${row}`"
            :class="['cell', 'data-cell', { 
              selected: selectedCell === `${col}${row}` 
            }]"
            @click="selectCell(`${col}${row}`)"
          >
            {{ spreadsheetData[`${col}${row}`]?.display || '' }}
          </div>
        </template>
      </div>
    </div>

    <div class="math-functions">
      <h4>利用可能な関数</h4>
      <div class="function-list">
        <span class="function">sum([a,b,c])</span>
        <span class="function">mean([a,b,c])</span>
        <span class="function">sqrt(x)</span>
        <span class="function">pow(x,y)</span>
        <span class="function">matrix([[1,2],[3,4]])</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.spreadsheet {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 1.5rem;
  font-size: 0.875rem;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9) 0%, rgba(248, 250, 252, 0.9) 100%);
  position: relative;
}

.spreadsheet::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 30% 20%, rgba(52, 211, 153, 0.05) 0%, transparent 50%),
    radial-gradient(circle at 70% 80%, rgba(139, 92, 246, 0.05) 0%, transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.spreadsheet-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  position: relative;
  z-index: 2;
}

.spreadsheet-header h3 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 700;
  background: linear-gradient(135deg, #34d399, #8b5cf6);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.sample-btn {
  padding: 0.5rem 1rem;
  background: linear-gradient(135deg, #34d399, #10b981);
  color: white;
  border: none;
  border-radius: 0.75rem;
  cursor: pointer;
  font-size: 0.75rem;
  font-weight: 600;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  box-shadow: 0 4px 15px rgba(52, 211, 153, 0.3);
  position: relative;
  overflow: hidden;
}

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

.sample-btn:hover::before {
  left: 100%;
}

.sample-btn:hover {
  transform: translateY(-2px) scale(1.05);
  box-shadow: 0 8px 25px rgba(52, 211, 153, 0.4);
}

.formula-bar {
  display: flex;
  gap: 0.75rem;
  align-items: center;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 1rem;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  position: relative;
  z-index: 2;
}

.formula-bar label {
  font-weight: 600;
  color: #4a5568;
  text-shadow: 0 1px 2px rgba(255, 255, 255, 0.8);
}

.formula-input {
  flex: 1;
  padding: 0.75rem;
  border: 1px solid rgba(139, 92, 246, 0.2);
  border-radius: 0.75rem;
  font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
  background: rgba(255, 255, 255, 0.9);
  transition: all 0.3s ease;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.05);
}

.formula-input:focus {
  outline: none;
  border-color: #8b5cf6;
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
  background: white;
}

.apply-btn {
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, #8b5cf6, #7c3aed);
  color: white;
  border: none;
  border-radius: 0.75rem;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  box-shadow: 0 4px 15px rgba(139, 92, 246, 0.3);
}

.apply-btn:hover {
  transform: translateY(-2px) scale(1.05);
  box-shadow: 0 8px 25px rgba(139, 92, 246, 0.4);
}

.grid-container {
  flex: 1;
  overflow: auto;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 1rem;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  box-shadow: 
    0 20px 40px rgba(0, 0, 0, 0.1),
    inset 0 1px 0 rgba(255, 255, 255, 0.8);
  position: relative;
  z-index: 1;
}

.grid {
  display: grid;
  grid-template-columns: 50px repeat(6, 100px);
  gap: 1px;
  background: linear-gradient(135deg, #e2e8f0, #f1f5f9);
}

.cell {
  padding: 0.5rem;
  background: white;
  border: none;
  font-size: 0.75rem;
  min-height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  position: relative;
}

.header-cell {
  background: linear-gradient(135deg, #f8fafc, #e2e8f0);
  font-weight: 700;
  text-align: center;
  color: #475569;
  border-right: 1px solid rgba(203, 213, 225, 0.5);
  border-bottom: 1px solid rgba(203, 213, 225, 0.5);
}

.data-cell {
  cursor: pointer;
  text-align: right;
  padding-right: 0.75rem;
  border-right: 1px solid rgba(226, 232, 240, 0.3);
  border-bottom: 1px solid rgba(226, 232, 240, 0.3);
}

.data-cell:hover {
  background: linear-gradient(135deg, #f0f9ff, #e0f2fe);
  transform: scale(1.02);
  z-index: 2;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.data-cell.selected {
  background: linear-gradient(135deg, #dbeafe, #bfdbfe);
  border: 2px solid #3b82f6;
  box-shadow: 
    0 0 0 2px rgba(59, 130, 246, 0.2),
    0 4px 12px rgba(59, 130, 246, 0.15);
  z-index: 3;
}

.math-functions {
  margin-top: 1.5rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 1rem;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  z-index: 2;
}

.math-functions h4 {
  margin: 0 0 0.75rem 0;
  font-size: 1rem;
  font-weight: 700;
  color: #374151;
}

.function-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.function {
  background: linear-gradient(135deg, #f3f4f6, #e5e7eb);
  padding: 0.375rem 0.75rem;
  border-radius: 0.5rem;
  font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
  font-size: 0.75rem;
  font-weight: 500;
  color: #6b7280;
  border: 1px solid rgba(209, 213, 219, 0.5);
  transition: all 0.2s ease;
  cursor: default;
}

.function:hover {
  background: linear-gradient(135deg, #e5e7eb, #d1d5db);
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
</style>
