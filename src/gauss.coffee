# Multiariate Gaussian Distribution
numeric = require 'numeric'

# p = (u, S) -> (x) -> Number
# n: Number; Dimensions in x
# u: Vector(n); Vector of means of elements of x
# S: Matrix(n, n); The covariance matrix of x
#
# x: Vector(n), the evaluated point
exports.gaussianDistribution = (n, u, S) ->
  det = numeric.det S
  return (x) ->
    Math.E ** (-(1/2) * numeric.dot(numeric.dot(numeric.sub(x, u), S), numeric.sub(x, u))) /
    ((2 * Math.PI) ** (n / 2) * det)
