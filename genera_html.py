import google.generativeai as genai
import os

def configura_api_gemini():
    """
    Configura l'API di Gemini usando la chiave API dalla variabile d'ambiente.
    Lancia un'eccezione se la chiave non è impostata.
    """
    
    api_key = os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        raise ValueError("La variabile d'ambiente GEMINI_API_KEY non è stata impostata.")
    genai.configure(api_key=api_key)

def leggi_file_di_testo(lista_file):
    """
    Legge il contenuto di una lista di file di testo e lo restituisce come una singola stringa.

    Args:
        lista_file (list): Una lista di percorsi di file.

    Returns:
        str: Il contenuto combinato dei file.
    """
    contenuto_completo = ""
    for percorso_file in lista_file:
        try:
            with open(percorso_file, 'r', encoding='utf-8') as f:
                contenuto_completo += f"--- Contenuto dal file: {percorso_file} ---\n"
                contenuto_completo += f.read()
                contenuto_completo += "\n\n"
        except FileNotFoundError:
            print(f"Attenzione: il file {percorso_file} non è stato trovato e sarà ignorato.")
    return contenuto_completo

def genera_html_con_gemini(prompt_utente, contenuto_testo):
    """
    Invia il prompt e il contenuto dei file a Gemini per generare il codice HTML.

    Args:
        prompt_utente (str): Le istruzioni per il modello.
        contenuto_testo (str): Il testo estratto dai file da includere.

    Returns:
        str: Il codice HTML generato dal modello.
    """
    print("Invio della richiesta a Gemini...")

    # Istruzioni precise per il modello per ottenere solo codice pulito
    prompt_completo = f"""
    Sei un esperto sviluppatore web. Il tuo compito è generare un file HTML5 completo e valido.
    Basati sulle seguenti istruzioni dell'utente e sui contenuti testuali forniti.

    **Istruzioni Utente:**
    {prompt_utente}

    **Contenuto Testuale dai File:**
    {contenuto_testo}

    **REGOLE IMPORTANTI:**
    1.  Il tuo output DEVE essere solo ed esclusivamente il codice HTML.
    2.  Non includere spiegazioni, commenti o markdown come ```html prima o dopo il codice.
    3.  Assicurati che l'HTML sia ben formattato e semanticamente corretto.
    4.  Usa l'encoding UTF-8.
    """

    model = genai.GenerativeModel('gemini-2.5-pro')
    response = model.generate_content(prompt_completo)
    
    # Pulizia di eventuali markdown residui (precauzione)
    html_generato = response.text.strip()
    if html_generato.startswith("```html"):
        html_generato = html_generato[7:]
    if html_generato.endswith("```"):
        html_generato = html_generato[:-3]

    print("Codice HTML generato con successo!")
    return html_generato.strip()

def salva_html(codice_html, nome_file_output):
    """
    Salva la stringa del codice HTML in un file.

    Args:
        codice_html (str): Il codice HTML da salvare.
        nome_file_output (str): Il nome del file di output (es. 'pagina.html').
    """
    try:
        with open(nome_file_output, 'w', encoding='utf-8') as f:
            f.write(codice_html)
        print(f"File salvato con successo come: {nome_file_output}")
    except IOError as e:
        print(f"Errore durante il salvataggio del file: {e}")


def start_generazione():
    # ---  CONFIGURAZIONE UTENTE ---

    # 1. Scrivi qui le istruzioni per Gemini.
    prompt_utente = """ Create an interactive web-based narrative experience.
    Devi generare un file html di un gioco partendo da una storia descritta nel file "lore.txt", deve essere una pagina interattiva all'interno della quale il giocatore deve poter fare 
    delle scelte, almeno 2 possibilità per livello, per proseguire la storia e arrivare all'obiettivo finale. Possono esserci anche finali negativi e percorsi nelle scelte che non portano a nulla.
    Usa anche i file "domain.pddl" e "problem.pddl" per modellare meglio la storia, seguire un filo logico e avere un miglior contesto.
    """

    # 2. Elenca i file di testo che vuoi usare come input.
    file_di_testo = [ "lore.txt", "domain.pddl", "problem.pddl"]
    
    # 3. Scegli il nome del file HTML di output.
    nome_file_output = "gioco_interattivo.html"

    # --- ESECUZIONE SCRIPT ---
    try:
        configura_api_gemini()
        contenuto_da_file = leggi_file_di_testo(file_di_testo)

        if contenuto_da_file:
            codice_html_risultante = genera_html_con_gemini(prompt_utente, contenuto_da_file)
            salva_html(codice_html_risultante, nome_file_output)
        else:
            print("Nessun contenuto dai file di input, lo script non può continuare.")

    except ValueError as e:
        print(f"Errore di configurazione: {e}")
    except Exception as e:
        print(f"Si è verificato un errore inaspettato: {e}")