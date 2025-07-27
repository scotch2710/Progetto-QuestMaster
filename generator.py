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

        Usa i tipi per definire categorie e ruoli (es. personaggio, luogo, salvatore). 
        I nomi specifici degli oggetti (le istanze) appartengono SOLO al file del problema nella sezione (:objects). Scrivere così   (:types
    luogo
    ponte - luogo
    bosco - luogo
    palude - luogo
    torre - luogo
    castello - luogo

    personaggio
    eroe - personaggio
    mulo - personaggio
    
    oggetto
    talismano - oggetto
    cipolla_fumogena - oggetto

    drago) è sbagliato. Nel file domain non va mai messo il tipo generico prima di quelli più particolare, devi invece scrivere così (:types
    ponte - luogo
    luogo

    salvatore - personaggio
    distrattore - personaggio
    da_salvare - personaggio
    personaggio
    
    oggetto
    drago
  ) mettendo il tipo generico dopo. Nel sezione :predicates del file domain non devi ripetere più volte gli stessi predicati come si_trova_a, ognuno può essere definito al massimo una volta.

    GERARCHIA DEI TIPI E RUOLI:

        Usa le gerarchie di tipi per creare relazioni logiche e assegnare ruoli. Ad esempio: salvatore - personaggio significa che un salvatore è un tipo speciale di personaggio e può fare tutto ciò che fa un personaggio, più le azioni specifiche del salvatore. Questo è il metodo corretto per limitare le azioni a certi personaggi.

    AZIONI CON EFFETTI SIGNIFICATIVI:

        Ogni azione (:action) deve avere un effetto (:effect) che modifica lo stato del mondo. Un'azione con un effetto vuoto (and) è inutile per un planner. L'effetto deve aggiungere o rimuovere predicati dallo stato del mondo.

    PRECONDIZIONI SPECIFICHE PER EVITARE SCORCIATOIE:

        Le precondizioni (:precondition) devono essere sufficientemente specifiche da evitare che il planner trovi soluzioni illogiche (come salvare Fiona nella palude). Usa i tipi/ruoli nei parametri delle azioni per limitare chi può fare cosa.

PROCESSO DI GENERAZIONE CONSIGLIATO:

Prima di scrivere il codice, ragiona seguendo questi passi:

    Analisi del Lore: Leggi il lore e identifica le entità (personaggi, luoghi, oggetti) e i loro ruoli.

    Definizione dei Tipi: Traduci queste entità e ruoli in una gerarchia di :types nel dominio.

    Definizione dei Predicati: Identifica le proprietà e le relazioni che possono cambiare (es. posizione di un personaggio, porta chiusa). Traducile in :predicates.

    Definizione delle Azioni: Per ogni azione possibile, definisci chiaramente i parametri, le precondizioni necessarie perché avvenga e gli effetti che produce sullo stato del mondo.

    Scrittura del Codice: Solo a questo punto, scrivi i due blocchi di codice PDDL, commentando ogni linea per spiegare la tua logica, come mostrato negli esempi. Devi stare molto attento 
    al fatto che ci sia un piano per poter completare la missione, questa è la cosa più importante. Deve sempre esserci almeno un percorso nel file pddl che porti alla buona riuscita della 
    missione.

--- ESEMPIO DOMINIO PDDL ---
{domain_example}
--- FINE ESEMPIO DOMINIO ---

--- ESEMPIO PROBLEMA PDDL ---
{problem_example}
--- FINE ESEMPIO PROBLEMA ---

Ora, basandoti sulla seguente NUOVA descrizione della quest e seguendo TUTTE le regole e i processi sopra descritti, genera un nuovo dominio e un nuovo problema PDDL.

--- NUOVO LORE DOCUMENT ---
{lore_text}
--- FINE NUOVO LORE DOCUMENT ---
    """

def get_correction_prompt(error_message):
    """Restituisce il prompt da usare quando un piano fallisce, includendo l'errore specifico."""
    return f"""
    ATTENZIONE: I file PDDL che hai generato hanno causato un errore o non hanno prodotto un piano.
    L'errore specifico restituito dal planner è il seguente. Questo non è un suggerimento, è l'output esatto del validatore, che ti indica il problema preciso.

    --- INIZIO MESSAGGIO DI ERRORE DAL PLANNER ---
    {error_message}
    --- FINE MESSAGGIO DI ERRORE DAL PLANNER ---

    Questo significa che c'è un errore logico nel tuo modello. Possibili cause:
    1.  Una precondizione di un'azione critica non può mai essere soddisfatta.
    2.  Manca un'azione fondamentale per collegare due stati del mondo (es. manca l'azione per aprire una porta).
    3.  L'obiettivo (:goal) è irraggiungibile con le azioni e lo stato iniziale definiti.


    Per favore, analizza con la massima attenzione il messaggio di errore qui sopra. Esso contiene la chiave per risolvere il problema. Ad esempio, potrebbe indicare un tipo non dichiarato, un predicato usato con un numero sbagliato di parametri, o un oggetto non definito.

    PROCESSO DI CORREZIONE RICHIESTO:
    1.  Spiega in italiano quale pensi sia stato l'errore, basandoti SPECIFICATAMENTE sul messaggio di errore fornito.
    2.  Dopo la spiegazione, fornisci le versioni COMPLETAMENTE corrette e riscritte da capo dei file PDDL di dominio e di problema per risolvere l'errore.
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
        plan_found, message = test.check_pddl() # Modificato per ricevere la tupla

        if plan_found:
            print(message) # Stampa il piano trovato
            print("\n✅ Successo! È stato trovato un piano valido.")
            break

        # Se il piano non è stato trovato, 'message' contiene l'errore
        print("\n❌ Fallimento: non è stato trovato un piano o si è verificato un errore.")
        print("--- Messaggio ricevuto dal Planner ---")
        print(message)
        print("---------------------------------------")

        user_consent = input("Vuoi chiedere a Gemini di correggere i file basandosi su questo errore? (y/n): ").lower()
        if user_consent != 'y':
            print("Processo interrotto dall'utente.")
            break

        # Passa il messaggio di errore specifico alla funzione del prompt
        correction_prompt = get_correction_prompt(message)
        print("\nInvio della richiesta di correzione a Gemini...")

        try:
            # Assicurati che la variabile 'chat' sia stata inizializzata prima del ciclo
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
