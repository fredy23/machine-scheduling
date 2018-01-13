#=
    Funkcje algorytmów szeregowania zadań
=#

# Algorymt listowy
function ms_list_algo(m::Int64, p::Array{Tuple{Int64, Int64}})

    mload = zeros(Int64, m) # obciążenie maszyn
    ts = Array[Tuple{Int64, Int64}[] for i in 1:m] # przydział zadań do maszyn

    for v in p
        i = indmin(mload) # indeks najmniej obciążonej maszyny
        mload[i] += v[2]
        push!(ts[i], (v[1], v[2]))
    end

    cmax = maximum(mload)

    return ts, cmax
end

# Algorymt LPT
function ms_lpt_algo(m::Int64, p::Array{Tuple{Int64, Int64}})

    pc = copy(p)
    sort!(pc, by = x -> x[2], rev = true) # sortowanie malejąco po czasie wykonania

    ts, cmax = ms_list_algo(m, pc)

    return ts, cmax
end

# Funkcja zwracająca indeks najbardziej obciążonej maszyny i jej obciążenie (=cmax)
function max_load(m::Int64, sch::Array{Array, 1})

	ind = 0
	load = 0

	for i = 1:m
		l = 0
		for t in sch[i]
			l = l + t[2]
		end
		if l > load
			load = l
			ind = i
		end
	end

	return ind, load

end
