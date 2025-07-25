from unified_planning.shortcuts import *
from unified_planning.io import PDDLReader
import traceback

def check_pddl():
    """
    Verifica se un piano può essere generato dai file PDDL.
    Restituisce True se un piano viene trovato, False altrimenti.
    """
    try:
        reader = PDDLReader()
        problem = reader.parse_problem("domain.pddl", "problem.pddl")

        # Usiamo un planner oneshot per trovare una soluzione
        with OneshotPlanner(name='fast-downward') as planner:
            result = planner.solve(problem)

            if result.plan:
                print("--- Piano Trovato! ---")
                # Itera su ogni azione nel piano e stampala
                for i, action in enumerate(result.plan.actions):
                    print(f"Passo {i+1}: {action}")
                print("----------------------")
                return True # Successo
            else:
                print("Impossibile trovare un piano con la configurazione attuale.")
                return False # Fallimento

    except Exception as e:
        print("\n--- ERRORE DURANTE LA VERIFICA DEL PDDL ---")
        print("Si è verificato un errore che ha impedito la verifica del piano.")
        print("Questo di solito indica un problema di sintassi o logico grave nei file PDDL.")
        # Stampa i dettagli dell'errore per il debug
        traceback.print_exc()
        print("-----------------------------------------")
        return False # Fallimento a causa di errore