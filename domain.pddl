(define (domain shrek-quest-for-the-swamp)
  (:requirements :strips :typing)

  ;; --- TIPI DI ENTITÀ E RUOLI ---
  ;; Definisce la gerarchia di tutti gli elementi nel mondo.
  ;; La sintassi 'sottotipo - tipo_padre' seguita dalla dichiarazione del tipo_padre
  ;; è fondamentale per evitare errori di ricorsione durante il parsing.
  (:types
    ;; Gerarchia dei Luoghi
    palude castello torre foresta - luogo
    luogo

    ;; Gerarchia dei Personaggi e dei loro Ruoli
    salvatore compagno da_salvare mandante - personaggio
    personaggio

    ;; Tipi di Ostacoli
    drago
    cavaliere
  )

  ;; --- PREDICATI ---
  ;; Descrivono le proprietà e le relazioni tra gli oggetti che possono cambiare.
  (:predicates
    ;; (si_trova_a ?chi - object ?dove - luogo) - Indica la posizione di qualsiasi oggetto (personaggi, draghi, ecc.).
    (si_trova_a ?o - object ?l - luogo)
    
    ;; (collegato ?da - luogo ?a - luogo) - Indica che esiste un percorso diretto tra due luoghi.
    (collegato ?da - luogo ?a - luogo)
    
    ;; (is_mobile ?p - personaggio) - Un personaggio può viaggiare autonomamente solo se questo predicato è vero.
    (is_mobile ?p - personaggio)
    
    ;; (palude_occupata) - Stato iniziale del problema: la palude di Shrek è invasa.
    (palude_occupata)
    
    ;; (accordo_stretto ?m - mandante ?s - salvatore) - L'accordo tra il mandante e il salvatore è stato siglato.
    (accordo_stretto ?m - mandante ?s - salvatore)
    
    ;; (cavalieri_bloccano_percorso ?da - luogo ?a - luogo) - I cavalieri bloccano un sentiero specifico.
    (cavalieri_bloccano_percorso ?k - cavaliere ?da - luogo ?a - luogo)

    ;; (drago_a_guardia ?t - torre) - Il drago sta attivamente sorvegliando la torre.
    (drago_a_guardia ?d - drago ?t - torre)
    
    ;; (personaggio_salvato ?p - da_salvare) - Il personaggio da salvare è stato liberato dalla sua prigionia iniziale.
    (personaggio_salvato ?p - da_salvare)
    
    ;; (legame_stabilito ?p1 - personaggio ?p2 - personaggio) - Si è creato un legame affettivo tra due personaggi.
    (legame_stabilito ?p1 - personaggio ?p2 - personaggio)

    ;; (missione_completata) - Predicato-flag per l'obiettivo finale.
    (missione_completata)
  )

  ;; --- AZIONI ---

  (:action viaggiare
    :parameters (?p - personaggio ?da - luogo ?a - luogo)
    :precondition (and
      (is_mobile ?p) ; Il personaggio deve essere in grado di muoversi.
      (si_trova_a ?p ?da) ; Deve trovarsi nel punto di partenza.
      (collegato ?da ?a) ; Deve esistere un percorso.
      (not (exists (?k - cavaliere) (cavalieri_bloccano_percorso ?k ?da ?a))) ; Il percorso non deve essere bloccato dai cavalieri.
    )
    :effect (and
      (not (si_trova_a ?p ?da))
      (si_trova_a ?p ?a)
    )
  )

  (:action stringere_accordo
    :parameters (?s - salvatore ?m - mandante ?l - luogo)
    :precondition (and
      (si_trova_a ?s ?l) ; Il salvatore deve essere dal mandante.
      (si_trova_a ?m ?l) ; Il mandante deve essere lì.
      (palude_occupata) ; L'accordo ha senso solo se c'è un problema da risolvere.
    )
    :effect (and
      (accordo_stretto ?m ?s)
    )
  )

  (:action affrontare_cavalieri
    :parameters (?p - personaggio ?k - cavaliere ?l1 - luogo ?l2 - luogo)
    :precondition (and
      (si_trova_a ?p ?l1) ; Il personaggio deve essere all'inizio del percorso bloccato.
      (cavalieri_bloccano_percorso ?k ?l1 ?l2) ; Il percorso deve essere effettivamente bloccato.
    )
    :effect (and
      (not (cavalieri_bloccano_percorso ?k ?l1 ?l2)) ; I cavalieri non bloccano più il percorso.
    )
  )

  (:action neutralizzare_drago
    :parameters (?p - personaggio ?d - drago ?t - torre)
    :precondition (and
      (si_trova_a ?p ?t) ; Un personaggio deve essere nella torre.
      (si_trova_a ?d ?t) ; Il drago deve essere nella torre.
      (drago_a_guardia ?d ?t) ; Il drago deve essere una minaccia attiva.
    )
    :effect (and
      (not (drago_a_guardia ?d ?t)) ; Il drago non è più una minaccia.
    )
  )
  
  (:action salvare_principessa
    :parameters (?s - salvatore ?p - da_salvare ?t - torre ?m - mandante)
    :precondition (and
      (si_trova_a ?s ?t) ; Il salvatore deve essere nella torre.
      (si_trova_a ?p ?t) ; La principessa deve essere nella torre.
      (accordo_stretto ?m ?s) ; Deve esserci un accordo ufficiale per salvarla.
      (not (exists (?d - drago) (drago_a_guardia ?d ?t))) ; Il drago non deve più essere una minaccia.
    )
    :effect (and
      (personaggio_salvato ?p)
      (is_mobile ?p) ; EFFETTO CHIAVE: La principessa ora può muoversi da sola.
    )
  )

  (:action sviluppare_legame
    :parameters (?p1 - personaggio ?p2 - da_salvare ?l - luogo)
    :precondition (and
      (si_trova_a ?p1 ?l)
      (si_trova_a ?p2 ?l)
      (personaggio_salvato ?p2) ; Il legame si può sviluppare solo dopo il salvataggio.
    )
    :effect (and
      (legame_stabilito ?p1 ?p2)
    )
  )

  (:action completare_missione
    :parameters (?s - salvatore ?p - da_salvare ?m - mandante ?l_consegna - castello)
    :precondition (and
      (si_trova_a ?s ?l_consegna) ; Il salvatore è nel luogo di consegna.
      (si_trova_a ?p ?l_consegna) ; La persona salvata è nel luogo di consegna.
      (si_trova_a ?m ?l_consegna) ; Il mandante è nel luogo di consegna.
      (accordo_stretto ?m ?s) ; C'era un accordo.
      (personaggio_salvato ?p) ; La persona è stata effettivamente salvata.
    )
    :effect (and
      (not (palude_occupata))
      (missione_completata)
    )
  )
)