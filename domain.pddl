(define (domain sushi-quest)
  (:requirements :strips :typing :universal-preconditions) ; :universal-preconditions è necessario per il forall nel goal

  ; --- TIPI ---
  ; Definisce le categorie di entità nel mondo, con gerarchie per specificare i ruoli.
  ; La regola "specifico - generico" è rispettata.
  (:types
    punto_partenza - luogo   ; Un tipo speciale di luogo da cui si inizia.
    punto_arrivo - luogo     ; Un tipo speciale di luogo che è la destinazione finale.
    luogo                    ; Categoria generica per tutte le location.

    guerriero - personaggio        ; Un personaggio con l'abilità di combattere.
    compagno_viaggio - personaggio ; Un personaggio che deve arrivare a destinazione.
    personaggio                    ; Categoria generica per tutte le figure.

    arma - oggetto           ; Un tipo speciale di oggetto usato per combattere.
    oggetto                  ; Categoria generica per tutti gli item.

    antagonista              ; Una categoria a sé per le minacce.
  )

  ; --- PREDICATI ---
  ; Definisce le proprietà e le relazioni che possono essere vere o false, descrivendo lo stato del mondo.
  (:predicates
    (si_trova_a ?p - personaggio ?l - luogo)              ; Un personaggio ?p si trova nel luogo ?l.
    (si_trova_a_oggetto ?o - oggetto ?l - luogo)          ; Un oggetto ?o si trova nel luogo ?l.
    (ha_con_se ?p - guerriero ?a - arma)                  ; Un guerriero ?p ha con sé un'arma ?a.
    (connessi ?da - luogo ?a - luogo)                     ; Esiste un percorso diretto dal luogo ?da al luogo ?a.
    (antagonista_presente_a ?ant - antagonista ?l - luogo) ; Un antagonista ?ant è presente nel luogo ?l.
    (antagonista_sconfitto ?ant - antagonista)            ; L'antagonista ?ant è stato sconfitto.
    (missione_completata)                                 ; Predicato-flag che indica il raggiungimento dell'obiettivo.
  )

  ; --- AZIONI ---

  ; Azione: Viaggiare tra due luoghi connessi.
  ; Può essere eseguita da qualsiasi 'personaggio'.
  (:action viaggiare
    :parameters (?pers - personaggio ?partenza - luogo ?destinazione - luogo)
    :precondition (and
      (si_trova_a ?pers ?partenza)    ; Il personaggio deve trovarsi nel luogo di partenza.
      (connessi ?partenza ?destinazione) ; Deve esistere un percorso tra i due luoghi.
    )
    :effect (and
      (not (si_trova_a ?pers ?partenza)) ; Il personaggio non è più nel luogo di partenza.
      (si_trova_a ?pers ?destinazione)  ; Il personaggio è ora nel luogo di destinazione.
    )
  )

  ; Azione: Raccogliere un'arma.
  ; Può essere eseguita solo da un 'guerriero'.
  (:action raccogliere_arma
    :parameters (?g - guerriero ?a - arma ?l - luogo)
    :precondition (and
      (si_trova_a ?g ?l)           ; Il guerriero deve essere nello stesso luogo dell'arma.
      (si_trova_a_oggetto ?a ?l)   ; L'arma deve trovarsi in quel luogo (e non essere già posseduta).
    )
    :effect (and
      (ha_con_se ?g ?a)               ; Ora il guerriero ha con sé l'arma.
      (not (si_trova_a_oggetto ?a ?l)) ; L'arma non si trova più liberamente nel luogo.
    )
  )

  ; Azione: Sconfiggere un antagonista.
  ; Richiede un 'guerriero' con un 'arma' nello stesso luogo dell' 'antagonista'.
  (:action sconfiggere_antagonista
    :parameters (?g - guerriero ?a - arma ?ant - antagonista ?l - luogo)
    :precondition (and
      (si_trova_a ?g ?l)                      ; Il guerriero deve essere nel luogo dello scontro.
      (antagonista_presente_a ?ant ?l)        ; L'antagonista deve essere presente lì.
      (ha_con_se ?g ?a)                       ; Il guerriero deve possedere l'arma per combattere.
    )
    :effect (and
      (antagonista_sconfitto ?ant)            ; L'antagonista è ora marcato come sconfitto.
      (not (antagonista_presente_a ?ant ?l))  ; L'antagonista non è più una minaccia presente in quel luogo.
    )
  )

  ; Azione: Completare la missione mangiando al ristorante.
  ; Richiede che tutti i personaggi siano a destinazione e che tutti gli antagonisti siano sconfitti.
  (:action mangiare_finalmente
    :parameters (?g - guerriero ?c - compagno_viaggio ?dest - punto_arrivo)
    :precondition (and
      (si_trova_a ?g ?dest) ; Il guerriero deve essere a destinazione.
      (si_trova_a ?c ?dest) ; Anche il compagno deve essere a destinazione.
      (forall (?ant - antagonista) ; Precondizione universale: PER OGNI antagonista nel mondo...
        (antagonista_sconfitto ?ant) ; ...deve essere vero che è stato sconfitto.
      )
    )
    :effect (and
      (missione_completata) ; L'obiettivo finale è raggiunto.
    )
  )
)