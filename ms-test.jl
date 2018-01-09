#=
    Program testujący działanie
    algorytmów szeregowania zadań
=#

# Funkcja wczytująca dane problemu

function read_data(file_handler)

    line = chomp(readline(file_handler))
    data = split(line, " ")

    # Liczba maszyn i zadań
    m = parse(Int64, data[1])
    t = parse(Int64, data[2])

    # Czasy wykonania zadań
    p = Tuple{Int64, Int64}[]

    for i = 1:t
        line = chomp(readline(file_handler))
        time = parse(Int64, line)
        push!(p, (i, time))
    end

    return m, p
end

# Wczytywanie danych

if length(ARGS) != 1
    println("Użycie: ", PROGRAM_FILE, " [PLIK DANYCH]")
    quit()
end

data_file = ARGS[1]

m = 0
p = Tuple{Int64, Int64}[]

try
    file_handler = open(data_file)
    m, p = read_data(file_handler)
catch
    println(PROGRAM_FILE, ": błąd podczas otwierania pliku danych")
    quit()
end

# Rozwiązanie problemu

include("opt/ms-opt.jl")
include("ms-algo.jl")

# Algorytm listowy

ts, cmax = ms_list_algo(m, p)
println("Algorytm listowy: ", cmax)

# Algorytm LPT

ts, cmax = ms_lpt_algo(m, p)
println("Algorytm LPT: ", cmax)

# Optimum

pv = map(v -> v[2], p)

cmax = ms_val(m, pv, false)
println("OPT: ", cmax)

# Optimum LB
cmax = ms_val(m, pv, true)
println("OPT LB: ", cmax)
