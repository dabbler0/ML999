schema = require '../src/schema.coffee'
stagewise = require '../src/stagewise.coffee'
helper = require './helper.coffee'
Canvas = require 'canvas'
fs = require 'fs'

p = 10
N = 1000
L = 100
S = 1

thetas = ((Math.random() - 0.5) ** 3 for [0...p])
intercept = Math.random() - 0.5

error = helper.boxMuller 0, S
generateInput = -> (Math.random() - 0.5 for [0...p])
trueOutput = (input) -> numeric.dot(thetas, input) + intercept + error()

corpusArray = []

for [0...N]
  input = generateInput()
  output = trueOutput input
  corpusArray.push {input, output}

bases = for i in [0...p] then do (i) ->
  return (x) -> x[i]

regressor = new stagewise.ForwardStagewiseRegressor bases, L
corpus = new schema.Corpus corpusArray

corpus.feedTo regressor
regressor.generate()
console.log 'TRUE THETAS:'
console.log '------------'
console.log "  theta[0] = ?"
console.log thetas.map((x, i) -> "  theta[#{i + 1}] = #{x}").join '\n'
