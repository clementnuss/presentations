<script setup>
import { ref, computed, watch, onBeforeUnmount } from 'vue'

// Layout constants
const W = 520
const H = 340
const NGINX_X = 100
const TOMCAT_X = 420
const TIMELINE_Y = 60
const TIMELINE_H = 240
const MID_X = (NGINX_X + TOMCAT_X) / 2

// Timing (in seconds of simulation)
const TOMCAT_TIMEOUT = 20
const NGINX_TIMEOUT = 60
const TOTAL_DURATION = 26 // we only show up to ~26s

// Playback state
const time = ref(0)
const playing = ref(false)
const speed = ref(1)
let animFrame = null
let lastTs = null

// Events timeline (in sim seconds)
// 0s: request #1 sent
// 1s: 200 OK received
// 1s: idle timer starts
// 20s: Tomcat sends FIN
// 19.9s: nginx sends request #2 (the race!)
// 20.1s: RST received, 502

const REQUEST1_SEND = 0
const REQUEST1_RECV = 0.8
const RESPONSE1_SEND = 1.2
const RESPONSE1_RECV = 2.0
const TOMCAT_IDLE_START = 1.2  // Tomcat is idle as soon as it sends the response
const NGINX_IDLE_START = 2.0   // nginx is idle when it receives the response
const TOMCAT_FIN_SEND = TOMCAT_IDLE_START + TOMCAT_TIMEOUT  // 21.2s
const NGINX_REQ2_SEND = 21.3  // nginx sends just after FIN departs — packets cross in flight
const FIN_ARRIVE = 21.8
const REQ2_ARRIVE = 21.9
const RST_SEND = 22.1
const RST_ARRIVE = 22.7
const SHOW_502 = 22.8

// Packet travel helpers
function packetProgress(sendTime, arriveTime) {
  if (time.value < sendTime) return -1
  if (time.value > arriveTime) return 2
  return (time.value - sendTime) / (arriveTime - sendTime)
}

function packetPos(fromX, toX, progress) {
  return fromX + (toX - fromX) * Math.max(0, Math.min(1, progress))
}

function timeToY(t) {
  return TIMELINE_Y + (t / TOTAL_DURATION) * TIMELINE_H
}

// Packets
const packets = computed(() => {
  const list = []

  // Request #1: nginx → tomcat
  const p1 = packetProgress(REQUEST1_SEND, REQUEST1_RECV)
  if (p1 >= 0 && p1 <= 1) {
    list.push({
      x: packetPos(NGINX_X, TOMCAT_X, p1),
      y: timeToY(REQUEST1_SEND + p1 * (REQUEST1_RECV - REQUEST1_SEND)),
      label: 'GET /api',
      color: '#ff7f15',
      id: 'req1',
    })
  }

  // Response #1: tomcat → nginx
  const p2 = packetProgress(RESPONSE1_SEND, RESPONSE1_RECV)
  if (p2 >= 0 && p2 <= 1) {
    list.push({
      x: packetPos(TOMCAT_X, NGINX_X, p2),
      y: timeToY(RESPONSE1_SEND + p2 * (RESPONSE1_RECV - RESPONSE1_SEND)),
      label: '200 OK',
      color: '#22c55e',
      id: 'res1',
    })
  }

  // FIN: tomcat → nginx
  const p3 = packetProgress(TOMCAT_FIN_SEND, FIN_ARRIVE)
  if (p3 >= 0 && p3 <= 1) {
    list.push({
      x: packetPos(TOMCAT_X, NGINX_X, p3),
      y: timeToY(TOMCAT_FIN_SEND + p3 * (FIN_ARRIVE - TOMCAT_FIN_SEND)),
      label: 'FIN',
      color: '#dc2626',
      id: 'fin',
    })
  }

  // Request #2: nginx → tomcat (the ill-fated one)
  const p4 = packetProgress(NGINX_REQ2_SEND, REQ2_ARRIVE)
  if (p4 >= 0 && p4 <= 1) {
    list.push({
      x: packetPos(NGINX_X, TOMCAT_X, p4),
      y: timeToY(NGINX_REQ2_SEND + p4 * (REQ2_ARRIVE - NGINX_REQ2_SEND)),
      label: 'GET /api',
      color: '#ff7f15',
      id: 'req2',
    })
  }

  // RST: tomcat → nginx
  const p5 = packetProgress(RST_SEND, RST_ARRIVE)
  if (p5 >= 0 && p5 <= 1) {
    list.push({
      x: packetPos(TOMCAT_X, NGINX_X, p5),
      y: timeToY(RST_SEND + p5 * (RST_ARRIVE - RST_SEND)),
      label: 'RST',
      color: '#dc2626',
      id: 'rst',
    })
  }

  return list
})

