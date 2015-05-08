helper = require './helper.coffee'
schema = require './schema.coffee'
linreg = require './linreg.coffee'
numeric = require 'numeric'

# ForwardStagewiseRegressor
# ===============
# This linear regressor uses the method of normal equations with
# incremental update.
exports.ForwardStagewiseRegressor = class ForwardStagewiseRegressor extends schema.Trainer
  constructor: (@bases, @n) ->
    @bases.unshift -> 1

    @inputs = []
    @outputs = []

    @thetas = (0 for base in @bases)

  feed: ({input, output}) ->
    @inputs.push input
    @outputs.push output

  univariate: (base) ->
    inputs = @inputs.map(@bases[base])
    return numeric.dot(inputs, @outputs) / numeric.dot(inputs, inputs)

  residual: (base, coeff) ->
    numeric.sub(@outputs, numeric.dot(@inputs.map(@bases[base]), coeff))

  generate: ->
    # Center y
    @thetas[0] = helper.avg(@outputs)
    @outputs = @outputs.map (x) => x - @thetas[0]

    # Center x
    @baseAvg = (0 for base in @bases)
    for el in @inputs
      for base, i in @bases when i > 0
        @baseAvg[i] += base(el) / @inputs.length

    @bases = @bases.map (f, i) =>
      (x) => f(x) - @baseAvg[i]

    for j in [0...@n]
      # Find best-correlated variable
      best = null; min = Infinity

      for base, i in @bases
        coefficient = @univariate i
        residual = @residual i, coefficient
        rss = numeric.dot residual, residual
        if rss < min
          min = rss
          best = {
            coefficient, i, residual
          }

      # Update output vector and coefficient
      @thetas[best.i] += best.coefficient
      @outputs = best.residual

      # DEBUG LOGGING
      console.log '>> Finished iteration', j
      console.log 'MSE: ', numeric.dot(@outputs, @outputs) / @outputs.length
      console.log '-------------'
      for el, i in @thetas
        if el isnt 0
          console.log "  theta[#{i}] = #{el}"

    return new linreg.LinearRegressionEstimator @bases, @thetas
