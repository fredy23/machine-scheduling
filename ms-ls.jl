#=
    Local search dla problemu przydziału prac na równoległych maszynach
=#

# Funkcja przypisująca j-te zadanie z maszyny k maszynie l
function ms_neighbour_reassign(k::Int64, l::Int64, j::Int64, sch::Array{Array, 1})

    new_sch = copy(sch)

    for i = 1:m
        new_sch[i] = copy(sch[i])
    end

    jk = new_sch[k][j]
    jk_ind = jk[1]
    filter!(p -> p[1] != jk_ind, new_sch[k])
    push!(new_sch[l], jk)

    return new_sch
end

# Funkcja wymieniająca j-te zadanie z maszyny k i h-te zadanie z maszyny l
function ms_neighbour_interchange(k::Int64, l::Int64, j::Int64, h::Int64, sch::Array{Array, 1})

    new_sch = copy(sch)

    for i = 1:m
        new_sch[i] = copy(sch[i])
    end

    jk = new_sch[k][j]
    jk_ind = jk[1]

	jl = new_sch[l][h]
    jl_ind = jl[1]

	filter!(p -> p[1] != jk_ind, new_sch[k])
	filter!(p -> p[1] != jl_ind, new_sch[l])

	push!(new_sch[k], jl)
	push!(new_sch[l], jk)

    return new_sch
end

# Algorytm local search
function ms_ls_algo(m::Int64, s::Array{Array, 1})

    sch = copy(s)

	for i = 1:m
		sch[i] = copy(s[i])
	end

    local_opt = false
    min_sch = nothing

    while local_opt == false

        i, cmax = max_load(m, sch) # indeks i obciążenie najbardziej obciążonej maszyny
        l = length(sch[i]) # liczba zadań na maszynie i

        min_cmax = Inf

        # pełny przegląd sąsiedztwa - szukamy najlepszego sąsiada

        for j = 1:l, k = 1:m

            if k != i

                # sąsiedztwo przez przemieszczenie zadania

                new_sch = ms_neighbour_reassign(i, k, j, sch)
                _, new_cmax = max_load(m, new_sch)

                # sprawdzamy, czy aktualny sąsiad jest najlepszym znalezionym do tej pory
                if new_cmax < min_cmax
                    min_cmax = new_cmax
                    min_sch = new_sch
                end

                # sąsiedztwo przez wymianę zadań

                lk = length(sch[k]) # liczba zadań na maszynie k

                for h = 1:lk

                    new_sch = ms_neighbour_interchange(i, k, j, h, sch)
                    _, new_cmax = max_load(m, new_sch)

                    # sprawdzamy, czy aktualny sąsiad jest najlepszym znalezionym do tej pory
                    if new_cmax < min_cmax
                        min_cmax = new_cmax
                        min_sch = new_sch
                    end
                end
            end
        end

        if min_cmax < cmax # znaleźliśmy lepsze rozwiązanie
            sch = min_sch
        else               # nie znaleźliśmy nic lepszego
            local_opt = true
        end
    end

    _, cmax = max_load(m, sch)

    return sch, cmax
end