// Timer bar progress
const nginxTimerPct = computed(() => {
  if (time.value < NGINX_IDLE_START) return 0
  return Math.min(1, (time.value - NGINX_IDLE_START) / NGINX_TIMEOUT)
})

const tomcatTimerPct = computed(() => {
  if (time.value < TOMCAT_IDLE_START) return 0
  return Math.min(1, (time.value - TOMCAT_IDLE_START) / TOMCAT_TIMEOUT)
})

const tomcatTimerExpired = computed(() => time.value >= TOMCAT_IDLE_START + TOMCAT_TIMEOUT)

// Status labels
const nginxStatus = computed(() => {
  if (time.value < REQUEST1_SEND) return 'idle'
  if (time.value < RESPONSE1_RECV) return 'waiting...'
  if (time.value < NGINX_REQ2_SEND) return 'keepalive'
  if (time.value < SHOW_502) return 'sending req #2'
  return '502 !'
})

const tomcatStatus = computed(() => {
  if (time.value < REQUEST1_RECV) return 'listening'
  if (time.value < RESPONSE1_SEND) return 'processing'
  if (time.value < TOMCAT_FIN_SEND) return 'keepalive'
  if (time.value < RST_SEND) return 'closing...'
  return 'closed'
})

const show502 = computed(() => time.value >= SHOW_502)

// Idle timer display (seconds since nginx idle start)
const idleSeconds = computed(() => {
  if (time.value < NGINX_IDLE_START) return null
  return Math.min(time.value - NGINX_IDLE_START, NGINX_TIMEOUT).toFixed(1)
})

// Tomcat countdown (20s → 0)
const tomcatCountdown = computed(() => {
  if (time.value < TOMCAT_IDLE_START) return null
  const remaining = TOMCAT_TIMEOUT - (time.value - TOMCAT_IDLE_START)
  if (remaining < 0) return '0.0'
  return remaining.toFixed(1)
})

// Playback controls
function tick(ts) {
  if (!playing.value) { lastTs = null; return }
  if (lastTs !== null) {
    const dt = (ts - lastTs) / 1000 * speed.value
    time.value = Math.min(time.value + dt, TOTAL_DURATION)
    if (time.value >= TOTAL_DURATION) {
      playing.value = false
    }
  }
  lastTs = ts
  animFrame = requestAnimationFrame(tick)
}

function play() {
  if (time.value >= TOTAL_DURATION) time.value = 0
  playing.value = true
  lastTs = null
  animFrame = requestAnimationFrame(tick)
}

function pause() {
  playing.value = false
}

function replay() {
  time.value = 0
  play()
}

watch(playing, (val) => {
  if (val) {
    lastTs = null
    animFrame = requestAnimationFrame(tick)
  }
})

onBeforeUnmount(() => {
  if (animFrame) cancelAnimationFrame(animFrame)
})

// Scrub via slider
function scrub(e) {
  pause()
  time.value = parseFloat(e.target.value)
}
</script>

