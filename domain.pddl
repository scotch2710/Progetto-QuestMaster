(define (domain avventura_orco_corretto)
  (:requirements :strips :typing)

  ; Tipi di entità nel mondo, con una gerarchia per i ruoli.
  ; Un 'salvatore' è un tipo di 'personaggio', quindi può fare tutto ciò che fa un personaggio, più le sue azioni speciali.
  (:types
    luogo                 ; Tipo base per tutte le location.

    salvatore - personaggio ; L'eroe principale della missione (es. Shrek).
    compagno - personaggio  ; L'aiutante dell'eroe, cruciale per certi compiti (es. Ciuchino).
    da_salvare - personaggio; La persona da salvare (es. Fiona).
    governante - personaggio; Colui che assegna la missione (es. Farquaad).
    personaggio           ; Tipo base per tutti gli esseri senzienti.

    guardiano             ; Un'entità non-personaggio che sorveglia un luogo (es. Drago).
  )

  ; Predicati: descrivono lo stato del mondo che può cambiare.
  (:predicates
    ; --- Predicati di Posizione e Connettività ---
    (si_trova_a ?p - object ?l - luogo)         ; Indica che un oggetto (personaggio o guardiano) si trova in un luogo.
    (connessi ?da - luogo ?a - luogo)         ; Indica che esiste un percorso diretto tra due luoghi.

    ; --- Predicati di Stato della Missione ---
    (creature_nella_palude)                     ; Lo stato iniziale del problema: la palude è invasa.
    (missione_proposta ?g - governante ?s - salvatore) ; Il governante ha proposto la missione al salvatore.
    (missione_accettata ?s - salvatore)         ; Il salvatore ha accettato la missione.
    (guardiano_neutralizzato ?g - guardiano)    ; Il guardiano è stato eluso o sconfitto.
    (personaggio_salvato ?p - da_salvare)       ; Il personaggio da salvare è stato liberato dalla sua prigionia.
    (personaggio_consegnato ?p - da_salvare)    ; Il personaggio salvato è stato consegnato al governante.
  )

  ; Azione: un personaggio viaggia da solo.
  (:action viaggiare_da_soli
    :parameters (?p - personaggio ?da - luogo ?a - luogo)
    :precondition (and
      (si_trova_a ?p ?da)     ; Il personaggio deve essere nel luogo di partenza.
      (connessi ?da ?a)       ; Ci deve essere un percorso.
    )
    :effect (and
      (not (si_trova_a ?p ?da)) ; Non è più nel luogo di partenza.
      (si_trova_a ?p ?a)        ; Ora è nel luogo di arrivo.
    )
  )

  ; Azione: Il salvatore negozia con il governante per ottenere la missione.
  (:action negoziare_missione
    :parameters (?s - salvatore ?g - governante ?l - luogo)
    :precondition (and
      (si_trova_a ?s ?l)      ; Il salvatore deve essere nello stesso luogo del governante.
      (si_trova_a ?g ?l)
      (creature_nella_palude) ; La negoziazione avviene solo se c'è il problema della palude.
    )
    :effect (and
      (missione_proposta ?g ?s) ; L'effetto è che la missione viene ufficialmente proposta.
    )
  )

  ; Azione: Il salvatore accetta la missione.
  (:action accettare_missione
    :parameters (?s - salvatore ?g - governante)
    :precondition (and
      (missione_proposta ?g ?s) ; La missione deve essere stata proposta per poterla accettare.
    )
    :effect (and
      (missione_accettata ?s)     ; L'effetto è che la missione è ora attiva.
    )
  )

  ; Azione: Neutralizzare il guardiano.
  ; **MODIFICA CHIAVE**: Questa azione ora richiede la presenza sia del salvatore che del compagno.
  ; Questo rende il ruolo del compagno (Ciuchino) indispensabile per il progresso della missione.
  (:action neutralizzare_guardiano
    :parameters (?s - salvatore ?c - compagno ?g - guardiano ?l - luogo)
    :precondition (and
      (missione_accettata ?s)    ; Si può affrontare il guardiano solo dopo aver accettato la missione.
      (si_trova_a ?s ?l)         ; Il salvatore deve essere sul posto.
      (si_trova_a ?c ?l)         ; ANCHE il compagno deve essere sul posto.
      (si_trova_a ?g ?l)         ; Il guardiano deve essere presente.
    )
    :effect (and
      (guardiano_neutralizzato ?g) ; Il guardiano non è più una minaccia.
    )
  )

  ; Azione: Il salvatore libera il personaggio da salvare.
  (:action salvare_personaggio
    :parameters (?s - salvatore ?p - da_salvare ?g - guardiano ?l - luogo)
    :precondition (and
      (si_trova_a ?s ?l)             ; Il salvatore è nella torre.
      (si_trova_a ?p ?l)             ; Il personaggio da salvare è nella torre.
      (guardiano_neutralizzato ?g)   ; Il guardiano deve essere stato neutralizzato per procedere.
    )
    :effect (and
      (personaggio_salvato ?p)     ; Il personaggio è ora ufficialmente "salvato" e può muoversi.
    )
  )

  ; Azione: Il salvatore scorta il personaggio salvato.
  ; **NUOVA AZIONE**: Questa azione modella il viaggio di ritorno del gruppo, muovendo due personaggi contemporaneamente.
  ; Impedisce che il personaggio appena salvato viaggi da solo.
  (:action scortare_personaggio
      :parameters (?s - personaggio ?p - da_salvare ?da - luogo ?a - luogo)
      :precondition (and
          (personaggio_salvato ?p)   ; Solo un personaggio salvato può essere scortato.
          (si_trova_a ?s ?da)        ; L'accompagnatore è nel punto di partenza.
          (si_trova_a ?p ?da)        ; Il personaggio da salvare è nello stesso punto.
          (connessi ?da ?a)          ; C'è un percorso.
      )
      :effect (and
          (not (si_trova_a ?s ?da))
          (si_trova_a ?s ?a)
          (not (si_trova_a ?p ?da))
          (si_trova_a ?p ?a)
      )
  )

  ; Azione: Consegnare il personaggio salvato al governante.
  (:action consegnare_personaggio
    :parameters (?s - salvatore ?p - da_salvare ?g - governante ?l - luogo)
    :precondition (and
      (personaggio_salvato ?p)  ; Deve essere stato salvato per essere consegnato.
      (si_trova_a ?s ?l)        ; Tutti e tre devono essere nello stesso luogo per la consegna.
      (si_trova_a ?p ?l)
      (si_trova_a ?g ?l)
    )
    :effect (and
      (not (personaggio_salvato ?p)) ; Non è più nello stato "salvato da consegnare".
      (personaggio_consegnato ?p)    ; Ora è ufficialmente "consegnato".
    )
  )

  ; Azione: Il salvatore reclama la sua ricompensa (la palude libera).
  (:action reclamare_ricompensa
    :parameters (?s - salvatore ?p - da_salvare ?g - governante)
    :precondition (and
      (personaggio_consegnato ?p) ; La ricompensa si ottiene solo dopo la consegna.
    )
    :effect (and
      (not (creature_nella_palude)) ; La palude viene liberata, risolvendo il problema iniziale.
    )
  )
)