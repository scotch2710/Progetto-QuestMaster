from unified_planning.shortcuts import *
from unified_planning.io import PDDLReader
import traceback

def check_pddl():
    """
    Verifica se un piano può essere generato dai file PDDL.
    Restituisce una tupla:
    - (True, stringa_del_piano) in caso di successo.
    - (False, messaggio_di_errore) in caso di fallimento.
    """
    try:
        reader = PDDLReader()
        problem = reader.parse_problem("domain.pddl", "problem.pddl")

        with OneshotPlanner(name='fast-downward') as planner:
            result = planner.solve(problem)

            if result.plan:
                # Costruisce una stringa leggibile per il piano
                plan_str = "--- Piano Trovato! ---\n"
                for i, action in enumerate(result.plan.actions):
                    plan_str += f"Passo {i+1}: {action}\n"
                plan_str += "----------------------"
                return True, plan_str # Successo
            else:
                # Nessun piano trovato, ma la sintassi è corretta
                return False, "Impossibile trovare un piano. La logica del dominio/problema potrebbe essere errata (es. obiettivo irraggiungibile)."

    except Exception as e:
        # Errore durante il parsing o la pianificazione (spesso per sintassi PDDL errata)
        print("\n--- ERRORE DURANTE LA VERIFICA DEL PDDL ---")
        print("L'errore verrà inviato a Gemini per la correzione.")
        # Formatta l'errore completo in una stringa per passarlo a Gemini
        error_details = traceback.format_exc()
        error_message = f"Il planner ha sollevato un'eccezione, il che indica un errore di sintassi o di coerenza nel PDDL.\n\nDETTAGLI DELL'ERRORE:\n{error_details}"
        return False, error_message