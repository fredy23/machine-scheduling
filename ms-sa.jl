#=
	Symulowane wyżarzanie dla problemu przydziału prac na równoległych maszynach
=#

# konwersja rozwiązania ze zbioru par (x - nr zadania, y - nr przydzielonej maszyny)
# na: sch[i] = zbiór par zadań (a - nr zadania, b - waga zadania) dla i-tej maszyny
function convert_schedule(m::Int64, ts::Array{Tuple{Int64, Int64}, 1})
	sch = Array[Tuple{Int64,Int64}[] for i in 1:m]	# sch[i] - lista zadań przydzielonych dla i-tej maszyny
	foreach(t -> push!(sch[t[2]], p[t[1]]), ts)
	
	return sch
end

# zwraca indeks najbardziej obciążonej maszyny i jej obciążenie (=cmax)
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

# generuje sąsiednie rozwiązanie dopuszczalne z otoczenia
function ms_neighbour(m::Int64, sch::Array{Array, 1})

	newsch = copy(sch)
	for i = 1:m
		newsch[i] = copy(sch[i])
	end
	
	# wybieramy losowo jeden z dwóch sposobów generowania sąsiadów
	roll = rand(1:2)
	
	if roll == 1
		ms_neighbour_reassign(m, newsch)
	else
		ms_neighbour_interchange(m, newsch)
	end
	
	return newsch

end

# przypisuje zadanie najbardziej obciążonej maszyny innej maszynie
function ms_neighbour_reassign(m::Int64, sch::Array{Array, 1})

	# najbardziej obciążona maszyna
	i, _ = max_load(m, sch)
	
	# losowo wybieramy zadanie
	numjobs = size(sch[i])[1]
	jobroll = rand(1:numjobs)
	jobind = sch[i][jobroll][1]
	
	# losowo wybieramy drugą maszynę...
	j = i
	while j == i
		j = rand(1:m)
	end
	
	# ...i przydzielamy jej to zadanie
	job = sch[i][jobroll]
	filter!(p -> p[1] != jobind, sch[i])
	push!(sch[j], job)

end

# zamienia przypisane zadania maszyny najbardziej obciążonej i innej maszyny
function ms_neighbour_interchange(m::Int64, sch::Array{Array, 1})

	# najbardziej obciążona maszyna
	i, _ = max_load(m, sch)
	
	# wybieramy losowa zadanie
	inumjobs = size(sch[i])[1]
	ijobroll = rand(1:inumjobs)
	ijobind = sch[i][ijobroll][1]
	
	# losowo wybieramy drugą maszynę...
	j = i
	while j == i && size(sch[j])[1] == 0	# musi mieć jakieś zadanie do wymiany
		j = rand(1:m)
	end
	
	# ...i jej zadanie
	jnumjobs = size(sch[j])[1]
	jjobroll = rand(1:jnumjobs)
	jjobind = sch[j][jjobroll][1]
	
	# wymiana zadaniami
	ijob = sch[i][ijobroll]
	jjob = sch[j][jjobroll]
	
	filter!(p -> p[1] != ijobind, sch[i])
	filter!(p -> p[1] != jjobind, sch[j])
	push!(sch[j], ijob)
	push!(sch[i], jjob)

end

# Algorytm symulowanego wyżarzania
function ms_sa_algo(m::Int64, s::Array{Array, 1})

	# trywialne dane (więcej maszyn niż zadań itp.)
	for i = 1:m
		if size(s[i])[1] == 0
			_, cmax = max_load(m, s)
			return s, cmax
		end
	end
	
	sch = copy(s)
	for i = 1:m
		sch[i] = copy(s[i])
	end
	
	numNeighbour = 25	# ile razy przeglądamy sąsiedztwo w jednej iteracji
	numIt = 500	# liczba iteracji algorytmu
	a = 0.98	# czynnik redukcji temperatury
	t = 10	# temperatura
	
	for i = 1:numIt
		for j = 1:numNeighbour
			# sprawdzanie sąsiedztwa
			newsch = ms_neighbour(m, sch)
			_, cmax = max_load(m, sch)
			_, newcmax = max_load(m, newsch)
			
			# sąsiad bliżej optimum - mamy lepsze rozwiązanie
			if newcmax < cmax
				sch = newsch
			else
				# nowe lokalne rozwiązanie nie polepsza funkcji celu,
				# ale z pewnym prawdopodobieństwem przyjmujemy je jako nowe rozwiązanie
				# - może wpłynąć pozytywnie na dłuższą metę (globalnie)
				d = newcmax - cmax
				p = exp(-d/t)	# prawdopodobieństwo z rozkładu Boltzmanna
				
				if rand() <= p
					sch = newsch
				end
			end
		end
		
		t = a * t	# redukcja temperatury
	end
	
	_, cmax = max_load(m, sch)
	_, oldcmax = max_load(m, s)
	
	if cmax < oldcmax
		return sch, cmax
	else
		return s, oldcmax
	end

end