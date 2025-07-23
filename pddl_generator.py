import os
import re
import google.generativeai as genai
import test_pddl;

# --- CONFIGURAZIONE ---
# 1. Installa la libreria: pip install google-generativeai
# 2. Ottieni la tua API key da Google AI Studio (https://aistudio.google.com/app/apikey)
# 3. Inserisci la tua API key qui sotto.
# Per maggiore sicurezza, è consigliabile caricarla come variabile d'ambiente.
try:
    # Metodo consigliato: carica la chiave da una variabile d'ambiente
    GOOGLE_API_KEY = os.environ['GOOGLE_API_KEY']
    genai.configure(api_key=GOOGLE_API_KEY)
except KeyError:
    # Metodo alternativo: inserisci la chiave direttamente (meno sicuro)
    # Sostituisci "INSERISCI_QUI_LA_TUA_API_KEY" con la tua chiave effettiva
    API_KEY_PLACEHOLDER = "INSERISCI_QUI_LA_TUA_API_KEY"
    if API_KEY_PLACEHOLDER == "INSERISCI_QUI_LA_TUA_API_KEY":
        print("ERRORE: Per favore, inserisci la tua API Key di Gemini nel codice.")
        exit()
    genai.configure(api_key=API_KEY_PLACEHOLDER)






def extract_pddl_code(text, block_type):
    """Estrae un blocco di codice PDDL dalla risposta, cercando '(define (...))'."""
    pattern = re.compile(r'\(\s*define\s*\(\s*' + block_type + r'[^)]+\)(.|\n)*\)', re.IGNORECASE)
    match = pattern.search(text)
    if not match:
        return None
    
    # Una volta trovato l'inizio, cerca la parentesi di chiusura corrispondente
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


def generate_pddl_from_lore(lore_text, domain_example, problem_example):
    """Usa l'API di Gemini con esempi per generare i file PDDL."""
    model = genai.GenerativeModel('gemini-1.5-flash-latest')

    prompt = f"""
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

    Scrittura del Codice: Solo a questo punto, scrivi i due blocchi di codice PDDL, commentando ogni linea per spiegare la tua logica, come mostrato negli esempi.

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

    print("\nInvio della richiesta a Gemini con esempi... Potrebbe richiedere qualche secondo.")
    try:
        response = model.generate_content(prompt)
        full_text = response.text
        
        domain_pddl = extract_pddl_code(full_text, 'domain')
        problem_pddl = extract_pddl_code(full_text, 'problem')

        if domain_pddl and problem_pddl:
            print("Risposta ricevuta e codice PDDL estratto con successo.")
            return domain_pddl, problem_pddl
        else:
            print("ERRORE: Non è stato possibile estrarre codice PDDL valido dalla risposta.")
            print("Output ricevuto:\n", full_text)
            return None

    except Exception as e:
        print(f"Si è verificato un errore durante la chiamata all'API di Gemini: {e}")
        return None

def save_pddl_files(domain_pddl, problem_pddl, domain_filename="domain.pddl", problem_filename="problem.pddl"):
    """Salva le stringhe PDDL in file di testo."""
    with open(domain_filename, "w", encoding="utf-8") as f:
        f.write(domain_pddl)
    print(f"File di dominio salvato come '{domain_filename}'")

    with open(problem_filename, "w", encoding="utf-8") as f:
        f.write(problem_pddl)
    print(f"File di problema salvato come '{problem_filename}'")


if __name__ == "__main__":
    # 1. Crea o verifica l'esistenza del file di lore
    lore_filename = "lore.txt"
    

  

    # 3. Leggi il lore e gli esempi
    with open(lore_filename, "r", encoding="utf-8") as f:
        lore_data = f.read()
    with open("domain_example.pddl", "r", encoding="utf-8") as f:
        domain_example_data = f.read()
    with open("problem_example.pddl", "r", encoding="utf-8") as f:
        problem_example_data = f.read()

    # 4. Genera il PDDL usando Gemini con gli esempi
    pddl_output = generate_pddl_from_lore(lore_data, domain_example_data, problem_example_data)

    # 5. Se la generazione ha avuto successo, salva i nuovi file
    if pddl_output:
        domain, problem = pddl_output
        save_pddl_files(domain, problem)
        print("\nProcesso completato! Controlla i nuovi file 'domain.pddl' e 'problem.pddl'.")
    
    test_pddl.check_pddl()

