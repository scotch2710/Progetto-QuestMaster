import os
import google.generativeai as genai

# Carica la chiave API dalla variabile d'ambiente
api_key = os.environ['GOOGLE_API_KEY']

if not api_key:
    print("Errore: La variabile d'ambiente GEMINI_API_KEY non è impostata.")
    exit()

# Configura Gemini
genai.configure(api_key=api_key)

# Impostazioni del modello
generation_config = {
    "temperature": 0.7,
    "top_p": 1,
    "top_k": 1,
    "max_output_tokens": 2048,
}

# Creazione del modello
model = genai.GenerativeModel(
    model_name="gemini-2.5-pro",
    generation_config=generation_config
)

# Avvia la sessione di chat, la cronologia verrà salvata qui
chat = model.start_chat(history=[])

print("Chat con Gemini avviata! (scrivi 'esci' o 'quit' per terminare)")
print("----------------------------------------------------------------")

while True:
    # Chiedi l'input all'utente
    user_input = input("👤 Tu: ")

    # Controlla se l'utente vuole uscire
    if user_input.lower() in ["esci", "quit"]:
        print("👋 Arrivederci!")
        break

    # Invia il messaggio a Gemini e ricevi la risposta in streaming
    # Lo streaming rende la risposta più fluida, apparendo man mano che viene generata
    response = chat.send_message(user_input, stream=True)

    print("🤖 Gemini: ", end="")
    for chunk in response:
        print(chunk.text, end="")
    print("\n") # Aggiunge una riga vuota per separare i messaggi