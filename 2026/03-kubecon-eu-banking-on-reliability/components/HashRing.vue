<script setup>
import { ref, computed, watch, onMounted } from 'vue'

const nodeCount = ref(15)
const neighborCount = ref(5)
const selectedNode = ref(null)
const showAllToAll = ref(false)
const showAllFiltered = ref(false)
const hashOrder = ref(true)

// SHA-256 via Web Crypto — returns first 32 bits as uint32
async function sha256_32(str) {
  const data = new TextEncoder().encode(str)
  const buf = await crypto.subtle.digest('SHA-256', data)
  return new DataView(buf).getUint32(0)
}

const CX = 170
const CY = 170
const R = 140

function nodeColor(originalIndex, total) {
  const hue = (originalIndex / total) * 360
  return `hsl(${hue}, 70%, 55%)`
}

// Precomputed hash cache: "node-01" → uint32
const hashCache = ref(new Map())

async function computeHashes(count) {
  const map = new Map()
  for (let i = 0; i < count; i++) {
    const name = `node-${String(i + 1).padStart(2, '0')}`
    map.set(name, await sha256_32(name))
  }
  hashCache.value = map
}

onMounted(() => computeHashes(nodeCount.value))
watch(nodeCount, (n) => computeHashes(n))

const nodes = computed(() => {
  if (hashCache.value.size < nodeCount.value) return []
  const arr = []
  for (let i = 0; i < nodeCount.value; i++) {
    const name = `node-${String(i + 1).padStart(2, '0')}`
    const hash = hashCache.value.get(name)
    arr.push({ name, hash, originalIndex: i })
  }
  arr.sort((a, b) => a.hash - b.hash)
  const withRingIndex = arr.map((n, i) => ({ ...n, ringIndex: i }))

  return withRingIndex.map((n) => {
    const pos = hashOrder.value ? n.ringIndex : n.originalIndex
    const angle = (pos / nodeCount.value) * 2 * Math.PI - Math.PI / 2
    return {
      ...n,
      angle,
      x: CX + R * Math.cos(angle),
      y: CY + R * Math.sin(angle),
      color: nodeColor(n.originalIndex, nodeCount.value),
    }
  })
})

const effectiveNeighborCount = computed(() =>
  Math.min(neighborCount.value, nodeCount.value - 1)
)

function getNeighborIndices(ringIndex) {
  const indices = []
  for (let j = 1; j <= effectiveNeighborCount.value; j++) {
    indices.push((ringIndex + j) % nodeCount.value)
  }
  return indices
}

const connections = computed(() => {
  if (showAllToAll.value) {
    // O(n²): every node to every other node
    const lines = []
    for (let i = 0; i < nodes.value.length; i++) {
      for (let j = i + 1; j < nodes.value.length; j++) {
        lines.push({ from: nodes.value[i], to: nodes.value[j] })
      }
    }
    return lines
  }
  return []
})

const neighborConnections = computed(() => {
  if (showAllToAll.value) return []
  if (showAllFiltered.value) {
    // Show every node's neighbor connections
    const lines = []
    for (let ri = 0; ri < nodes.value.length; ri++) {
      const from = nodes.value[ri]
      const indices = getNeighborIndices(ri)
      for (const i of indices) {
        lines.push({ from, to: nodes.value[i], id: `${from.name}-${nodes.value[i].name}` })
      }
    }
    return lines
  }
  if (selectedNode.value === null) return []
  const sel = nodes.value[selectedNode.value]
  if (!sel) return []
  const indices = getNeighborIndices(selectedNode.value)
  return indices.map(i => ({ from: sel, to: nodes.value[i], id: `${sel.name}-${nodes.value[i].name}` }))
})

// Shorten line so arrow doesn't overlap the target node dot
function shortenedLine(from, to, margin = 12) {
  const dx = to.x - from.x
  const dy = to.y - from.y
  const len = Math.sqrt(dx * dx + dy * dy)
  if (len < margin * 2) return { x1: from.x, y1: from.y, x2: to.x, y2: to.y }
  const ratio = (len - margin) / len
  return { x1: from.x, y1: from.y, x2: from.x + dx * ratio, y2: from.y + dy * ratio }
}

