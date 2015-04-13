schema = require './schema.coffee'
numeric = require 'numeric'

# LinearRegressor
# ===============
# This linear regressor uses the method of normal equations with
# incremental update.
exports.LinearRegressor = class LinearRegressor extends schema.Trainer
  constructor: (@bases, @lambda = 0) ->
    @left = for i in [0...@bases.length] then for j in [0...@bases.length]
      if i is j and i isnt 0 then @lambda
      else 0
    @right = ([0] for [0...@bases.length])

  feed: ({input, output}) ->
    basisTransformed = @bases.map (basis) -> basis(input)
    for a, i in basisTransformed
      for b, j in basisTransformed
        @left[i][j] += a * b

    for a, i in basisTransformed
      @right[i][0] += output * a

  generate: ->
    thetas = numeric.solve @left, @right
    return new LinearRegressorEstimator @bases, thetas

class LinearRegressorEstimator extends schema.Estimator
  constructor: (@bases, @thetas) ->
  estimate: (input) ->
    basisTransformed = @bases.map (basis) -> basis(input)
    return numeric.dot(basisTransformed, @thetas)
