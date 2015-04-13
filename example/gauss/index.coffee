STEPS = 25
MAX = 1
MIN = -1

WIDTH = HEIGHT = 600

f = stats.gauss.gaussianDistribution 2, [0, 0], [
  [10, 9]
  [9, 10]
]

maxVal = 0
for i in [0...25]
  for j in [0...25]
    maxVal = Math.max maxVal, f([i * (MAX - MIN) / STEPS + MIN, j * (MAX - MIN) / STEPS + MIN])

data =
  for i in [0...25]
    for j in [0...25]
      100 - 200 * f([i * (MAX - MIN) / STEPS + MIN, j * (MAX - MIN) / STEPS + MIN]) / maxVal

console.log data

svg = d3.select('#output')
        .append('svg')
        .attr('height', WIDTH)
        .attr('width', HEIGHT)

group = svg.append 'g'

md = group.data([data])
          .surface3D(WIDTH, HEIGHT)
          .surfaceHeight((d) -> d)
          .surfaceColor((d) ->
            c = d3.hsl((d+100), 0.6, 0.5).rgb()
            return "rgb(#{Math.round(c.r)},#{Math.round(c.g)},#{Math.round(c.b)})"
          )

yaw = 0.5; pitch = 0.5; drag = false
svg.on("mousedown", ->
  drag = [d3.mouse(@), yaw, pitch]
).on("mouseup", ->
  drag = false
).on("mousemove", ->
  if drag
    mouse = d3.mouse @
    yaw = drag[1] - (mouse[0] - drag[0][0]) / 50
    pitch = drag[2]+(mouse[1] - drag[0][1]) / 50
    pitch = Math.max(-Math.PI/2, Math.min(Math.PI/2,pitch))
    md.turntable(yaw, pitch)
)
