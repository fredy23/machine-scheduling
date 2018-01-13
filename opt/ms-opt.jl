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

	Task = 1:n
    Machine = 1:m

	# Zmienne decyzyjne

	# Cmax     - zmienna decyzyjna całkowitego czasu wykonania wszystkich zadań

	# x[i,j] - zmienne decyzyjne przydziału zadań
	# x[i,j] = 1 oznacza, że zadanie j wykonuje się na maszynie i

	if lp == true
		@variable(model, Cmax >= 0)
    	@variable(model, 1 >= x[Machine, Task] >= 0)
	else
		@variable(model, Cmax >= 0, Int)
    	@variable(model, x[Machine, Task], Bin)
	end

	# Funkcja celu
	@objective(model, Min, Cmax)

	# Ograniczenia przydziału - zadanie może się wykowywać tylko na jednej maszynie
	for j in Task
		@constraint(model, sum(x[i, j] for i in Machine) == 1)
	end

	# Ogranczenia całkowitego czasu wykonania wszystkich zadań
	for i in Machine
		@constraint(model, Cmax >= sum(p[j] * x[i, j] for j in Task))
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
