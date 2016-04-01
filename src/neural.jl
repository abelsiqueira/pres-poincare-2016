# The traditional linear regression with affine model
# y ≈ αx + β
function linreg(x, y)
  A = [ones(x) x]
  α, β = A\y
  return α, β
end

sig(x) = 1./(1+exp(-x))
sigd(x) = sig(x).*(1-sig(x))
normalize(x) = (x - minimum(x))/(maximum(x)-minimum(x))

function neural(xx, yy; nh = 3, f=x->sig(x), fd=x->sig(x).*(1-sig(x)))
  x = normalize(xx)
  y = normalize(yy)
  n = length(x)

  W1 = rand(nh,1)
  W2 = rand(1,nh)


  F(W1,W2) = 0.5*vecnorm(y - f(W2*f(W1*x)))^2
  J(W1,W2) = begin
    a = f(W1*x)
    z = W2*a
    δ = -(y-f(z)) .* fd(z)
    dW2 = -δ*a'
    dW1 = W2'*δ.*fd(W1*x)*x'
    return dW1, dW2
  end

  k = 0
  d1, d2 = J(W1,W2)
  nJ = vecnorm(d1)^2 + vecnorm(d2)^2
  while nJ > 1e-4
    t = 1.0
    while F(W1-t*d1,W2-t*d2) > F(W1,W2) - 0.1*t*nJ
      t *= 0.9
      if t < 0.1
        break
      end
    end
    W1 += t*d1
    W2 += t*d2
    d1,d2 = J(W1,W2)
    nJ = vecnorm(d1)^2 + vecnorm(d2)^2
    k += 1
    if k > 100000
      break
    end
  end
  my = minimum(yy)
  dy = maximum(yy)-my
  mx = minimum(xx)
  dx = maximum(xx)-mx
  model(xx) = begin
    f(W2*f(W1*(xx-mx)/dx))[1]*dy + my
  end
  return model, W1, W2
end
