import os
import re
import google.generativeai as genai
import test_pddl

# --- CONFIGURAZIONE ---
GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
if not GOOGLE_API_KEY:
    raise EnvironmentError("Devi impostare la variabile d'ambiente GOOGLE_API_KEY con la tua chiave API Google.")
genai.configure(api_key=GOOGLE_API_KEY)


# --- FUNZIONI DI SUPPORTO ---
def extract_pddl_code(text, block_type):
    """Estrae un blocco di codice PDDL dalla risposta."""
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


def generate_pddl_from_lore(lore_text, domain_example, problem_example):
    """Genera i file PDDL usando Gemini."""
    model = genai.GenerativeModel('gemini-2.5-pro')
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
    print("\nInvio della richiesta a Gemini per generare i file PDDL...")
    try:
        response = model.generate_content(prompt)
        full_text = response.text
        domain_pddl = extract_pddl_code(full_text, 'domain')
        problem_pddl = extract_pddl_code(full_text, 'problem')
        if domain_pddl and problem_pddl:
            print("PDDL generato con successo.")
            return domain_pddl, problem_pddl
        else:
            print("ERRORE: Impossibile estrarre codice PDDL valido.")
            print("Output ricevuto:\n", full_text)
            return None
    except Exception as e:
        print(f"Errore nella chiamata a Gemini: {e}")
        return None


def save_pddl_files(domain_pddl, problem_pddl, domain_filename="domain.pddl", problem_filename="problem.pddl"):
    """Salva i file PDDL."""
    with open(domain_filename, "w", encoding="utf-8") as f:
        f.write(domain_pddl)
    with open(problem_filename, "w", encoding="utf-8") as f:
        f.write(problem_pddl)
    print(f"File salvati: '{domain_filename}', '{problem_filename}'")


# --- REFLECTION AGENT ---
def reflection_agent(lore_text, domain_pddl, problem_pddl):
    """Analizza il PDDL e propone modifiche, chiedendo conferma per rigenerare e ristampare il piano."""
    model = genai.GenerativeModel('gemini-2.5-pro')
    user_input = ""
    while True:
        prompt = f"""
        Sei un Reflection Agent. Analizza e proponi correzioni al PDDL.

        Lore:
        {lore_text}

        Dominio:
        {domain_pddl}

        Problema:
        {problem_pddl}

        L'utente ha detto finora: {user_input}

        Indica cosa cambiare per ottenere un piano valido. 
        Rispondi con le modifiche proposte e attendi che l'utente scriva 'conferma' per applicarle.
        """
        response = model.generate_content(prompt)
        print("\n--- PROPOSTA DEL REFLECTION AGENT ---")
        print(response.text)

        user_input = input("\nScrivi 'conferma' per applicare le modifiche, 'exit' per uscire, o commenta: ")
        if user_input.strip().lower() == "exit":
            print("Chiusura del Reflection Agent.")
            break
        elif user_input.strip().lower() == "conferma":
            print("\nRigenero il PDDL con le modifiche proposte...")
            new_pddl = generate_pddl_from_lore(lore_text, domain_pddl, problem_pddl)
            if new_pddl:
                domain_pddl, problem_pddl = new_pddl
                save_pddl_files(domain_pddl, problem_pddl)
                print("\n--- NUOVO PIANO ---")
                result = test_pddl.check_pddl()
                if not result:
                    print("Il nuovo PDDL non produce ancora un piano valido.")
                else:
                    print("Piano valido trovato!")
            else:
                print("Errore durante la rigenerazione del PDDL.")
        else:
            print("Ok, aggiorno il contesto con il tuo input.")


# --- MAIN ---
if __name__ == "__main__":
    lore_filename = "lore.txt"
    with open(lore_filename, "r", encoding="utf-8") as f:
        lore_data = f.read()
    with open("domain_example.pddl", "r", encoding="utf-8") as f:
        domain_example_data = f.read()
    with open("problem_example.pddl", "r", encoding="utf-8") as f:
        problem_example_data = f.read()

    pddl_output = generate_pddl_from_lore(lore_data, domain_example_data, problem_example_data)
    if pddl_output:
        domain, problem = pddl_output
        save_pddl_files(domain, problem)
        result = test_pddl.check_pddl()
        if not result:
            print("\nNessun piano valido trovato. Avvio del Reflection Agent...")
            reflection_agent(lore_data, domain, problem)
        else:
            print("\nProcesso completato! È stato trovato un piano valido.")
