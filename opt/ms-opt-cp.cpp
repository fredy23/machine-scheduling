#include <ilsolver/ilosolverint.h>
#include <fstream>
#include <vector>
#include <algorithm>

typedef IloArray<IloIntVarArray> IntMatrix;
typedef IloArray<IntMatrix> IntMatrix3;

ILOSTLBEGIN

int main(int argc, char **argv) {

    // Dane do problemu

    if(argc != 2) {
        std::cerr << "UŻYCIE: " << argv[0] << " [PLIK DANYCH]" << std::endl;
        return 1;
    }

    std::ifstream data_file(argv[1], std::ios_base::in);

    if(!data_file.is_open()) {
		std::cerr << argv[0] << ": błąd podczas otwierania pliku danych" << std::endl;
		return 1;
	}

    std::vector<int> tasks_times;

    int machines, tasks;
    int horizon = 1;

    data_file >> machines >> tasks;

    for(int i = 0; i < tasks; i++) {
        int t;
        data_file >> t;

        horizon += t;

        tasks_times.push_back(t);
    }

    data_file.close();

    // Model

    IloEnv env;

    try {

        // Zmienne modelu

        IloModel model(env);
        IloIntVar Cmax(env);
        IntMatrix X(env, machines);

        for(int i = 0; i < machines; i++) {

            X[i] = IloIntVarArray(env, tasks, 0, 1);
        }

        // Ograniczenia

        // Ograniczenia przydziału - zadanie może się wykowywać tylko na jednej maszynie
        for(int j = 0; j < tasks; j++) {

            IloExpr expr(env);

            for(int i = 0; i < machines; i++) {
                expr += X[i][j];
            }

            model.add(expr == 1);
        }

        // Ogranczenia całkowitego czasu wykonania wszystkich zadań
        for(int i = 0; i < machines; i++) {

            IloExpr expr(env);

            for(int j = 0; j < tasks; j++) {
                expr += tasks_times[j] * X[i][j];
            }

            model.add(Cmax >= expr);
        }

        // Funkcja celu

        IloObjective objective = IloMinimize(env, Cmax);
        model.add(objective);

        // Rozwiązanie modelu

        IloSolver solver(model);

        if(solver.solve()) {

            int cmax = solver.getValue(Cmax);
            solver.out() << cmax << std::endl;
        }
    }
    catch(IloException &e) {
        std::cout << "Błąd: " << e << std::endl;
    }

    env.end();

    return 0;
}
