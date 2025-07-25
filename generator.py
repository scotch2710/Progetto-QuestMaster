import os
import re
import google.generativeai as genai
import test

# --- CONFIGURAZIONE ---
# Assicurati che la tua API key sia configurata come variabile d'ambiente
try:
    GOOGLE_API_KEY = os.environ['GOOGLE_API_KEY']
    genai.configure(api_key=GOOGLE_API_KEY)
except KeyError:
    print("ERRORE: La variabile d'ambiente GOOGLE_API_KEY non è stata impostata.")
    exit()

def extract_pddl_code(text, block_type):
    """Estrae un blocco di codice PDDL dalla risposta, cercando '(define (...))'."""
    pattern = re.compile(r'\(\s*define\s*\(\s*' + block_type + r'[^)]+\)(.|\n)*\)', re.IGNORECASE)
    match = pattern.search(text)
    if not match:
        return None
    
    block_text = match.group(0)
    open_parens = 0
    end_index = -1
    for i, char in enumerate(block_text):
        if char == '(':
            open_parens += 1
        elif char == ')':
            open_parens -= 1
            if open_parens == 0:
                end_index = i + 1
                break
    
    return block_text[:end_index] if end_index != -1 else None

def get_initial_prompt(lore_text, domain_example, problem_example):
    """Costruisce il prompt iniziale per la generazione PDDL."""
    return f"""
    Sei un logico e un esperto di AI Planning, specializzato nella creazione di modelli PDDL robusti e semanticamente corretti a partire da descrizioni narrative.

    Il tuo obiettivo è analizzare un documento di "lore" e derivare un modello PDDL logicamente coerente e sintatticamente perfetto, composto da un file di dominio e uno di problema.

    REGOLE FONDAMENTALI DA SEGUIRE SCRUPOLOSAMENTE:

    SEPARAZIONE DOMINIO/PROBLEMA (REGOLA PIÙ IMPORTANTE):
        Il file di dominio deve essere COMPLETAMENTE GENERICO. Non deve MAI contenere nomi di oggetti specifici (es. fiona, torree, chiave_della_torre).
        Usa i tipi per definire categorie e ruoli (es. personaggio, luogo, salvatore). I nomi specifici degli oggetti (le istanze) appartengono SOLO al file del problema nella sezione (:objects).

    GERARCHIA DEI TIPI E RUOLI:
        Usa le gerarchie di tipi per creare relazioni logiche. Il tipo più generico va sempre messo per ultimo (es. salvatore - personaggio).

    AZIONI CON EFFETTI SIGNIFICATIVI:
        Ogni azione (:action) deve avere un effetto (:effect) che modifica lo stato del mondo.

    PRECONDIZIONI SPECIFICHE PER EVITARE SCORCIATOIE:
        Le precondizioni (:precondition) devono essere sufficientemente specifiche da evitare soluzioni illogiche.

    PROCESSO DI GENERAZIONE:
    Prima di scrivere il codice, ragiona sui tipi, predicati e azioni. Assicurati che esista sempre un percorso logico per raggiungere l'obiettivo.

    --- ESEMPIO DOMINIO PDDL ---
    {domain_example}
    --- FINE ESEMPIO DOMINIO ---

    --- ESEMPIO PROBLEMA PDDL ---
    {problem_example}
    --- FINE ESEMPIO PROBLEMA ---

    Ora, basandoti sulla seguente NUOVA descrizione della quest e seguendo TUTTE le regole, genera un nuovo dominio e un nuovo problema PDDL.

    --- NUOVO LORE DOCUMENT ---
    {lore_text}
    --- FINE NUOVO LORE DOCUMENT ---
    """

def get_correction_prompt():
    """Restituisce il prompt da usare quando un piano fallisce."""
    return """
    ATTENZIONE: I file di dominio e problema che hai appena generato non hanno prodotto un piano risolvibile. 
    L'analizzatore PDDL non è riuscito a trovare una sequenza di azioni valida per raggiungere l'obiettivo.

    Questo significa che c'è un errore logico nel tuo modello. Possibili cause:
    1.  Una precondizione di un'azione critica non può mai essere soddisfatta.
    2.  Manca un'azione fondamentale per collegare due stati del mondo (es. manca l'azione per aprire una porta).
    3.  L'obiettivo (:goal) è irraggiungibile con le azioni e lo stato iniziale definiti.

    Per favore, analizza attentamente la tua risposta precedente.
    
    PROCESSO DI CORREZIONE:
    1.  Spiega in italiano quale pensi sia stato l'errore logico nel tuo precedente tentativo.
    2.  Dopo la spiegazione, fornisci le versioni COMPLETAMENTE corrette dei file PDDL di dominio e di problema. Non fornire solo frammenti, ma l'intero codice per entrambi i file.
    """

