(define (domain shrek_duloc_quest)
  (:requirements :strips :typing)

  ; --- TIPI ---
  ; Gerarchia di tipi per entità, luoghi e ruoli.
  ; NOTA SULLA SINTASSI: Per evitare errori di ricorsione, i tipi generici (es. personaggio, luogo)
  ; sono dichiarati DOPO i loro sottotipi specifici.
  (:types
    salvatore - personaggio
    accompagnatore - personaggio
    da_salvare - personaggio
    mandante - personaggio
    personaggio ; Tipo generico per tutte le figure umanoidi

    palude - luogo
    torre - luogo
    castello - luogo
    territorio_pericoloso - luogo
    luogo ; Tipo generico per tutte le location

    guardiano ; Tipo per l'ostacolo principale (il drago)
  )

  ; --- PREDICATI ---
  ; Definiscono le proprietà e le relazioni che descrivono lo stato del mondo.
  (:predicates
    (si_trova_a ?obj - object ?loc - luogo)           ; Indica che un oggetto/personaggio si trova in un luogo.
    (connessi ?da - luogo ?a - luogo)                ; Indica che c'è un percorso diretto tra due luoghi.
    (palude_occupata ?l - palude)                    ; Vero se la palude è occupata da creature magiche.
    (prigioniera_in ?p - da_salvare ?t - torre)      ; Vero se la principessa è prigioniera nella torre.
    (fa_la_guardia ?g - guardiano ?t - torre)        ; Vero se il guardiano sorveglia la torre.
    (drago_neutralizzato ?g - guardiano)             ; Vero dopo che il drago è stato sconfitto o eluso.
    (segue ?follower - da_salvare ?leader - salvatore) ; Vero se la principessa sta seguendo il suo salvatore.
    (accordo_stretto ?s - salvatore ?m - mandante)   ; Vero se l'accordo tra Shrek e Farquaad è attivo.
    (missione_completata)                            ; Predicato-obiettivo, vero quando la quest è finita.
  )

  ; --- AZIONI ---

  ; Azione: Un singolo personaggio viaggia tra due luoghi connessi.
  (:action viaggiare
    :parameters (?p - personaggio ?da - luogo ?a - luogo)
    :precondition (and
      (si_trova_a ?p ?da)
      (connessi ?da ?a)
    )
    :effect (and
      (not (si_trova_a ?p ?da))
      (si_trova_a ?p ?a)
    )
  )

  ; Azione: Il salvatore e il suo accompagnatore neutralizzano il guardiano della torre.
  (:action neutralizzare_drago
    :parameters (?s - salvatore ?c - accompagnatore ?g - guardiano ?t - torre)
    :precondition (and
      (si_trova_a ?s ?t)
      (si_trova_a ?c ?t)
      (fa_la_guardia ?g ?t)
    )
    :effect (and
      (not (fa_la_guardia ?g ?t))
      (drago_neutralizzato ?g)
    )
  )

  ; Azione: Il salvatore libera la principessa dalla torre dopo aver neutralizzato il guardiano.
  (:action salvare_principessa
    :parameters (?s - salvatore ?ds - da_salvare ?g - guardiano ?t - torre)
    :precondition (and
      (si_trova_a ?s ?t)
      (prigioniera_in ?ds ?t)
      (drago_neutralizzato ?g)
    )
    :effect (and
      (not (prigioniera_in ?ds ?t))
      (segue ?ds ?s) ; Effetto chiave: la principessa ora segue il salvatore.
    )
  )

  ; Azione: Il salvatore scorta la principessa che lo segue in un nuovo luogo.
  (:action scortare
    :parameters (?s - salvatore ?ds - da_salvare ?da - luogo ?a - luogo)
    :precondition (and
      (si_trova_a ?s ?da)
      (si_trova_a ?ds ?da) ; Devono essere nello stesso posto per partire insieme.
      (segue ?ds ?s)       ; Lei deve stare seguendo lui.
      (connessi ?da ?a)
    )
    :effect (and
      (not (si_trova_a ?s ?da))
      (not (si_trova_a ?ds ?da))
      (si_trova_a ?s ?a)
      (si_trova_a ?ds ?a)
    )
  )

  ; Azione: Il salvatore consegna la principessa al mandante nel suo castello, adempiendo all'accordo.
  (:action completare_accordo
    :parameters (?s - salvatore ?ds - da_salvare ?m - mandante ?p - palude ?c - castello)
    :precondition (and
      (si_trova_a ?s ?c)
      (si_trova_a ?ds ?c)
      (si_trova_a ?m ?c) ; Il mandante deve essere nel suo castello per ricevere la principessa.
      (segue ?ds ?s)
      (accordo_stretto ?s ?m)
      (palude_occupata ?p)
    )
    :effect (and
      (not (segue ?ds ?s))
      (not (palude_occupata ?p)) ; Effetto chiave: la palude viene liberata.
    )
  )

  ; Azione: Il salvatore, tornato nella sua palude ormai libera, completa la sua missione.
  (:action tornare_in_pace
    :parameters (?s - salvatore ?p - palude)
    :precondition (and
      (si_trova_a ?s ?p)
      (not (palude_occupata ?p))
    )
    :effect (and
      (missione_completata)
    )
  )
)