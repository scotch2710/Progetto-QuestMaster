from unified_planning.shortcuts import *
from unified_planning.io import PDDLReader


# Assicurati che i percorsi ai file siano corretti


def check_pddl():
    reader = PDDLReader()
    problem = reader.parse_problem("domain.pddl", "problem.pddl")

    with OneshotPlanner(name='fast-downward-opt') as planner: # Usa 'fast-downward-opt' per piani ottimali
        result = planner.solve(problem)

        if result.plan:
            print("--- Piano Trovato! ---")
        # Itera su ogni azione nel piano e stampala
            for i, action in enumerate(result.plan.actions):
                print(f"Passo {i+1}: {action}")
            print("----------------------")
        else:
            print("Impossibile trovare un piano.")
        
check_pddl()