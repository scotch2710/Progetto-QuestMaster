from unified_planning.shortcuts import *
from unified_planning.io import PDDLReader
import traceback # Importiamo questo modulo per ottenere dettagli sull'errore

def check_pddl():
    """
    Verifica i file PDDL e restituisce lo stato del piano.

    Returns:
        tuple: Una tupla (status, message) dove:
               - status è "success" se il piano è stato trovato,
               - status è "no_plan" se nessun piano è stato trovato (ma la sintassi è valida),
               - status è "error" se si è verificato un errore di sintassi/validazione.
               - message contiene il piano o il messaggio di errore dettagliato.
    """
    try:
        reader = PDDLReader()
        problem = reader.parse_problem("domain.pddl", "problem.pddl")

        # Usiamo un planner oneshot
        with OneshotPlanner(name='fast-downward') as planner:
            result = planner.solve(problem)

            if result.plan:
                plan_str = "--- Piano Trovato! ---\n"
                for i, action in enumerate(result.plan.actions):
                    plan_str += f"Passo {i+1}: {action}\n"
                plan_str += "----------------------"
                return ("success", plan_str)
            else:
                # La sintassi PDDL è corretta, ma non esiste una soluzione logica.
                return ("no_plan", "Impossibile trovare un piano. La logica del problema potrebbe essere errata.")

    except Exception as e:
        # Si è verificato un errore, probabilmente di sintassi nel PDDL.
        print("\nERRORE: Il planner PDDL ha sollevato un'eccezione.")
        # Formattiamo l'intero traceback per dare a Gemini il massimo contesto.
        error_details = traceback.format_exc()
        return ("error", error_details)