canvas = document.getElementById 'output'
ctx = canvas.getContext '2d'

render = ->
  Math.seedrandom $('#random-seed').val()

  generating = {
    poly: Number $('#gen-poly').val()
    fourier: Number $('#gen-fourier').val()
    variance: Number $('#gen-variance').val()
    size: Number $('#gen-size').val()
  }

  linreg = {
    poly: Number $('#linreg-poly').val()
    fourier: Number $('#linreg-fourier').val()
    lambda: Number $('#linreg-lambda').val()
  }

  knn = {
    k: Number $("#nn-k").val()
  }

  # Create generating function
  generatingBases = stats.test.polyBases(1, generating.poly).concat(
    stats.test.fourierBases(1, generating.fourier)
  )

  thetas = stats.test.thetas(generatingBases.length, 1)

  gen = stats.test.generatingFunction(generatingBases, thetas, generating.variance)

  ctx.clearRect 0, 0, canvas.width, canvas.height

  # Determine appropriate range
  outMax = Math.max.apply @, [0...canvas.width].map (x) -> gen.raw([x * 2 / canvas.width - 1])
  outMin = Math.min.apply @, [0...canvas.width].map (x) -> gen.raw([x * 2 / canvas.width - 1])

  outMax += generating.variance
  outMin -= generating.variance

  points = []

  # Collect training data
  for [0...generating.size]
    x = Math.random() * canvas.width
    i = x * 2 / canvas.width - 1
    j = gen.noisy([i])

    points.push {
      input: [i]
      output: j
    }

    y = canvas.height * (1 - (j - outMin) / (outMax - outMin))

    ctx.fillRect x - 1, y - 1, 2, 2

  # General abstraction for plotting a function
  # on the canvas
  plotFun = (c, f) ->
    ctx.beginPath()
    ctx.strokeStyle = c

    for x in [0...canvas.width]
      i = x * 2 / canvas.width - 1
      j = f([i])
      y = canvas.height * (1 - (j - outMin) / (outMax - outMin))

      if x is 0
        ctx.moveTo x, y
      else
        ctx.lineTo x, y

    ctx.stroke()

  trainingCorpus = new stats.schema.Corpus points

  # Create linreg bases
  linregBases = stats.test.polyBases(1, linreg.poly).concat(
    stats.test.fourierBases(1, linreg.fourier)
  )

  # Collect testing data
  testPoints = []

  for [0...generating.size]
    i = Math.random() * 2 / canvas.width - 1
    j = gen.noisy([i])

    testPoints.push {
      input: [i]
      output: j
    }

  testCorpus = new stats.schema.Corpus testPoints

  if ($("#linreg-check")[0].checked)
    linRegressor = new stats.linreg.LinearRegressor linregBases, linreg.lambda
    trainingCorpus.feedTo linRegressor
    linEstimator = linRegressor.generate()
    plotFun '#00F', (x) -> linEstimator.estimate(x)
    $('#out-linreg').text testCorpus.meanSquaredError linEstimator

  if ($("#nn-check")[0].checked)
    neighborTrainer = new stats.nn.NearestNeighborTrainer knn.k
    trainingCorpus.feedTo neighborTrainer
    neighborEstimator = neighborTrainer.generate()
    plotFun '#0F0', (x) -> neighborEstimator.estimate(x)
    $('#out-nn').text testCorpus.meanSquaredError neighborEstimator

  plotFun '#F00', (x) -> gen.raw(x)

$('#go').on 'click', render
$('.config').on 'input change', ->
  if $('#auto')[0].checked
    render()
render()
