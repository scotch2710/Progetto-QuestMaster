(define (domain shrek-quest)
  (:requirements :strips :typing)

  ;; Tipi di entità con una gerarchia logica per definire i ruoli.
  ;; I tipi più specifici (es. 'torre') ereditano dal tipo più generico (es. 'luogo').
  (:types
    torre - luogo
    castello - luogo
    luogo

    salvatore - personaggio
    compagno - personaggio
    da_salvare - personaggio
    mandante - personaggio
    personaggio

    guardiano
  )

  ;; Predicati che descrivono lo stato del mondo. Ogni predicato rappresenta
  ;; una proprietà o una relazione che può essere vera o falsa.
  (:predicates
    (si_trova_a ?obj - object ?l - luogo)            ; Un oggetto (personaggio, guardiano) si trova in un luogo.
    (connessi ?da - luogo ?a - luogo)               ; Due luoghi sono connessi, permettendo il viaggio.
    (palude_invasa)                                 ; Lo stato iniziale della 'casa' del salvatore.
    (accordo_stipulato ?s - salvatore ?m - mandante)  ; Il salvatore ha un accordo con il mandante.
    (guardiano_presente ?g - guardiano ?l - luogo)    ; Un guardiano sorveglia un luogo.
    (guardiano_neutralizzato ?g - guardiano)          ; Il guardiano è stato sconfitto o eluso.
    (imprigionata ?ds - da_salvare ?l - torre)      ; La persona da salvare è prigioniera in una torre.
    (liberata ?ds - da_salvare)                     ; La persona è stata liberata.
    (segue_eroe ?ds - da_salvare ?s - salvatore)    ; La persona salvata ora segue il salvatore.
    (segreto_svelato ?ds - da_salvare)              ; Il segreto della persona salvata è stato rivelato.
    (missione_completata)                           ; Lo stato finale che rappresenta il raggiungimento dell'obiettivo.
  )

  ;; Azione: Il salvatore si reca dal mandante per stringere un patto.
  (:action stipulare_accordo
    :parameters (?s - salvatore ?m - mandante ?l - castello)
    :precondition (and
      (si_trova_a ?s ?l) ; Il salvatore deve essere nel castello del mandante.
      (si_trova_a ?m ?l) ; Anche il mandante deve essere lì.
      (palude_invasa)    ; L'accordo è motivato dall'invasione.
      (not (accordo_stipulato ?s ?m)) ; L'accordo non deve essere già stato fatto.
    )
    :effect (and
      (accordo_stipulato ?s ?m) ; L'effetto è che ora l'accordo esiste.
    )
  )

  ;; Azione: Un singolo personaggio si sposta tra due luoghi connessi.
  (:action viaggiare
    :parameters (?p - personaggio ?da - luogo ?a - luogo)
    :precondition (and
      (si_trova_a ?p ?da) ; Il personaggio deve essere nel luogo di partenza.
      (connessi ?da ?a)   ; I due luoghi devono essere direttamente collegati.
    )
    :effect (and
      (not (si_trova_a ?p ?da)) ; Il personaggio non è più nel luogo di partenza.
      (si_trova_a ?p ?a)        ; Il personaggio è ora nel luogo di arrivo.
    )
  )

  ;; Azione: Il salvatore e il suo compagno collaborano per neutralizzare il guardiano.
  (:action neutralizzare_guardiano
    :parameters (?s - salvatore ?c - compagno ?g - guardiano ?l - luogo)
    :precondition (and
      (si_trova_a ?s ?l) ; Il salvatore deve essere sul posto.
      (si_trova_a ?c ?l) ; Anche il compagno deve essere sul posto.
      (guardiano_presente ?g ?l) ; Il guardiano deve essere lì.
      (not (guardiano_neutralizzato ?g)) ; E non deve essere già stato neutralizzato.
    )
    :effect (and
      (guardiano_neutralizzato ?g) ; Il guardiano è ora neutralizzato.
    )
  )

  ;; Azione: Il salvatore libera la persona imprigionata.
  (:action salvare_persona
    :parameters (?s - salvatore ?ds - da_salvare ?g - guardiano ?t - torre)
    :precondition (and
      (si_trova_a ?s ?t) ; Il salvatore deve essere nella torre.
      (imprigionata ?ds ?t) ; La persona deve essere imprigionata in QUELLA torre.
      (guardiano_presente ?g ?t) ; Il guardiano di quella torre...
      (guardiano_neutralizzato ?g) ; ...deve essere stato neutralizzato.
    )
    :effect (and
      (not (imprigionata ?ds ?t)) ; Non è più imprigionata.
      (liberata ?ds)              ; È ufficialmente libera.
      (segue_eroe ?ds ?s)         ; Ora segue il suo salvatore.
      (si_trova_a ?ds ?t)         ; La sua posizione è ora esplicita e uguale a quella del salvatore.
    )
  )

  ;; Azione: Il salvatore e la persona salvata viaggiano insieme.
  (:action viaggiare_in_gruppo
    :parameters (?s - salvatore ?ds - da_salvare ?da - luogo ?a - luogo)
    :precondition (and
      (si_trova_a ?s ?da)       ; Il salvatore è nel luogo di partenza.
      (si_trova_a ?ds ?da)      ; Anche la persona salvata è lì.
      (segue_eroe ?ds ?s)     ; E sta seguendo il salvatore.
      (connessi ?da ?a)       ; I luoghi sono connessi.
    )
    :effect (and
      (not (si_trova_a ?s ?da))
      (si_trova_a ?s ?a)
      (not (si_trova_a ?ds ?da))
      (si_trova_a ?ds ?a)
    )
  )

  ;; Azione: La persona salvata rivela il suo segreto al salvatore durante il viaggio.
  (:action svelare_segreto
      :parameters (?s - salvatore ?ds - da_salvare)
      :precondition (and
          (segue_eroe ?ds ?s)            ; Può accadere solo dopo che si è creato un legame.
          (not (segreto_svelato ?ds))    ; Il segreto non deve essere già stato svelato.
      )
      :effect (and
          (segreto_svelato ?ds)         ; Ora il segreto è noto.
      )
  )

  ;; Azione: Il salvatore consegna la persona salvata al mandante per completare la missione.
  (:action completare_missione
    :parameters (?s - salvatore ?ds - da_salvare ?m - mandante ?l - castello)
    :precondition (and
      (si_trova_a ?s ?l) ; Il salvatore deve essere nel castello del mandante.
      (si_trova_a ?ds ?l) ; La persona salvata deve essere con lui.
      (si_trova_a ?m ?l) ; Il mandante deve essere presente per verificare.
      (liberata ?ds) ; La persona deve essere stata effettivamente liberata.
      (accordo_stipulato ?s ?m) ; Deve esistere un accordo da onorare.
    )
    :effect (and
      (not (palude_invasa)) ; La ricompensa: la palude non è più invasa.
      (missione_completata)   ; La missione è ufficialmente conclusa.
    )
  )
)