def save_pddl_files(domain_pddl, problem_pddl, domain_filename="domain.pddl", problem_filename="problem.pddl"):
    """Salva le stringhe PDDL in file di testo."""
    with open(domain_filename, "w", encoding="utf-8") as f:
        f.write(domain_pddl)
    print(f"File di dominio salvato come '{domain_filename}'")

    with open(problem_filename, "w", encoding="utf-8") as f:
        f.write(problem_pddl)
    print(f"File di problema salvato come '{problem_filename}'")
    return True

if __name__ == "__main__":
    lore_filename = "lore.txt"
    domain_example_filename = "domain_example.pddl"
    problem_example_filename = "problem_example.pddl"

    try:
        with open(lore_filename, "r", encoding="utf-8") as f:
            lore_data = f.read()
        with open(domain_example_filename, "r", encoding="utf-8") as f:
            domain_example_data = f.read()
        with open(problem_example_filename, "r", encoding="utf-8") as f:
            problem_example_data = f.read()
    except FileNotFoundError as e:
        print(f"ERRORE: File non trovato - {e.filename}. Assicurati che esista.")
        exit()

    model = genai.GenerativeModel('gemini-1.5-pro') # O il modello che preferisci
    chat = model.start_chat(history=[]) # Inizia una sessione di chat con cronologia

    # --- Generazione Iniziale ---
    initial_prompt = get_initial_prompt(lore_data, domain_example_data, problem_example_data)
    print("\nInvio della richiesta iniziale a Gemini...")
    
    try:
        response = chat.send_message(initial_prompt)
        full_text = response.text
        
        domain, problem = extract_pddl_code(full_text, 'domain'), extract_pddl_code(full_text, 'problem')

        if not (domain and problem):
            print("ERRORE CRITICO: Impossibile estrarre il PDDL dalla prima risposta di Gemini.")
            print("Output ricevuto:\n", full_text)
            exit()
        
        save_pddl_files(domain, problem)

    except Exception as e:
        print(f"Si è verificato un errore durante la chiamata all'API di Gemini: {e}")
        exit()

    # --- Ciclo di Test e Correzione ---
    while True:
        print("\n--- Verifica del piano PDDL ---")
        plan_found = test.check_pddl()

        if plan_found:
            print("\n✅ Successo! È stato trovato un piano valido.")
            break # Esce dal ciclo se il piano ha successo
        
        # Se il piano non viene trovato
        print("\n❌ Fallimento: non è stato trovato un piano. Avvio della sessione di correzione con Gemini.")
        
        user_consent = input("Vuoi chiedere a Gemini di correggere i file? (y/n): ").lower()
        if user_consent != 'y':
            print("Processo interrotto dall'utente.")
            break

        correction_prompt = get_correction_prompt()
        print("\nInvio della richiesta di correzione a Gemini...")

        try:
            response = chat.send_message(correction_prompt)
            full_text = response.text
            
            print("\n--- Proposta di Correzione di Gemini ---")
            print(full_text)
            print("------------------------------------------")
            
            new_domain = extract_pddl_code(full_text, 'domain')
            new_problem = extract_pddl_code(full_text, 'problem')

            if new_domain and new_problem:
                apply_changes = input("Vuoi applicare le modifiche suggerite e riprovare? (y/n): ").lower()
                if apply_changes == 'y':
                    save_pddl_files(new_domain, new_problem)
                    # Il ciclo continuerà e rieseguirà il test
                else:
                    print("Modifiche rifiutate. Processo terminato.")
                    break
            else:
                print("ERRORE: Gemini ha risposto ma non è stato possibile estrarre un PDDL valido dalla sua correzione.")
                print("Processo terminato.")
                break

        except Exception as e:
            print(f"Si è verificato un errore durante la chiamata API per la correzione: {e}")
            break