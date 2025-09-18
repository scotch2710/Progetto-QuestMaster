import os
import re
import google.generativeai as genai
import test_pddl
import genera_html

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


def generate_pddl_from_lore(lore_text, domain_example, problem_example, error_context=None):
    """Genera i file PDDL usando Gemini, includendo un eventuale errore precedente."""

    model = genai.GenerativeModel('gemini-2.5-pro')
    error_prompt_section = ""
    
    if error_context:
        error_prompt_section = f"""
        ATTENZIONE: Il precedente tentativo ha fallito o è stato rifiutato dall'utente.
        Analizza attentamente il seguente feedback per risolvere il problema.

        --- FEEDBACK / ERRORE PRECEDENTE ---
        {error_context}
        --- FINE FEEDBACK / ERRORE ---
        
        Se il feedback indica un problema LOGICO (un piano valido ma senza senso), la tua priorità è modificare le PRECONDIZIONI o gli EFFETTI delle azioni per renderlo impossibile.
        Se il feedback indica un problema di SINTASSI, correggi la dichiarazione errata.
        
        Ora rigenera il PDDL correggendo il problema.
        """

    prompt = f"""
    Sei un logico e un esperto di AI Planning, specializzato nella creazione di modelli PDDL robusti e semanticamente corretti a partire da descrizioni narrative.
    Il tuo obiettivo è analizzare un documento di "lore" e derivare un modello PDDL logicamente coerente e sintatticamente perfetto.
    
    {error_prompt_section}

    REGOLE FONDAMENTALI DA SEGUIRE SCRUPOLOSAMENTE: SEPARAZIONE DOMINIO/PROBLEMA (REGOLA PIÙ IMPORTANTE):

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
--- FINE NUOVO LORE DOCUMENT --- """
    
    
    
    
    
    
    print("\nInvio della richiesta a Gemini per generare/correggere i file PDDL...")
    
    
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


def start_reflection_agent(lore_text, domain_pddl, problem_pddl, domain_example, problem_example):
    """
    Avvia un ciclo di chat interattivo per correggere un PDDL che non produce un piano.
    Restituisce il nuovo (domain, problem) o (None, None) se l'utente esce.
    """
    print("\n--- ATTIVAZIONE REFLECTION AGENT ---")
    print("Il PDDL è valido ma non è stato trovato un piano. Avvio sessione interattiva per risolvere problemi logici.")

    # Usiamo una lista per mantenere la cronologia della conversazione con l'agente
    conversation_history = [
        f"Il PDDL attuale è sintatticamente valido, ma il planner non trova una soluzione. "
        f"Questo indica un problema logico, come un obiettivo irraggiungibile o precondizioni che non possono mai essere soddisfatte. "
        f"Analizza il file lore, il dominio e il problema per identificare la causa."
    ]

    while True:
        # Costruisci il contesto per Gemini
        error_context = "\n".join(conversation_history)
        
        # Chiediamo a Gemini di analizzare e proporre una soluzione
        domain, problem = generate_pddl_from_lore(
            lore_text,
            domain_example,
            problem_example,
            error_context=error_context
        )

        if not (domain and problem):
            print("L'agente non è riuscito a generare una correzione valida. Uscita dal Reflection Agent.")
            return None, None

        # Mostra la nuova proposta all'utente
        print("\n--- NUOVA PROPOSTA DALL'AGENTE ---")
        print("Nuovo Dominio Proposto:\n", domain)
        print("\nNuovo Problema Proposto:\n", problem)
        
        user_input = input(
            "\nVuoi accettare questa nuova versione e testarla? "
            "(scrivi 'si' per accettare, 'no' per dare un altro feedback, 'esci' per terminare): "
        ).lower().strip()

        if user_input in ["si", "s", "yes", "y"]:
            print("Proposta accettata. Ritorno al ciclo di validazione principale...")
            return domain, problem
        elif user_input in ["esci", "exit"]:
            print("Uscita dal Reflection Agent.")
            return None, None
        else:
            # L'utente vuole dare altro feedback
            feedback = input("Fornisci il tuo feedback per la prossima iterazione: ")
            conversation_history.append(f"FEEDBACK UTENTE: {feedback}")
            print("Feedback registrato. L'agente userà questa informazione per la prossima proposta.")



# --- MAIN ---
if __name__ == "__main__":
    lore_filename = "lore.txt"
    with open(lore_filename, "r", encoding="utf-8") as f:
        lore_data = f.read()
    with open("domain_example.pddl", "r", encoding="utf-8") as f:
        domain_example_data = f.read()
    with open("problem_example.pddl", "r", encoding="utf-8") as f:
        problem_example_data = f.read()

    # Tentativo iniziale
    domain, problem = generate_pddl_from_lore(lore_data, domain_example_data, problem_example_data)
    
    error_for_next_iteration = None
    max_retries = 20
    
    for i in range(max_retries):
        if domain and problem:
            save_pddl_files(domain, problem)
            status, message = test_pddl.check_pddl()

            if status == "success":
                print("\nProcesso completato! È stato trovato un piano valido.")
                print(message)
                
                user_input = input("\nQuesto piano è logicamente corretto? (si/no): ").lower().strip()
            
                if user_input in ["si", "s", "yes", "y"]:
                    print("\nOttimo! Il piano è stato approvato. Processo completato. \nProcedo a generare il file HTML dell'avventura interattiva...")
                    genera_html.start_generazione()
                    break # Il piano è corretto, usciamo dal ciclo.
                else:
                    # Il piano è valido ma non corretto, chiediamo dettagli.
                    details = input("Per favore, spiega perché il piano non è corretto (es. 'un personaggio non dovrebbe poter fare X'): ")
                    error_for_next_iteration = f"""
                    Il piano precedente era SINTATTICAMENTE VALIDO, ma LOGICAMENTE SCORRETTO secondo la validazione umana.
                    Questo è un problema di modello (precondizioni/effetti), non di sintassi.

                    PIANO RIFIUTATO DALL'UTENTE:
                    {message}
                
                    MOTIVAZIONE DEL RIFIUTO:
                    {details}
                
                    Per favore, modifica le azioni, le precondizioni o gli effetti nel file di dominio per impedire questo comportamento illogico.
                    """
                    print(f"\nFeedback registrato. Tentativo di correzione {i+1}/{max_retries}...")
        






            elif status == "no_plan":
                print(f"\nIl PDDL è valido ma non è stato trovato un piano. Tentativo di correzione {i+1}/{max_retries}...")
                error_for_next_iteration = message

                # Attiva l'agente riflessivo interattivo
                new_domain, new_problem = start_reflection_agent(
                    lore_data, domain, problem, domain_example_data, problem_example_data
                )
                if new_domain and new_problem:
                    domain, problem = new_domain, new_problem
                    # Continua il ciclo per una nuova validazione completa
                    continue 
                else:
                    print("Reflection Agent terminato senza una soluzione. Interruzione del processo.")
                    continue
            elif status == "error":
                print(f"\nErrore di sintassi PDDL rilevato. Tentativo di correzione {i+1}/{max_retries}...")
                print(message) # Mostra l'errore dettagliato all'utente
                error_for_next_iteration = message
        else:
            print("Generazione PDDL fallita. Interruzione.")
            break

        # Se siamo arrivati qui, c'è stato un errore o nessun piano. Tentiamo la rigenerazione.
        if i < max_retries - 1:
             domain, problem = generate_pddl_from_lore(
                lore_data, 
                domain_example_data, 
                problem_example_data, 
                error_context=error_for_next_iteration
            )
        else:
            print("\nNumero massimo di tentativi di correzione raggiunto. Interruzione del processo.")

