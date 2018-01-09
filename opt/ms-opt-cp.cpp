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
        IntMatrix3 X(env, tasks);

        for(int j = 0; j < tasks; j++) {

            X[j] = IntMatrix(env, machines);

            for(int k = 0; k < machines; k++) {
                X[j][k] = IloIntVarArray(env, horizon, 0, 1);
            }
        }

        // Ograniczenia

        // Ograniczenia na czas rozpoczęcia - każde zadanie może się rozpocząć tylko raz
        for(int j = 0; j < tasks; j++) {

            IloExpr expr(env);

            for(int k = 0; k < machines; k++) {
                expr += IloSum(X[j][k]);
            }

            model.add(expr == 1);
        }

        // Ograniczenia na niekolidujące wykonanie na maszynach
        for(int k = 0; k < machines; k++) {
            for(int t = 0; t < horizon; t++) {

                IloExpr expr(env);

                for(int j = 0; j < tasks; j++) {
                    int m = std::max(0, t - tasks_times[j]);

                    for(int s = m; s < t; s++)
                        expr += X[j][k][s];
                }

                model.add(expr <= 1);
            }
        }

        // Ogranczenia całkowitego czasu wykonania wszystkich zadań
        for(int j = 0; j < tasks; j++) {
            for(int k = 0; k < machines; k++) {

                IloExpr expr(env);

                for(int t = 0; t < horizon; t++) {
                    expr += ((t + tasks_times[j]) * X[j][k][t]);
                }

                model.add(Cmax >= expr);
            }
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
