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

function ms_solve(m::Int64, p::Vector{Int64}, lp::Bool)

	model = Model(solver = GLPKSolverMIP())

	if lp == true
		model = Model(solver = GLPKSolverLP())
	end

    n = length(p) # liczba zadań
	T = sum(p) + 1 # maksymalna liczba chwil

	Task = 1:n
    Machine = 1:m
	Horizon = 1:T

	# Zmienne decyzyjne

	# Cmax     - zmienna decyzyjna całkowitego czasu wykonania wszystkich zadań

	# x[j,k,t] - zmienne decyzyjne czasu rozpoczęcia zadań
	# x[j,k,t] = 1 oznacza, że zadanie j wykonuje się na maszynie k oraz rozpoczyna się w chwili t - 1

	if lp == true
		@variable(model, Cmax >= 0)
    	@variable(model, 1 >= x[Task, Machine, Horizon] >= 0)
	else
		@variable(model, Cmax >= 0, Int)
    	@variable(model, x[Task, Machine, Horizon], Bin)
	end

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

#=
	Wartość funkcji celu
=#

function ms_val(m::Int64, p::Vector{Int64}, lp::Bool)

	(status, fval, x) = ms_solve(m, pv, lp)
	return fval
end
