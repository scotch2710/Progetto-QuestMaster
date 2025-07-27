(define (domain shrek-quest)
  (:requirements :strips :typing)

  ; --- TIPI ---
  ; Definisce le categorie di entità nel mondo. La gerarchia (es. salvatore - personaggio)
  ; permette di creare azioni specifiche per ruoli specifici.
  (:types
    torre - luogo      ; Un tipo speciale di luogo dove qualcuno è imprigionato.
    castello - luogo   ; Un tipo speciale di luogo dove risiede un mandante.
    luogo              ; Tipo base per tutte le location.

    salvatore - personaggio ; Il protagonista che esegue la quest.
    compagno - personaggio    ; Un aiutante che può eseguire azioni specifiche (es. distrarre).
    da_salvare - personaggio  ; La persona che deve essere salvata.
    mandante - personaggio    ; Chi assegna la quest e fornisce la ricompensa.
    personaggio        ; Tipo base per tutti gli esseri senzienti che possono agire.

    guardiano          ; Un'entità non giocante che sorveglia un luogo, come un drago.
  )

  ; --- PREDICATI ---
  ; Definisce le proprietà e le relazioni che possono essere vere o false, descrivendo lo stato del mondo.
  (:predicates
    ; Posizione e relazioni tra entità
    (si_trova_a ?p - personaggio ?l - luogo)
    (guardiano_in ?g - guardiano ?l - luogo)
    (prigioniero_in ?p - da_salvare ?l - torre)
    (viaggia_con ?p1 - personaggio ?p2 - personaggio)

    ; Stati del mondo e della quest
    (palude_invasa)                           ; Condizione iniziale che motiva la quest.
    (accordo_stretto ?s - salvatore ?m - mandante) ; L'accordo tra eroe e mandante è stato fatto.
    (guardiano_sconfitto ?g - guardiano)      ; Il guardiano è stato neutralizzato.
    (cavalieri_presenti ?l - luogo)           ; Un luogo è presidiato da ostacoli (cavalieri).
    (cavalieri_sconfitti_a ?l - luogo)        ; Gli ostacoli in un luogo sono stati superati.
    (missione_completata)                     ; Predicato che definisce il raggiungimento dell'obiettivo.
    
    ; Stati opzionali/narrativi
    (conosce_segreto ?p1 - personaggio ?p2 - da_salvare)
    (legame_affettivo ?p1 - personaggio ?p2 - personaggio)
  )

  ; --- AZIONI ---

  ; Azione per il salvatore per andare dal mandante e negoziare.
  (:action recarsi_dal_mandante
    :parameters (?s - salvatore ?m - mandante ?l_partenza - luogo ?l_destinazione - castello)
    :precondition (and
      (palude_invasa)                        ; C'è una motivazione per andare.
      (si_trova_a ?s ?l_partenza)            ; Il salvatore deve essere nel suo luogo di partenza.
      (si_trova_a ?m ?l_destinazione)        ; Il mandante deve essere nel suo castello.
      (not (= ?l_partenza ?l_destinazione))  ; Non può già essere lì.
    )
    :effect (and
      (not (si_trova_a ?s ?l_partenza))
      (si_trova_a ?s ?l_destinazione)
    )
  )

  ; Azione per formalizzare l'accordo che dà il via alla missione di salvataggio.
  (:action stringere_accordo
    :parameters (?s - salvatore ?m - mandante ?l - castello)
    :precondition (and
      (si_trova_a ?s ?l) ; Devono essere nello stesso luogo.
      (si_trova_a ?m ?l)
      (palude_invasa)    ; L'accordo si basa sulla risoluzione di questo problema.
    )
    :effect (and
      (accordo_stretto ?s ?m) ; L'accordo è ora attivo.
    )
  )

  ; Azione di viaggio generica per un personaggio (e il suo compagno, se presente).
  (:action viaggiare
    :parameters (?s - salvatore ?c - compagno ?da - luogo ?a - luogo)
    :precondition (and
        (exists (?m - mandante) (accordo_stretto ?s ?m)) ; Può viaggiare per la quest solo dopo l'accordo.
        (si_trova_a ?s ?da)
        (si_trova_a ?c ?da) ; Il compagno viaggia con il protagonista.
        (not (cavalieri_presenti ?a)) ; Non si può entrare in un luogo presidiato senza prima sconfiggere i cavalieri.
    )
    :effect (and
        (not (si_trova_a ?s ?da))
        (si_trova_a ?s ?a)
        (not (si_trova_a ?c ?da))
        (si_trova_a ?c ?a)
    )
  )

  ; Azione per superare l'ostacolo dei cavalieri in un luogo.
  (:action sconfiggere_cavalieri
    :parameters (?s - salvatore ?l - luogo)
    :precondition (and
      (si_trova_a ?s ?l)
      (cavalieri_presenti ?l)
    )
    :effect (and
      (not (cavalieri_presenti ?l))
      (cavalieri_sconfitti_a ?l) ; Il luogo è ora sicuro.
    )
  )
  
  ; Azione per neutralizzare il guardiano, richiede la cooperazione del compagno.
  (:action eludere_o_sconfiggere_guardiano
    :parameters (?s - salvatore ?c - compagno ?g - guardiano ?l - torre)
    :precondition (and
      (si_trova_a ?s ?l)
      (si_trova_a ?c ?l) ; Salvatore e compagno devono essere presenti.
      (guardiano_in ?g ?l)
      (not (guardiano_sconfitto ?g))
    )
    :effect (and
      (guardiano_sconfitto ?g)
    )
  )

  ; Azione per liberare il prigioniero una volta superati gli ostacoli nella torre.
  (:action salvare_prigioniero
    :parameters (?s - salvatore ?ds - da_salvare ?g - guardiano ?l - torre)
    :precondition (and
      (si_trova_a ?s ?l)
      (prigioniero_in ?ds ?l)
      (guardiano_sconfitto ?g) ; Il guardiano non deve più essere una minaccia.
    )
    :effect (and
      (not (prigioniero_in ?ds ?l))
      (viaggia_con ?s ?ds) ; Ora viaggiano insieme.
      (si_trova_a ?ds ?l)  ; La persona salvata è ora "libera" nella torre.
    )
  )

  ; Azione per viaggiare insieme al personaggio salvato.
  (:action viaggiare_in_coppia
    :parameters (?s - salvatore ?ds - da_salvare ?c - compagno ?da - luogo ?a - luogo)
    :precondition (and
      (viaggia_con ?s ?ds) ; Devono essere in "modalità viaggio di coppia".
      (si_trova_a ?s ?da)
      (si_trova_a ?ds ?da)
      (si_trova_a ?c ?da) ; Anche il compagno segue.
      (or (not (cavalieri_presenti ?a)) (cavalieri_sconfitti_a ?a)) ; Il percorso deve essere sicuro.
    )
    :effect (and
      (not (si_trova_a ?s ?da))
      (not (si_trova_a ?ds ?da))
      (not (si_trova_a ?c ?da))
      (si_trova_a ?s ?a)
      (si_trova_a ?ds ?a)
      (si_trova_a ?c ?a)
    )
  )
  
  ; Azione narrativa opzionale per sviluppare la relazione.
  (:action scoprire_segreto
    :parameters (?s - salvatore ?ds - da_salvare)
    :precondition (and
      (viaggia_con ?s ?ds) ; Avviene durante il viaggio di ritorno.
    )
    :effect (and
      (conosce_segreto ?s ?ds)
      (legame_affettivo ?s ?ds) ; La conoscenza del segreto crea un legame.
    )
  )

  ; Azione finale: consegnare la persona salvata per completare la missione e ottenere la ricompensa.
  (:action consegnare_e_reclamare_palude
    :parameters (?s - salvatore ?ds - da_salvare ?m - mandante ?l - castello)
    :precondition (and
      (si_trova_a ?s ?l)
      (si_trova_a ?ds ?l) ; Salvatore e salvato devono essere arrivati a destinazione.
      (si_trova_a ?m ?l)  ; Il mandante deve essere lì per verificare.
      (accordo_stretto ?s ?m)
    )
    :effect (and
      (not (palude_invasa)) ; La palude viene liberata come ricompensa.
      (missione_completata)
    )
  )
)