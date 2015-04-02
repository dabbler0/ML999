helper = require './helper.coffee'
schema = require './schema.coffee'
numeric = require 'numeric'
kdt = require 'kdt' # K-d tree

# NearestNeighborTrainer
# ======================
# "Trains" a nearest-neighbor model
exports.NearestNeighborTrainer = class NearestNeighborTrainer extends schema.Trainer
  constructor: (@k) ->
    @points = []

  feed: (point) ->
    @points.push point

  generate: ->
    return new NearestNeighborEstimator @k, @points

class NearestNeighborEstimator extends schema.Estimator
  constructor: (@k, @points) ->
    # Put things into a format that kd-js can use
    @points = @points.map (x) ->
      object = {}
      for el, i in x.input
        object[i] = el
      object.output = x.output
      object.length = x.input.length
      return object
    @points = kdt.createKdTree @points, ((a, b) -> helper.distance(a, b)), [0...@points[0].length]

  estimate: (input) ->
    nearest = @points.nearest input, @k
    avg = 0
    for el, i in nearest
      avg += el[0].output / @k
    return avg
