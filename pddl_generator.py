import os
import re
import google.generativeai as genai

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


def create_example_lore_file(filename="lore.txt"):
    """Crea un file lore.txt di esempio se non esiste già."""
    if not os.path.exists(filename):
        print(f"File '{filename}' non trovato. Ne creo uno di esempio.")
        # (Contenuto del lore omesso per brevità, è identico alla versione precedente)
        lore_content = """
# Quest Description
L'avventura si intitola "La Spada del Re Decaduto". L'eroe, Artus, deve recuperare la leggendaria spada Excalibur per reclamare il trono.
# Initial State
- Artus si trova nella foresta di Sherwood.
- Excalibur è incastrata in una roccia magica al centro della foresta.
- La roccia è protetta da un golem di pietra.
- Artus possiede un martello da guerra.
# Goal
- Artus deve possedere Excalibur.
# Obstacles
- Il golem di pietra blocca l'accesso alla spada.
- Il golem può essere sconfitto solo se Artus è abbastanza forte.
- Per diventare forte, Artus deve trovare e bere una pozione della forza nascosta in una grotta.
# Branching Factor
- Minimo: 2 azioni possibili per stato.
- Massimo: 4 azioni possibili per stato.
# Depth Constraints
- Minimo: 3 passi per la soluzione.
- Massimo: 6 passi per la soluzione.
"""
        with open(filename, "w", encoding="utf-8") as f:
            f.write(lore_content)
        print(f"File '{filename}' creato con successo.")
    else:
        print(f"Utilizzo il file '{filename}' esistente.")

def create_example_pddl_files():
    """
    Crea file PDDL di esempio (domain e problem) se non esistono.
    Questi file serviranno da guida per il modello LLM.
    """
    if not os.path.exists("domain_example.pddl"):
        print("File 'domain_example.pddl' non trovato. Ne creo uno di esempio.")
        domain_example_content = """; Un dominio per l'avventura della Spada del Re Decaduto
(define (domain spada-del-re)
  ; Definisce i requisiti base per il planning
  (:requirements :strips)

  ; Definisce i tipi di oggetti nel nostro mondo
  (:types
    eroe oggetto luogo creatura - object
  )

  ; Definisce i predicati, ovvero le proprietà che possono essere vere o false
  (:predicates
    (at ?p - object ?l - luogo) ; L'oggetto p si trova nel luogo l
    (has ?e - eroe ?o - oggetto) ; L'eroe e possiede l'oggetto o
    (is-strong ?e - eroe) ; L'eroe e è forte
    (protects ?c - creatura ?o - oggetto) ; La creatura c protegge l'oggetto o
  )

  ; Azione: muoversi da un luogo all'altro
  (:action move
    :parameters (?e - eroe ?from - luogo ?to - luogo)
    :precondition (and (at ?e ?from))
    :effect (and (not (at ?e ?from)) (at ?e ?to))
  )

  ; Azione: bere una pozione per diventare forti
  (:action drink-potion
    :parameters (?e - eroe ?p - oggetto ?l - luogo)
    :precondition (and (at ?e ?l) (at ?p ?l) (has ?e ?p))
    :effect (and (is-strong ?e))
  )

  ; Azione: sconfiggere una creatura
  (:action defeat-golem
    :parameters (?e - eroe ?g - creatura ?s - oggetto ?l - luogo)
    :precondition (and (at ?e ?l) (at ?g ?l) (is-strong ?e) (protects ?g ?s))
    :effect (and (not (protects ?g ?s)))
  )

  ; Azione: prendere un oggetto
  (:action take-sword
    :parameters (?e - eroe ?s - oggetto ?l - luogo)
    :precondition (and (at ?e ?l) (at ?s ?l) (not (exists (?c - creatura) (protects ?c ?s))))
    :effect (and (has ?e ?s))
  )
)"""
        with open("domain_example.pddl", "w", encoding="utf-8") as f:
            f.write(domain_example_content)

    if not os.path.exists("problem_example.pddl"):
        print("File 'problem_example.pddl' non trovato. Ne creo uno di esempio.")
        problem_example_content = """; File del problema per l'avventura della Spada del Re Decaduto
(define (problem recupera-spada)
  ; Specifica a quale dominio appartiene questo problema
  (:domain spada-del-re)

  ; Elenca tutti gli oggetti concreti che esistono in questa istanza del problema
  (:objects
    artus - eroe
    excalibur pozione-forza martello - oggetto
    foresta grotta roccia-magica - luogo
    golem - creatura
  )

  ; Definisce lo stato iniziale del mondo
  (:init
    ; Posizioni iniziali
    (at artus foresta)
    (at pozione-forza grotta)
    (at excalibur roccia-magica)
    (at golem roccia-magica)
    (at martello foresta)

    ; Proprietà iniziali
    (has artus martello)
    (protects golem excalibur)
  )

  ; Definisce l'obiettivo da raggiungere
  (:goal
    (and
      (has artus excalibur)
    )
  )
)"""
        with open("problem_example.pddl", "w", encoding="utf-8") as f:
            f.write(problem_example_content)

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
    Sei un esperto di Intelligenza Artificiale specializzato in planning e PDDL.
    Il tuo compito è tradurre una descrizione narrativa (lore) in file PDDL sintatticamente perfetti.

    Usa i seguenti due esempi come guida STRETTA per la sintassi, la struttura e lo stile dei commenti. Non deviare da questo formato.

    --- ESEMPIO DOMINIO PDDL ---
    {domain_example}
    --- FINE ESEMPIO DOMINIO ---

    --- ESEMPIO PROBLEMA PDDL ---
    {problem_example}
    --- FINE ESEMPIO PROBLEMA ---

    Ora, basandoti sulla seguente NUOVA descrizione della quest, genera un nuovo dominio e un nuovo problema PDDL.
    Assicurati che ogni linea di codice sia commentata, esattamente come negli esempi.
    Produci solo ed esclusivamente i due blocchi di codice PDDL, senza alcun testo aggiuntivo.

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
    create_example_lore_file(lore_filename)

    # 2. Crea o verifica l'esistenza dei file PDDL di esempio
    create_example_pddl_files()

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