const totalChecks = computed(() => {
  const n = nodeCount.value
  if (showAllToAll.value) return n * (n - 1)
  return n * effectiveNeighborCount.value
})

function isNeighbor(ringIndex) {
  if (selectedNode.value === null) return false
  return getNeighborIndices(selectedNode.value).includes(ringIndex)
}

function selectNode(ringIndex) {
  selectedNode.value = selectedNode.value === ringIndex ? null : ringIndex
}

// Reset selection when toggling modes; keep them mutually exclusive
watch(showAllToAll, (val) => {
  selectedNode.value = null
  if (val) showAllFiltered.value = false
})
watch(showAllFiltered, (val) => {
  if (val) showAllToAll.value = false
})

// Clamp neighbor count when node count decreases
watch(nodeCount, (n) => {
  if (neighborCount.value >= n) {
    neighborCount.value = n - 1
  }
})
</script>

<template>
  <div class="hash-ring-widget">
    <!-- Controls row -->
    <div class="controls">
      <label>
        <span class="label-text">Nodes: <strong>{{ nodeCount }}</strong></span>
        <input type="range" min="5" max="30" v-model.number="nodeCount" />
      </label>
      <label>
        <span class="label-text">Neighbors: <strong>{{ effectiveNeighborCount }}</strong></span>
        <input type="range" min="1" :max="nodeCount - 1" v-model.number="neighborCount" />
      </label>
      <button
        :class="['toggle-btn', 'order-toggle', { active: hashOrder }]"
        @click="hashOrder = !hashOrder"
      >
        {{ hashOrder ? '🔀 hash order' : '🔢 linear order' }}
      </button>
    </div>
    <div class="controls">
      <button
        :class="['toggle-btn', 'order-toggle', { active: showAllFiltered }]"
        @click="showAllFiltered = !showAllFiltered"
      >
        {{ showAllFiltered ? '✓ all O(n)' : '⊙ all O(n)' }}
      </button>
      <button
        :class="['toggle-btn', { active: showAllToAll }]"
        @click="showAllToAll = !showAllToAll"
      >
        {{ showAllToAll ? 'O(n²) all-to-all' : 'O(n²)' }}
      </button>
    </div>

    <!-- SVG visualization -->
    <svg viewBox="0 0 340 340" class="ring-svg">
      <defs>
        <marker id="arrowhead" markerWidth="8" markerHeight="6" refX="7" refY="3" orient="auto">
          <polygon points="0 0, 8 3, 0 6" fill="#ff7f15" opacity="0.8" />
        </marker>
      </defs>

      <!-- Ring circle -->
      <circle :cx="CX" :cy="CY" :r="R" class="ring-circle" />

      <!-- Tick marks -->
      <line
        v-for="i in 60"
        :key="'tick-' + i"
        :x1="CX + (R - 4) * Math.cos((i / 60) * 2 * Math.PI)"
        :y1="CY + (R - 4) * Math.sin((i / 60) * 2 * Math.PI)"
        :x2="CX + (R + 4) * Math.cos((i / 60) * 2 * Math.PI)"
        :y2="CY + (R + 4) * Math.sin((i / 60) * 2 * Math.PI)"
        class="tick"
      />

      <!-- O(n²) connections -->
      <line
        v-for="(c, i) in connections"
        :key="'all-' + i"
        :x1="c.from.x" :y1="c.from.y"
        :x2="c.to.x" :y2="c.to.y"
        class="connection-all"
      />

      <!-- Neighbor connections with arrows -->
      <line
        v-for="c in neighborConnections"
        :key="c.id"
        :x1="shortenedLine(c.from, c.to).x1"
        :y1="shortenedLine(c.from, c.to).y1"
        :x2="shortenedLine(c.from, c.to).x2"
        :y2="shortenedLine(c.from, c.to).y2"
        class="connection-neighbor"
        marker-end="url(#arrowhead)"
      />

      <!-- Nodes -->
      <g
        v-for="node in nodes"
        :key="node.name"
        class="node-group"
        :class="{
          selected: selectedNode === node.ringIndex,
          neighbor: isNeighbor(node.ringIndex),
          dimmed: showAllToAll
        }"
        @click="selectNode(node.ringIndex)"
        style="cursor: pointer"
      >
        <circle
          :cx="node.x" :cy="node.y" r="10"
          class="node-dot"
          :style="{ fill: node.color, transition: 'cx 0.6s ease, cy 0.6s ease' }"
        />
        <text
          :x="CX + (R + 24) * Math.cos(node.angle)"
          :y="CY + (R + 24) * Math.sin(node.angle)"
          class="node-label"
          text-anchor="middle"
          dominant-baseline="central"
          :style="{ transition: 'x 0.6s ease, y 0.6s ease' }"
        >{{ node.name.replace('node-', '') }}</text>
      </g>
    </svg>

    <!-- Stats -->
    <div class="stats">
      Total checks: <strong :class="{ red: showAllToAll }">{{ totalChecks }}</strong>
      <span class="formula">
        ({{ nodeCount }} × {{ showAllToAll ? (nodeCount - 1) : effectiveNeighborCount }})
      </span>
      <span v-if="!showAllToAll && selectedNode !== null" class="hint">
        ← click a node
      </span>
      <span v-if="!showAllToAll && selectedNode === null" class="hint">
        click a node to see its neighbors
      </span>
    </div>
  </div>
