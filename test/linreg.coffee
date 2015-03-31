schema = require '../src/schema.coffee'
linreg = require '../src/linreg.coffee'
helper = require './helper.coffee'
Canvas = require 'canvas'
fs = require 'fs'

TEST_DEFAULTS =
  dimensions: 1
  regressionBases: [((x) -> 1), ((x) -> x[0])]
  generationBases: [((x) -> 1), ((x) -> x[0])]
  n: 1000
  variance: 0

  trainLower: -1
  trainUpper: 1

  testLower: -1
  testUpper: 1

test = (opts) ->
  opts = helper.fillOpts opts, TEST_DEFAULTS
  {dimensions, regressionBases, generationBases, n,
  variance, trainLower, trainUpper, testLower, testUpper} = opts

  error = helper.boxMuller 0, variance
  trueThetas = (Math.random() * 2 - 1 for basis in generationBases)

  rawFunction = (input) ->
    sum = 0
    for basis, i in generationBases
      sum += trueThetas[i] * basis(input)
    return sum

  trueFunction = (input) -> rawFunction(input) + error()

  trainInputs = ((Math.random() * (trainUpper - trainLower) + trainLower for [0...dimensions]) for [0...n])
  trainCorpus = new schema.Corpus trainInputs.map (x) ->
    {
      input: x
      output: trueFunction(x)
    }

  testInputs = ((Math.random() * (testUpper - testLower) + testLower for [0...dimensions]) for [0...n])
  testCorpus = new schema.Corpus testInputs.map (x) ->
    {
      input: x
      output: trueFunction(x)
    }

  # Canvas plotting
  if dimensions is 1
    canvas = new Canvas 500, 500
    ctx = canvas.getContext '2d'

    maxOutput = Math.max.apply @, testCorpus.pairs.map (x) -> x.output
    minOutput = Math.min.apply @, testCorpus.pairs.map (x) -> x.output

    ctx.fillStyle = '#FFF'

    ctx.fillRect 0, 0, 500, 500

    ctx.fillStyle = '#000'

    for el, i in trainCorpus.pairs
      ctx.fillRect (el.input[0] - testLower) * 500 / (testUpper - testLower) - 1,
        500 - (el.output - minOutput) * 500 / (maxOutput - minOutput) - 1, 2, 2

  trainer = new linreg.LinearRegressor regressionBases
  trainCorpus.feedTo trainer

  estimator = trainer.generate()

  if dimensions is 1
    ###
    ctx.fillStyle = '#0F0'
    for el, i in testCorpus.pairs
      ctx.fillRect (el.input[0] - testLower) * 500 / (testUpper - testLower) - 1,
        500 - (el.output - minOutput) * 500 / (maxOutput - minOutput) - 1, 2, 2
    ###

    ctx.globalAlpha = 0.5

    ctx.beginPath()

    for x in [0..500]
      input = [testLower + x * (testUpper - testLower) / 500]
      y = 500 - (rawFunction(input) - minOutput) * 500 / (maxOutput - minOutput)

      if x is 0
        ctx.moveTo x, y
      else
        ctx.lineTo x, y

    ctx.strokeStyle = '#F00'
    ctx.lineWidth = 2
    ctx.stroke()


    ctx.beginPath()

    for x in [0..500]
      input = [testLower + x * (testUpper - testLower) / 500]
      y = 500 - (estimator.estimate(input) - minOutput) * 500 / (maxOutput - minOutput)

      if x is 0
        ctx.moveTo x, y
      else
        ctx.lineTo x, y

    ctx.strokeStyle = '#00F'
    ctx.lineWidth = 2
    ctx.stroke()

    fs.writeFile 'out.png', canvas.toBuffer()

  console.log 'True thetas:', trueThetas
  console.log 'Estimated thetas:', estimator.thetas
  console.log 'MSE:', testCorpus.meanSquaredError estimator

# First test: very complex function, should match exactly
test
  output: 'match.png'
  regressionBases: [
    (x) -> 1
    (x) -> x[0] / 10
    (x) -> x[0] ** 2 / 100
    (x) -> Math.sin x[0]
    (x) -> Math.sin x[0] * 2
    (x) -> Math.sin x[0] / 2
  ]

  generationBases: [
    (x) -> 1
    (x) -> x[0] / 10
    (x) -> x[0] ** 2 / 100
    (x) -> Math.sin x[0]
    (x) -> Math.sin x[0] * 2
    (x) -> Math.sin x[0] / 2
  ]
  n: 1000

  trainLower: -5
  trainUpper: 5

  testLower: -10
  testUpper: 10

  variance: 1
