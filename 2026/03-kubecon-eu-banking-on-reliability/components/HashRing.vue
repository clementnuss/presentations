<script setup>
import { ref, computed, watch } from 'vue'

const nodeCount = ref(15)
const neighborCount = ref(5)
const selectedNode = ref(null)
const showAllToAll = ref(false)
const hashOrder = ref(true)

// FNV-1a hash
function fnv1a(str) {
  let hash = 2166136261
  for (let i = 0; i < str.length; i++) {
    hash ^= str.charCodeAt(i)
    hash = (hash * 16777619) >>> 0
  }
  return hash
}

const CX = 170
const CY = 170
const R = 140

// Color palette for node IDs — gives each original index a stable hue
function nodeColor(originalIndex, total) {
  const hue = (originalIndex / total) * 360
  return `hsl(${hue}, 70%, 55%)`
}

const nodes = computed(() => {
  const arr = []
  for (let i = 0; i < nodeCount.value; i++) {
    const name = `node-${String(i + 1).padStart(2, '0')}`
    const hash = fnv1a(name)
    arr.push({ name, hash, originalIndex: i })
  }
  // Always sort by hash to assign stable ringIndex
  arr.sort((a, b) => a.hash - b.hash)
  const withRingIndex = arr.map((n, i) => ({ ...n, ringIndex: i }))

  return withRingIndex.map((n) => {
    // Position on ring: by hash order or by original sequential order
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
  if (showAllToAll.value || selectedNode.value === null) return []
  const sel = nodes.value[selectedNode.value]
  if (!sel) return []
  const indices = getNeighborIndices(selectedNode.value)
  return indices.map(i => ({ from: sel, to: nodes.value[i] }))
})

const neighborArc = computed(() => {
  if (showAllToAll.value || !hashOrder.value || selectedNode.value === null) return ''
  const indices = getNeighborIndices(selectedNode.value)
  if (indices.length === 0) return ''
  const lastIdx = indices[indices.length - 1]
  const startAngle = nodes.value[selectedNode.value].angle
  const endAngle = nodes.value[lastIdx].angle
  let sweep = endAngle - startAngle
  if (sweep <= 0) sweep += 2 * Math.PI
  const largeArc = sweep > Math.PI ? 1 : 0
  const arcR = R + 12
  const x1 = CX + arcR * Math.cos(startAngle)
  const y1 = CY + arcR * Math.sin(startAngle)
  const x2 = CX + arcR * Math.cos(endAngle)
  const y2 = CY + arcR * Math.sin(endAngle)
  return `M ${x1} ${y1} A ${arcR} ${arcR} 0 ${largeArc} 1 ${x2} ${y2}`
})

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

// Reset selection when toggling mode
watch(showAllToAll, () => {
  selectedNode.value = null
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
      <button
        :class="['toggle-btn', { active: showAllToAll }]"
        @click="showAllToAll = !showAllToAll"
      >
        {{ showAllToAll ? 'O(n²) all-to-all' : 'O(n) hash ring' }}
      </button>
    </div>

    <!-- SVG visualization -->
    <svg viewBox="0 0 340 340" class="ring-svg">
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

      <!-- Neighbor arc -->
      <path
        v-if="neighborArc"
        :d="neighborArc"
        class="neighbor-arc"
      />

      <!-- Neighbor connections -->
      <line
        v-for="(c, i) in neighborConnections"
        :key="'nb-' + i"
        :x1="c.from.x" :y1="c.from.y"
        :x2="c.to.x" :y2="c.to.y"
        class="connection-neighbor"
        style="transition: x1 0.6s ease, y1 0.6s ease, x2 0.6s ease, y2 0.6s ease"
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

.neighbor-arc {
  fill: none;
  stroke: #ff7f15;
  stroke-width: 3;
  opacity: 0.5;
  stroke-linecap: round;
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
