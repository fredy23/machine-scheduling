#=
	Przeszukiwanie algorytmem tabu search
=#

# kryterium aspiracji
function ms_tabu_aspiration(m::Int64, sch::Array{Array, 1}, newsch::Array{Array, 1})

	_, cmax1 = max_load(m, sch)
	_, cmax2 = max_load(m, newsch)
	
	return cmax1 > cmax2

end

# zwraca:	- rozwiązanie dopuszczalne z sąsiedztwa zgodnie ze strategią Aspiration Plus,
# 			- atrybut opisujący ruch do listy tabu
function ms_aspiration_plus(m::Int64, sch::Array{Array, 1}, tabu::Dict)

	minNeighbours = 200	# minimalna liczba sąsiadów do zbadania
	maxNeighbours = 100	# maksymalna liczba sąsiadów do zbadania
	numNeighbours = 0	# ilu sąsiadów sprawdzono
	plus = 50	# po znalezieniu lepszego rozwiązania przeszukujemy 
				# jeszcze plus sąsiadów, ale w sumie nie więcej niż maxNeighbours
				# oraz co najmniej minNeighbours
	atr = 0	# atrybut ruchu dla listy tabu
	cmax = typemax(Int) # wart f celu
	found = false	# czy już znaleziono lepsze rozwiązanie
	result = sch
	
	# najbardziej obciążona maszyna
	ind, load = max_load(m, sch)
	numjobs1 = size(sch[ind])[1]
	
	for i = 1:m
		if numNeighbours >= maxNeighbours
			break
		end
		
		if ind == i
			continue
		end
		
		numjobs2 = size(sch[i])[1]
		
		for j = 1:numjobs1
			if numNeighbours >= maxNeighbours
					break
			end
			
			for k = 1:numjobs2
				if numNeighbours >= maxNeighbours
					break
				end
				
				# wymiana zadań między maszynami
				job1 = sch[ind][j]
				jobind1 = sch[ind][j][1]
				job2 = sch[i][k]
				jobind2 = sch[i][k][1]
				
				newsch = copy(sch)
				for x = 1:m
					newsch[x] = copy(sch[x])
				end
				
				a = (ind, i, jobind1, jobind2)
				
				filter!(p -> p[1] != jobind1, newsch[ind])
				filter!(p -> p[1] != jobind2, newsch[i])
				push!(newsch[i], job1)
				push!(newsch[ind], job2)
				
				# jeśli nie figuruje w liście tabu lub spełnia kryterium aspiracji
				if !haskey(tabu, a) || ms_tabu_aspiration(m, sch, newsch)
					numNeighbours = numNeighbours + 1
					_, l = max_load(m, newsch)
					
					# najlepsze rozwiązanie z sąsiedztwa
					if l < cmax
						atr = a
						result = newsch
						cmax = l
						
						# sprawdzamy jeszcze maksymalnie plus sąsiadów
						if !found
							found = true
							max = numNeighbours + plus
							
							if max < minNeighbours
								max = minNeighbours
							elseif max > maxNeighbours
								max = maxNeighbours
							end
							
							maxNeighbours = max
						end
					end
				end
			end
		end
	end
	
	return result, atr

end

# przeszukiwanie tabu search
function ms_tabu_algo(m::Int64, s::Array{Array, 1})

	_, cmax = max_load(m, s)
	
	# trywialne dane (więcej maszyn niż zadań itp.)
	for i = 1:m
		if size(s[i])[1] == 0
			return s, cmax
		end
	end
	
	sch = copy(s)
	for i = 1:m
		sch[i] = copy(s[i])
	end
	
	maxIt = 500	# maksymalna liczba iteracji
	
	tabu = Dict()
	result = 0
	C = 50	# maksymalna kadencja dla atrybutu w liście tabu
	
	newsch = sch
	
	for i = 1:maxIt
		newsch, atr = ms_aspiration_plus(m, newsch, tabu)	# rozpatrywanie rozwiązania z sąsiedztwa
		
		# jeśli mamy sąsiada
		if atr != 0
			_, load = max_load(m, newsch)
			
			if load < cmax
				cmax = load
				result = newsch
			end
			
			# zakazujemy na pewien czas ostatnio wykonanego ruchu
			tabu[atr] = C
		end
		
		# aktualizacja kadencji
		foreach(e -> tabu[e[1]] = e[2] - 1, tabu)
		# wyjęcie z listy tabu atrybutów, którym skończyła się kadencja
		foreach(e -> if e[2] == 0 delete!(tabu, e[1]) end, tabu)
	end
	
	return result, cmax

end
