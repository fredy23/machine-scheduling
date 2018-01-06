using JuMP
using GLPKMathProgInterface
using Cbc

#=
	Funkcja rozwiązująca model programowania całkowitoliczbowego
	dla problemu szeregowania zadań

	Dane wejściowe:
        m - liczba maszyn
        p - wektor czasów wykonania zadań

	Zwracane wartości:
		  - status
		  - wartość funkcji celu
		  - wartości zmiennych decyzyjnych x
=#

function ms_mip(m::Int64, p::Vector{Int64})

	model = Model(solver = GLPKSolverMIP())
	#model = Model(solver = CbcSolver())

    n = length(p) # liczba zadań
	T = sum(p) + 1 # maksymalna liczba chwil

	Task = 1:n
    Machine = 1:m
	Horizon = 1:T

	# zmienna decyzyjna całkowitego czasu wykonania wszystkich zadań
	@variable(model, Cmax >= 0, Int)

    # zmienne decyzyjne czasu rozpoczęcia zadań
    @variable(model, x[Task, Machine, Horizon], Bin) # x[j,k,t] = 1 oznacza, że zadanie j wykonuje się na maszynie k
												     # oraz rozpoczyna się w chwili t - 1
	# Funkcja celu
	@objective(model, Min, Cmax)

	# Ograniczenia na czas rozpoczęcia - każde zadanie może się rozpocząć tylko raz
	for j in Task
		@constraint(model, sum(x[j, k, t] for k in Machine, t in Horizon) == 1)
	end

	# Ograniczenia na niekolidujące wykonanie na maszynach
	for k in Machine, t in Horizon
		@constraint(model, sum(sum(x[j, k, s] for s = max(1, t - p[j] + 1):t) for j in Task) <= 1)
	end

	# Ogranczenia całkowitego czasu wykonania wszystkich zadań
	for j in Task, k in Machine
		@constraint(model, Cmax >= sum((t - 1 + p[j]) * x[j, k, t] for t in Horizon))
	end

	# Rozwiązanie modelu
	status = solve(model, suppress_warnings=true)

	if status == :Optimal
		return status, getobjectivevalue(model), getvalue(x)
	else
		return status, nothing, nothing
	end

end
