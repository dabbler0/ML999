exports.boxMuller = (mean, variance) ->
  swap = null
  return ->
    if swap?
      result = swap; swap = null
    else
      R = Math.sqrt -2 * Math.log Math.random()
      t = 2 * Math.PI * Math.random()

      result = R * Math.cos(t)
      swap = R * Math.sin(t)
    return result * variance + mean

exports.fillOpts = (opts, defaults) ->
  result = {}
  for key, val of defaults
    result[key] = opts[key] ? val
  return result
