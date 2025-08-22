<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const isConnected = ref(false)
const isMuted = ref(false)
const isVideoOff = ref(false)
const participants = ref([
  { id: 1, name: 'あなた', status: 'active' }
])

const connectionStatus = ref('disconnected') // disconnected, connecting, connected
const roomId = ref('room-' + Math.random().toString(36).substr(2, 9))

// WebRTC関連の状態
const localStream = ref(null)
const videoRef = ref(null)

onMounted(() => {
  // 初期化処理
})

onUnmounted(() => {
  // クリーンアップ
  if (localStream.value) {
    localStream.value.getTracks().forEach(track => track.stop())
  }
})

const connectToRoom = async () => {
  try {
    connectionStatus.value = 'connecting'
    
    // メディアストリームの取得
    const stream = await navigator.mediaDevices.getUserMedia({
      video: true,
      audio: true
    })
    
    localStream.value = stream
    if (videoRef.value) {
      videoRef.value.srcObject = stream
    }
    
    // 実際のWebRTC接続はここで実装
    // 今回はモックとして状態を更新
    setTimeout(() => {
      connectionStatus.value = 'connected'
      isConnected.value = true
      
      // サンプル参加者を追加
      participants.value.push(
        { id: 2, name: '参加者A', status: 'active' },
        { id: 3, name: '参加者B', status: 'muted' }
      )
    }, 2000)
    
  } catch (error) {
    console.error('メディア取得エラー:', error)
    connectionStatus.value = 'disconnected'
    alert('カメラ・マイクへのアクセスが拒否されました')
  }
}

const disconnectFromRoom = () => {
  if (localStream.value) {
    localStream.value.getTracks().forEach(track => track.stop())
    localStream.value = null
  }
  
  if (videoRef.value) {
    videoRef.value.srcObject = null
  }
  
  connectionStatus.value = 'disconnected'
  isConnected.value = false
  participants.value = [{ id: 1, name: 'あなた', status: 'active' }]
}

const toggleMute = () => {
  isMuted.value = !isMuted.value
  if (localStream.value) {
    const audioTracks = localStream.value.getAudioTracks()
    audioTracks.forEach(track => {
      track.enabled = !isMuted.value
    })
  }
  
  // 自分の状態を更新
  const selfParticipant = participants.value.find(p => p.id === 1)
  if (selfParticipant) {
    selfParticipant.status = isMuted.value ? 'muted' : 'active'
  }
}

const toggleVideo = () => {
  isVideoOff.value = !isVideoOff.value
  if (localStream.value) {
    const videoTracks = localStream.value.getVideoTracks()
    videoTracks.forEach(track => {
      track.enabled = !isVideoOff.value
    })
  }
}

const copyRoomId = () => {
  navigator.clipboard.writeText(roomId.value)
  alert('ルームIDをコピーしました')
}

const openDiscord = () => {
  window.open('https://discord.com', '_blank')
}

const openZoom = () => {
  window.open('https://zoom.us', '_blank')
}
</script>

