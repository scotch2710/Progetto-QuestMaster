(define (domain shrek_quest)
  (:requirements :strips :typing)

  ;; Tipi di entità nel mondo, con una gerarchia di ruoli specifica.
  ;; Il tipo più generico (es. luogo) è posto dopo i suoi sotto-tipi.
  (:types
    torre - luogo
    castello - luogo
    palude - luogo
    foresta - luogo
    luogo                 ; Tipo generico per tutte le location

    salvatore - personaggio
    aiutante - personaggio
    da_salvare - personaggio
    mandante - personaggio
    personaggio           ; Tipo generico per tutti i personaggi

    drago - ostacolo
    cavaliere - ostacolo
    ostacolo              ; Tipo generico per tutte le minacce
  )

  ;; Predicati: descrivono le proprietà e le relazioni che possono cambiare.
  (:predicates
    (si_trova_a ?obj - object ?l - luogo)            ; Indica la posizione di un oggetto o personaggio.
    (connesso ?da - luogo ?a - luogo)               ; Indica che c'è un percorso diretto tra due luoghi.
    (palude_disturbata)                             ; Fatto che rappresenta il problema iniziale di Shrek.
    (accordo_stretto ?s - salvatore ?m - mandante)  ; Fatto che indica che la quest è stata accettata.
    (ostacolo_presente ?o - ostacolo ?l - luogo)    ; Un ostacolo si trova in un determinato luogo.
    (ostacolo_sconfitto ?o - ostacolo)              ; L'ostacolo è stato superato.
    (imprigionato ?p - da_salvare ?l - torre)       ; Il personaggio da salvare è prigioniero in una torre.
    (salvato ?p - da_salvare)                       ; Il personaggio è stato liberato.
    (in_compagnia ?p1 - personaggio ?p2 - personaggio) ; Indica che due personaggi viaggiano insieme.
    (missione_completata)                           ; Fatto che rappresenta il raggiungimento del goal finale.
  )

  ;; Azione per spostarsi da un luogo all'altro.
  (:action viaggiare
    :parameters (?p - personaggio ?da - luogo ?a - luogo)
    :precondition (and
      (si_trova_a ?p ?da)          ; Il personaggio deve essere nel luogo di partenza.
      (connesso ?da ?a)            ; Deve esistere un percorso.
    )
    :effect (and
      (not (si_trova_a ?p ?da))    ; Rimuove la vecchia posizione.
      (si_trova_a ?p ?a)           ; Aggiunge la nuova posizione.
    )
  )

  ;; Azione per spostare un gruppo di due personaggi. Essenziale per la fase di scorta.
  (:action viaggiare_in_compagnia
    :parameters (?p1 - personaggio ?p2 - personaggio ?da - luogo ?a - luogo)
    :precondition (and
      (in_compagnia ?p1 ?p2)       ; I due personaggi devono essere in un gruppo.
      (si_trova_a ?p1 ?da)         ; Entrambi devono essere nel luogo di partenza.
      (si_trova_a ?p2 ?da)
      (connesso ?da ?a)            ; Il percorso deve esistere.
    )
    :effect (and
      (not (si_trova_a ?p1 ?da))
      (si_trova_a ?p1 ?a)
      (not (si_trova_a ?p2 ?da))
      (si_trova_a ?p2 ?a)
    )
  )
  
  ;; Azione per iniziare formalmente la quest.
  (:action stringere_accordo
    :parameters (?s - salvatore ?m - mandante ?l - castello)
    :precondition (and
      (si_trova_a ?s ?l)           ; Il salvatore deve essere dal mandante.
      (si_trova_a ?m ?l)
      (palude_disturbata)          ; Ci deve essere una motivazione per l'accordo.
    )
    :effect (and
      (accordo_stretto ?s ?m)      ; L'accordo viene siglato.
    )
  )
  
  ;; Azione per superare un ostacolo, richiede la cooperazione del salvatore e dell'aiutante.
  (:action affrontare_ostacolo
    :parameters (?s - salvatore ?a - aiutante ?o - ostacolo ?l - luogo)
    :precondition (and
      (si_trova_a ?s ?l)           ; L'eroe e il suo aiutante devono essere dove si trova l'ostacolo.
      (si_trova_a ?a ?l)
      (ostacolo_presente ?o ?l)    ; L'ostacolo deve essere effettivamente lì.
      (not (ostacolo_sconfitto ?o)); L'ostacolo non deve essere già stato sconfitto.
    )
    :effect (and
      (not (ostacolo_presente ?o ?l)); L'ostacolo viene rimosso dal luogo.
      (ostacolo_sconfitto ?o)      ; Viene registrato come sconfitto.
    )
  )

  ;; Azione per liberare il personaggio da salvare.
  (:action salvare_principessa
    :parameters (?s - salvatore ?ds - da_salvare ?drago - drago ?t - torre ?m - mandante)
    :precondition (and
      (accordo_stretto ?s ?m)      ; La quest deve essere attiva.
      (si_trova_a ?s ?t)           ; Il salvatore deve essere nella torre.
      (imprigionato ?ds ?t)        ; La principessa deve essere imprigionata lì.
      (ostacolo_sconfitto ?drago)  ; Il drago guardiano deve essere stato sconfitto.
    )
    :effect (and
      (not (imprigionato ?ds ?t))  ; Non è più imprigionata.
      (salvato ?ds)                ; È ufficialmente "salvata".
      (si_trova_a ?ds ?t)          ; Ora è un personaggio libero nella torre.
      (in_compagnia ?s ?ds)        ; Inizia la fase di scorta.
    )
  )

  ;; Azione per consegnare il personaggio salvato e ottenere la ricompensa.
  (:action consegnare_principessa
    :parameters (?s - salvatore ?ds - da_salvare ?m - mandante ?c - castello)
    :precondition (and
      (accordo_stretto ?s ?m)
      (salvato ?ds)                ; Deve essere stata salvata.
      (in_compagnia ?s ?ds)        ; Deve essere in compagnia del salvatore.
      (si_trova_a ?s ?c)           ; Tutti e tre devono trovarsi nel castello del mandante.
      (si_trova_a ?ds ?c)
      (si_trova_a ?m ?c)
    )
    :effect (and
      (not (palude_disturbata))    ; La palude viene "ripulita", risolvendo il problema iniziale.
      (not (in_compagnia ?s ?ds))  ; La scorta finisce.
    )
  )

  ;; Azione finale che porta al goal, possibile solo dopo aver riottenuto la palude.
  (:action completare_missione
    :parameters (?s - salvatore ?p - palude)
    :precondition (and
      (not (palude_disturbata))    ; La ricompensa deve essere stata ottenuta.
      (si_trova_a ?s ?p)           ; L'eroe deve essere tornato a casa.
    )
    :effect (and
      (missione_completata)        ; La missione è completata.
    )
  )
)