numeric = require 'numeric'

exports.boxMuller = (mean, variance) ->
  swap = null
  return ->
    if swap?
      result = swap; swap = null
    else
      R = Math.sqrt -2 * Math.log Math.random()
      t = 2 * Math.PI * Math.random()

      result = R * Math.cos t
      swap = R * Math.sin t

    return result * variance + mean

# p is maximum power
# n is number of dimensions
exports.polyBases = (n = 1, p = 1) ->
  if p is 0
    return [-> 1]
  else if n is 0
    return [-> 1]
  else
    return exports.polyBases(n, p - 1).map((f) -> ((x) -> f(x) * x[n - 1])).concat exports.polyBases(n - 1, p)

# p is maximum frequency
# n is number of dimensions
exports.fourierBases = (n = 1, p = 1) ->
  bases = []
  if p is 0 then return bases
  for k in [1..p]
    for i in [0...n] then do (k, i) ->
      bases.push (x) -> Math.sin x[i] * 2 * Math.PI * k
  return bases

exports.thetas = (n = 1, p = 1) -> ((Math.random() * 2 - 1) * p for [0...n])

exports.generatingFunction = (bases, thetas, variance) ->
  error = exports.boxMuller 0, variance
  raw = (x) -> numeric.dot(thetas, bases.map((basis) -> basis(x)))
  noisy = (x) ->
    raw(x) + error()
  return {raw, noisy}