<template>
  <div class="communication-panel">
    <div class="panel-header">
      <h3>通話・コミュニケーション</h3>
    </div>

    <div class="connection-section">
      <div class="room-info">
        <label>ルームID:</label>
        <div class="room-id-container">
          <code class="room-id">{{ roomId }}</code>
          <button @click="copyRoomId" class="copy-btn" title="コピー">📋</button>
        </div>
      </div>

      <div class="connection-controls">
        <button
          v-if="!isConnected"
          @click="connectToRoom"
          :disabled="connectionStatus === 'connecting'"
          class="connect-btn"
        >
          {{ connectionStatus === 'connecting' ? '接続中...' : '通話に参加' }}
        </button>
        
        <button
          v-else
          @click="disconnectFromRoom"
          class="disconnect-btn"
        >
          通話を終了
        </button>
      </div>
    </div>

    <!-- ビデオプレビュー -->
    <div v-if="isConnected" class="video-section">
      <div class="video-container">
        <video
          ref="videoRef"
          autoplay
          muted
          playsinline
          class="local-video"
        ></video>
        <div class="video-overlay">
          <span class="video-label">あなた</span>
        </div>
      </div>

      <div class="video-controls">
        <button
          @click="toggleMute"
          :class="['control-btn', { active: isMuted }]"
          :title="isMuted ? 'ミュート解除' : 'ミュート'"
        >
          {{ isMuted ? '🔇' : '🎤' }}
        </button>
        
        <button
          @click="toggleVideo"
          :class="['control-btn', { active: isVideoOff }]"
          :title="isVideoOff ? 'ビデオ開始' : 'ビデオ停止'"
        >
          {{ isVideoOff ? '📹' : '📷' }}
        </button>
      </div>
    </div>

    <!-- 参加者リスト -->
    <div class="participants-section">
      <h4>参加者 ({{ participants.length }})</h4>
      <div class="participants-list">
        <div
          v-for="participant in participants"
          :key="participant.id"
          class="participant"
        >
          <span class="participant-name">{{ participant.name }}</span>
          <span
            :class="['participant-status', participant.status]"
            :title="participant.status === 'muted' ? 'ミュート中' : 'アクティブ'"
          >
            {{ participant.status === 'muted' ? '🔇' : '🎤' }}
          </span>
        </div>
      </div>
    </div>

    <!-- 外部ツール連携 -->
    <div class="external-tools">
      <h4>外部ツール</h4>
      <div class="tool-buttons">
        <button @click="openDiscord" class="tool-btn discord">
          Discord
        </button>
        <button @click="openZoom" class="tool-btn zoom">
          Zoom
        </button>
      </div>
      <p class="tool-note">
        外部の通話アプリと併用することもできます
      </p>
    </div>
  </div>
</template>

<style scoped>
.communication-panel {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 1.5rem;
  font-size: 0.875rem;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9) 0%, rgba(248, 250, 252, 0.9) 100%);
  position: relative;
}