</template>

<style scoped>
.hash-ring-widget {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  font-family: 'Inter', sans-serif;
  color: #333;
}

.controls {
  display: flex;
  gap: 12px;
  align-items: center;
  flex-wrap: wrap;
  justify-content: center;
}

.controls label {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
}

.label-text {
  font-size: 11px;
  color: #555;
}

.controls input[type="range"] {
  width: 90px;
  accent-color: #ff7f15;
  height: 4px;
}

.toggle-btn {
  font-size: 11px;
  padding: 4px 10px;
  border-radius: 12px;
  border: 1.5px solid #ff7f15;
  background: white;
  color: #ff7f15;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s;
}
.toggle-btn.active {
  background: #dc2626;
  border-color: #dc2626;
  color: white;
}
.toggle-btn.order-toggle.active {
  background: #ff7f15;
  border-color: #ff7f15;
}

.ring-svg {
  width: 100%;
  max-width: 340px;
}

.ring-circle {
  fill: none;
  stroke: #ddd;
  stroke-width: 1.5;
}

.tick {
  stroke: #ccc;
  stroke-width: 0.5;
}

.connection-all {
  stroke: #dc2626;
  stroke-width: 0.3;
  opacity: 0.35;
}

.connection-neighbor {
  stroke: #ff7f15;
  stroke-width: 1.5;
  opacity: 0.7;
}

.node-dot {
  stroke: white;
  stroke-width: 2;
  transition: all 0.2s;
}

.node-group.selected .node-dot {
  r: 13;
  stroke-width: 2.5;
  filter: brightness(0.85);
}

.node-group.neighbor .node-dot {
  r: 11;
}

.node-group.dimmed .node-dot {
  opacity: 0.5;
  filter: saturate(0.3);
}

.node-label {
  font-size: 8px;
  fill: #666;
  pointer-events: none;
  user-select: none;
}

.node-group.selected .node-label,
.node-group.neighbor .node-label {
  fill: #333;
  font-weight: bold;
  font-size: 9px;
}

.stats {
  font-size: 13px;
  color: #555;
  text-align: center;
}

.stats strong {
  color: #ff7f15;
  font-size: 15px;
}
.stats strong.red {
  color: #dc2626;
}

.formula {
  font-size: 11px;
  color: #999;
  margin-left: 4px;
}

.hint {
  font-size: 10px;
  color: #aaa;
  margin-left: 6px;
}

/* Dark/slidev overrides */
:deep(.dark) .hash-ring-widget {
  color: #eee;
}
</style>
