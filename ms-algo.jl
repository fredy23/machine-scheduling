#=
    Funkcje algorytmów szeregowania zadań
=#

# Algorymt listowy
function ms_list_algo(m::Int64, p::Array{Tuple{Int64, Int64}})

    mload = zeros(Int64, m) # obciążenie maszyn
    ts = Tuple{Int64, Int64}[] # przydział zadań do maszyn

    for v in p
        i = indmin(mload) # indeks najmniej obciążonej maszyny
        mload[i] += v[2]
        push!(ts, (v[1], i))
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