<template>
  <div class="race-widget">
    <!-- Controls -->
    <div class="controls">
      <button class="play-btn" @click="playing ? pause() : play()">
        {{ playing ? '⏸' : '▶' }}
      </button>
      <button class="play-btn" @click="replay">↻</button>
      <input
        type="range" min="0" :max="TOTAL_DURATION" step="0.05"
        :value="time"
        @input="scrub"
        class="scrubber"
      />
      <label class="speed-label">
        {{ speed }}x
        <input type="range" min="0.25" max="3" step="0.25" v-model.number="speed" class="speed-slider" />
      </label>
    </div>

    <!-- SVG -->
    <svg :viewBox="`0 0 ${W} ${H}`" class="race-svg">
      <!-- Column headers -->
      <text :x="NGINX_X" :y="28" text-anchor="middle" class="col-header">ingress-nginx</text>
      <text :x="NGINX_X" :y="42" text-anchor="middle" class="col-sub">keepalive: 60s</text>
      <text :x="TOMCAT_X" :y="28" text-anchor="middle" class="col-header">Tomcat</text>
      <text :x="TOMCAT_X" :y="42" text-anchor="middle" class="col-sub">keepalive: 20s</text>

      <!-- Lifelines -->
      <line :x1="NGINX_X" :y1="TIMELINE_Y" :x2="NGINX_X" :y2="TIMELINE_Y + TIMELINE_H" class="lifeline" />
      <line :x1="TOMCAT_X" :y1="TIMELINE_Y" :x2="TOMCAT_X" :y2="TIMELINE_Y + TIMELINE_H" class="lifeline" />

      <!-- Time cursor -->
      <line
        :x1="NGINX_X - 30" :y1="timeToY(time)"
        :x2="TOMCAT_X + 30" :y2="timeToY(time)"
        class="time-cursor"
      />

      <!-- Idle period bracket -->
      <rect
        v-if="time >= TOMCAT_IDLE_START"
        :x="NGINX_X + 10" :y="timeToY(TOMCAT_IDLE_START)"
        :width="TOMCAT_X - NGINX_X - 20"
        :height="Math.max(0, timeToY(Math.min(time, TOMCAT_IDLE_START + TOMCAT_TIMEOUT)) - timeToY(TOMCAT_IDLE_START))"
        class="idle-zone"
      />
      <text
        v-if="idleSeconds !== null"
        :x="MID_X" :y="timeToY(Math.min(NGINX_IDLE_START + 10, time))"
        text-anchor="middle" class="idle-label"
      >idle: {{ idleSeconds }}s</text>

      <!-- Timer bars -->
      <!-- Tomcat timer -->
      <rect
        v-if="time >= TOMCAT_IDLE_START"
        :x="TOMCAT_X + 14" :y="timeToY(TOMCAT_IDLE_START)"
        width="8"
        :height="Math.max(0, tomcatTimerPct * (timeToY(TOMCAT_IDLE_START + TOMCAT_TIMEOUT) - timeToY(TOMCAT_IDLE_START)))"
        :class="['timer-bar', { expired: tomcatTimerExpired }]"
        rx="3"
      />
      <text
        v-if="tomcatCountdown !== null"
        :x="TOMCAT_X + 30"
        :y="timeToY(Math.min(time, TOMCAT_IDLE_START + TOMCAT_TIMEOUT))"
        class="tomcat-countdown"
        :class="{ urgent: parseFloat(tomcatCountdown) < 2 }"
      >{{ tomcatCountdown }}s</text>

      <!-- Packet trails (static lines for completed packets) -->
      <!-- req1 line -->
      <line v-if="time >= REQUEST1_RECV"
        :x1="NGINX_X" :y1="timeToY(REQUEST1_SEND)"
        :x2="TOMCAT_X" :y2="timeToY(REQUEST1_RECV)"
        class="trail trail-orange"
      />
      <!-- res1 line -->
      <line v-if="time >= RESPONSE1_RECV"
        :x1="TOMCAT_X" :y1="timeToY(RESPONSE1_SEND)"
        :x2="NGINX_X" :y2="timeToY(RESPONSE1_RECV)"
        class="trail trail-green"
      />
      <!-- FIN line -->
      <line v-if="time >= TOMCAT_FIN_SEND"
        :x1="TOMCAT_X" :y1="timeToY(TOMCAT_FIN_SEND)"
        :x2="packetPos(TOMCAT_X, NGINX_X, packetProgress(TOMCAT_FIN_SEND, FIN_ARRIVE) > 1 ? 1 : Math.max(0, packetProgress(TOMCAT_FIN_SEND, FIN_ARRIVE)))"
        :y2="timeToY(Math.min(time, FIN_ARRIVE))"
        class="trail trail-red"
        stroke-dasharray="4 3"
      />
      <!-- req2 line -->
      <line v-if="time >= NGINX_REQ2_SEND"
        :x1="NGINX_X" :y1="timeToY(NGINX_REQ2_SEND)"
        :x2="packetPos(NGINX_X, TOMCAT_X, packetProgress(NGINX_REQ2_SEND, REQ2_ARRIVE) > 1 ? 1 : Math.max(0, packetProgress(NGINX_REQ2_SEND, REQ2_ARRIVE)))"
        :y2="timeToY(Math.min(time, REQ2_ARRIVE))"
        class="trail trail-orange"
      />
      <!-- RST line -->
      <line v-if="time >= RST_SEND"
        :x1="TOMCAT_X" :y1="timeToY(RST_SEND)"
        :x2="packetPos(TOMCAT_X, NGINX_X, packetProgress(RST_SEND, RST_ARRIVE) > 1 ? 1 : Math.max(0, packetProgress(RST_SEND, RST_ARRIVE)))"
        :y2="timeToY(Math.min(time, RST_ARRIVE))"
        class="trail trail-red"
      />

      <!-- Animated packet dots -->
      <g v-for="pkt in packets" :key="pkt.id">
        <circle :cx="pkt.x" :cy="pkt.y" r="5" :fill="pkt.color" class="packet-dot" />
        <text
          :x="pkt.x" :y="pkt.y - 9"
          text-anchor="middle" class="packet-label"
          :fill="pkt.color"
        >{{ pkt.label }}</text>
      </g>

      <!-- 502 explosion -->
      <g v-if="show502">
        <rect
          :x="NGINX_X - 58" :y="timeToY(SHOW_502) - 14"
          width="116" height="28" rx="6"
          fill="#dc2626"
        />
        <text
          :x="NGINX_X" :y="timeToY(SHOW_502) + 5"
          text-anchor="middle"
          class="label-502"
        >502 Bad Gateway</text>
      </g>

      <!-- Status indicators -->
      <text :x="NGINX_X" :y="TIMELINE_Y + TIMELINE_H + 18" text-anchor="middle" class="status-text">
        {{ nginxStatus }}
      </text>
      <text :x="TOMCAT_X" :y="TIMELINE_Y + TIMELINE_H + 18" text-anchor="middle" class="status-text">
        {{ tomcatStatus }}
      </text>
    </svg>
  </div>
