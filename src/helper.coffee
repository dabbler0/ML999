exports.mapmap = (map, f) ->
  result = {}
  for key, val of map
    result[key] = f val
  return result

exports.sum = (map) ->
  sum = 0
  for key, val of map
    sum += val
  return sum

exports.max = (map) ->
  max = -Infinity
  for key, val of map
    if val > max
      max = val
  return max

exports.argmax = (map) ->
  max = -Infinity; best = null
  for key, val of map
    if val > max
      max = val
      best = key
  return best

exports.normalize = (map) ->
  sum = exports.sum map
  return exports.mapmap map, (x) -> x / sum

exports.normalizeLog = (map) ->
  max = exports.max(map)
  scaled = exports.mapmap map, (x) -> x - max
  power = exports.mapmap scaled, (x) -> Math.E ** x

  normalized = exports.normalize(power)
  return exports.mapmap normalized, (x) -> Math.log x