.communication-panel::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 20% 80%, rgba(168, 85, 247, 0.05) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, rgba(34, 197, 94, 0.05) 0%, transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.panel-header h3 {
  margin: 0 0 1.5rem 0;
  font-size: 1.25rem;
  font-weight: 700;
  background: linear-gradient(135deg, #a855f7, #22c55e);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  position: relative;
  z-index: 2;
}

.connection-section {
  margin-bottom: 1.5rem;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 1rem;
  padding: 1rem;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  position: relative;
  z-index: 2;
}

.room-info {
  margin-bottom: 0.75rem;
}

.room-info label {
  display: block;
  font-weight: 700;
  margin-bottom: 0.5rem;
  color: #374151;
}

.room-id-container {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.room-id {
  background: linear-gradient(135deg, #f8fafc, #f1f5f9);
  padding: 0.75rem 1rem;
  border-radius: 0.75rem;
  font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
  font-size: 0.75rem;
  flex: 1;
  border: 1px solid rgba(203, 213, 225, 0.5);
  color: #475569;
}

.copy-btn {
  padding: 0.75rem;
  background: linear-gradient(135deg, #6b7280, #4b5563);
  color: white;
  border: none;
  border-radius: 0.75rem;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  box-shadow: 0 4px 15px rgba(107, 114, 128, 0.3);
}

.copy-btn:hover {
  transform: translateY(-2px) scale(1.05);
  box-shadow: 0 8px 25px rgba(107, 114, 128, 0.4);
}

.connect-btn {
  width: 100%;
  padding: 1rem;
  background: linear-gradient(135deg, #22c55e, #16a34a);
  color: white;
  border: none;
  border-radius: 0.75rem;
  cursor: pointer;
  font-weight: 700;
  font-size: 1rem;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  box-shadow: 0 4px 15px rgba(34, 197, 94, 0.3);
  position: relative;
  overflow: hidden;
}

.connect-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.5s;
}

.connect-btn:hover::before {
  left: 100%;
}

.connect-btn:hover {
  transform: translateY(-2px) scale(1.02);
  box-shadow: 0 8px 25px rgba(34, 197, 94, 0.4);
}

.connect-btn:disabled {
  background: linear-gradient(135deg, #9ca3af, #6b7280);
  cursor: not-allowed;
  transform: none;
  box-shadow: 0 4px 15px rgba(156, 163, 175, 0.3);
}

.disconnect-btn {
  width: 100%;
  padding: 1rem;
  background: linear-gradient(135deg, #ef4444, #dc2626);
  color: white;
  border: none;
  border-radius: 0.75rem;
  cursor: pointer;
  font-weight: 700;
  font-size: 1rem;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
}

.disconnect-btn:hover {
  transform: translateY(-2px) scale(1.02);
  box-shadow: 0 8px 25px rgba(239, 68, 68, 0.4);
}

.video-section {
  margin-bottom: 1.5rem;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 1rem;
  padding: 1rem;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  z-index: 2;
}

.video-container {
  position: relative;
  width: 100%;
  height: 150px;
  background: linear-gradient(135deg, #1f2937, #111827);
  border-radius: 1rem;
  overflow: hidden;
  margin-bottom: 1rem;
  box-shadow: 
    0 20px 40px rgba(0, 0, 0, 0.2),
    inset 0 1px 0 rgba(255, 255, 255, 0.1);
}

.local-video {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.video-overlay {
  position: absolute;
  bottom: 0.75rem;
  left: 0.75rem;
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 0.5rem 0.75rem;
  border-radius: 0.5rem;
  font-size: 0.75rem;
  font-weight: 600;
  backdrop-filter: blur(10px);
}

.video-controls {
  display: flex;
  gap: 0.75rem;
  justify-content: center;
}

.control-btn {
  width: 50px;
  height: 50px;
  border: none;
  border-radius: 50%;
  cursor: pointer;
  font-size: 1.5rem;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
  color: white;
  box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
  position: relative;
  overflow: hidden;
}

.control-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.3), transparent);
  opacity: 0;
  transition: opacity 0.3s;
}

.control-btn:hover::before {
  opacity: 1;
}

.control-btn:hover {
  transform: translateY(-2px) scale(1.1);
  box-shadow: 0 8px 25px rgba(59, 130, 246, 0.4);
}

.control-btn.active {
  background: linear-gradient(135deg, #ef4444, #dc2626);
  box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
}

.control-btn.active:hover {
  box-shadow: 0 8px 25px rgba(239, 68, 68, 0.4);
}

.participants-section {
  margin-bottom: 1.5rem;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 1rem;
  padding: 1rem;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  z-index: 2;
}

.participants-section h4 {
  margin: 0 0 0.75rem 0;
  font-size: 1rem;
  font-weight: 700;
  color: #374151;
}

.participants-list {
  max-height: 120px;
  overflow-y: auto;
}

.participant {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0;
  border-bottom: 1px solid rgba(229, 231, 235, 0.3);
  transition: all 0.2s ease;
}

.participant:hover {
  background: rgba(249, 250, 251, 0.5);
  border-radius: 0.5rem;
  padding-left: 0.5rem;
  padding-right: 0.5rem;
}

.participant-name {
  flex: 1;
  font-weight: 500;
  color: #374151;
}

.participant-status.muted {
  color: #ef4444;
  font-size: 1.1rem;
}

.participant-status.active {
  color: #22c55e;
  font-size: 1.1rem;
}

.external-tools {
  background: rgba(255, 255, 255, 0.8);
  border-radius: 1rem;
  padding: 1rem;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  z-index: 2;
}

.external-tools h4 {
  margin: 0 0 0.75rem 0;
  font-size: 1rem;
  font-weight: 700;
  color: #374151;
}

.tool-buttons {
  display: flex;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}

.tool-btn {
  flex: 1;
  padding: 0.75rem;
  border: none;
  border-radius: 0.75rem;
  cursor: pointer;
  font-weight: 700;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  position: relative;
  overflow: hidden;
}

.tool-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.5s;
}

.tool-btn:hover::before {
  left: 100%;
}

.tool-btn.discord {
  background: linear-gradient(135deg, #5865F2, #4752C4);
  color: white;
  box-shadow: 0 4px 15px rgba(88, 101, 242, 0.3);
}

.tool-btn.discord:hover {
  transform: translateY(-2px) scale(1.05);
  box-shadow: 0 8px 25px rgba(88, 101, 242, 0.4);
}

.tool-btn.zoom {
  background: linear-gradient(135deg, #2D8CFF, #1E6FCC);
  color: white;
  box-shadow: 0 4px 15px rgba(45, 140, 255, 0.3);
}

.tool-btn.zoom:hover {
  transform: translateY(-2px) scale(1.05);
  box-shadow: 0 8px 25px rgba(45, 140, 255, 0.4);
}

.tool-note {
  font-size: 0.75rem;
  color: #6b7280;
  margin: 0;
  text-align: center;
  font-style: italic;
}
</style>