</template>

<style scoped>
.race-widget {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  font-family: 'Inter', sans-serif;
}

.controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.play-btn {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  border: 1.5px solid #ff7f15;
  background: white;
  color: #ff7f15;
  font-size: 14px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  transition: all 0.15s;
}
.play-btn:hover {
  background: #ff7f15;
  color: white;
}

.scrubber {
  width: 160px;
  accent-color: #ff7f15;
  height: 4px;
}

.speed-label {
  font-size: 10px;
  color: #888;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1px;
}

.speed-slider {
  width: 50px;
  accent-color: #ff7f15;
  height: 3px;
}

.race-svg {
  width: 100%;
  max-width: 520px;
}

.col-header {
  font-size: 13px;
  font-weight: 700;
  fill: #333;
}

.col-sub {
  font-size: 10px;
  fill: #999;
}

.lifeline {
  stroke: #bbb;
  stroke-width: 2;
  stroke-dasharray: 6 4;
}

.time-cursor {
  stroke: #ff7f15;
  stroke-width: 1;
  opacity: 0.4;
  stroke-dasharray: 3 3;
}

.idle-zone {
  fill: rgba(59, 130, 246, 0.06);
  stroke: rgba(59, 130, 246, 0.15);
  stroke-width: 1;
  rx: 4;
}

.idle-label {
  font-size: 11px;
  fill: #6b7280;
  font-weight: 500;
}

.timer-bar {
  fill: #3b82f6;
  opacity: 0.6;
  transition: fill 0.3s;
}
.timer-bar.expired {
  fill: #dc2626;
}

.tomcat-countdown {
  font-size: 10px;
  fill: #3b82f6;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
  transition: fill 0.3s;
}
.tomcat-countdown.urgent {
  fill: #dc2626;
}

.trail {
  stroke-width: 1.5;
  opacity: 0.5;
}
.trail-orange { stroke: #ff7f15; }
.trail-green { stroke: #22c55e; }
.trail-red { stroke: #dc2626; }

.packet-dot {
  filter: drop-shadow(0 0 3px rgba(0,0,0,0.2));
}

.packet-label {
  font-size: 9px;
  font-weight: 700;
}

.label-502 {
  fill: white;
  font-size: 13px;
  font-weight: 800;
}

.status-text {
  font-size: 11px;
  fill: #666;
  font-weight: 500;
}
</style>
