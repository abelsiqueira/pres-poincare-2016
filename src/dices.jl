dice(n) = rand(1:n)
function dice(number, sides)
  return sum([dice(sides) for n = 1:number])
end

"Estimate the expected value rolling N times"
function dice_est(number, sides; N = 100000)
  s = 0
  for i = 1:N
    s += dice(number, sides)
  end
  s = round(s/N, 2)
  return s
end

function profit_basic(machines::Array{Tuple{Int,Int},1}, rolls)
  K = length(machines)
  if K > rolls
    error("Not enough rolls to have fun")
  end
  profit = 0
  mach(i) = begin (n,s) = machines[i]; return dice(n,s) end
  mach_hist = [ [] for i = 1:K ]
  hist = []
  μ = Inf*ones(K)
  # Initial roll
  for N = 1:rolls
    i = indmax(μ)
    x = mach(i)
    profit += x
    push!(mach_hist[i], x)
    μ[i] = mean(mach_hist[i])
    push!(hist, (i,x))
  end
  return profit, hist, mach_hist, μ
end

function profit_ucb(machines::Array{Tuple{Int,Int},1}, rolls)
  K = length(machines)
  if K > rolls
    error("Not enough rolls to have fun")
  end
  profit = 0
  mach(i) = begin (n,s) = machines[i]; return dice(n,s) end
  mach_hist = [ [] for i = 1:K ]
  hist = []
  μ = Inf*ones(K)
  B = Inf*ones(K)
  # Initial roll
  for N = 1:rolls
    i = indmax(B)
    x = mach(i)
    profit += x
    push!(mach_hist[i], x)
    μ[i] = mean(mach_hist[i])
    B = μ + sqrt(2*log(N)./log(length(mach_hist)))
    push!(hist, (i,x))
  end
  return profit, hist, mach_hist, μ
end

rolls = 10000
machines = [(100,6); (50,12); (30,20)]
profit, hist, mach_hist, μ = profit_basic(machines, rolls)
profitucb, histucb, machhistucb, μucb = profit_ucb(machines, rolls)

println("P = $profit")
println("PUCB = $profitucb")

println("NdS   E   μ   μUCB")
for (i,(n,s)) in enumerate(machines)
  println("$(n)d$s $(dice_est(n,s)) $(round(μ[i],2)) $(round(μucb[i],2))")
end
