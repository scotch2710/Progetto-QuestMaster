(define (domain shrek-chronicles)
  (:requirements :strips :typing)

  ; Tipi di entità con una gerarchia chiara per ruoli specifici.
  ; Il tipo generico (es. personaggio) è posto dopo quelli specifici.
  (:types
    salvatore - personaggio
    compagno - personaggio
    da_salvare - personaggio
    committente - personaggio
    personaggio

    drago
    
    oggetto_legale - oggetto
    oggetto
    
    luogo
  )

  ; Predicati che descrivono lo stato del mondo e le relazioni tra entità.
  (:predicates
    ; --- Predicati di Posizione ---
    (si_trova_a ?p - personaggio ?l - luogo)
    (drago_a_guardia ?d - drago ?l - luogo)

    ; --- Predicati di Possesso e Relazioni ---
    (possiede ?p - personaggio ?o - oggetto_legale)
    (atto_relativo_a ?o - oggetto_legale ?l - luogo)
    (luogo_natale ?p - personaggio ?l - luogo)

    ; --- Predicati di Stato (flag booleani per la progressione) ---
    (accordo_stipulato)
    (drago_neutralizzato ?d - drago)
    (principessa_salvata ?p - da_salvare)
    (principessa_consegnata ?p - da_salvare)
    (palude_riconquistata)
    
    ; --- MODIFICA CHIAVE: Predicati per gestire la logica di gruppo e i personaggi statici ---
    (compagni_di_viaggio ?p1 - personaggio ?p2 - personaggio) ; Indica se due personaggi viaggiano insieme
    (personaggio_fermo ?p - personaggio)                      ; Impedisce a un personaggio di muoversi (es. Farquaad)
  )

  ; Azione per formare il gruppo tra il salvatore e il compagno.
  (:action formare_gruppo
    :parameters (?s - salvatore ?c - compagno ?l - luogo)
    :precondition (and
      (si_trova_a ?s ?l)
      (si_trova_a ?c ?l)
      (not (compagni_di_viaggio ?s ?c))
    )
    :effect (and
      (compagni_di_viaggio ?s ?c)
    )
  )

  ; Azione di viaggio per il salvatore, PRIMA di trovare il suo compagno.
  (:action viaggiare_da_soli
    :parameters (?s - salvatore ?da - luogo ?a - luogo)
    :precondition (and
        (si_trova_a ?s ?da)
        (not (personaggio_fermo ?s))
        ; Condizione per assicurarsi che non abbia ancora un compagno
        (not (exists (?c - compagno) (compagni_di_viaggio ?s ?c)))
    )
    :effect (and
        (not (si_trova_a ?s ?da))
        (si_trova_a ?s ?a)
    )
  )

  ; Azione di viaggio per il gruppo (salvatore e compagno).
  (:action viaggiare_in_gruppo
    :parameters (?s - salvatore ?c - compagno ?da - luogo ?a - luogo)
    :precondition (and
        (compagni_di_viaggio ?s ?c)
        (si_trova_a ?s ?da)
        (si_trova_a ?c ?da)
    )
    :effect (and
        (not (si_trova_a ?s ?da))
        (si_trova_a ?s ?a)
        (not (si_trova_a ?c ?da))
        (si_trova_a ?c ?a)
    )
  )

  ; Azione per stipulare l'accordo. Può avvenire solo dove si trova il committente.
  (:action stipulare_accordo
    :parameters (?s - salvatore ?lord - committente ?doc - oggetto_legale ?l_accordo - luogo ?l_palude - luogo)
    :precondition (and
      (si_trova_a ?s ?l_accordo)           ; Il salvatore deve essere nel luogo dell'accordo.
      (si_trova_a ?lord ?l_accordo)        ; Il committente deve essere nello stesso luogo.
      (possiede ?lord ?doc)                ; Il committente deve possedere l'atto.
      (luogo_natale ?s ?l_palude)          ; Deve esserci un luogo natale per il salvatore.
      (atto_relativo_a ?doc ?l_palude)     ; L'atto deve essere relativo a quel luogo.
    )
    :effect (and (accordo_stipulato))
  )

  ; Azione del compagno per neutralizzare il drago, con l'aiuto del salvatore.
  (:action neutralizzare_drago
    :parameters (?c - compagno ?s - salvatore ?d - drago ?l_torre - luogo)
    :precondition (and
      (accordo_stipulato)
      (si_trova_a ?c ?l_torre)
      (si_trova_a ?s ?l_torre)
      (drago_a_guardia ?d ?l_torre)
      (not (drago_neutralizzato ?d))
    )
    :effect (and (drago_neutralizzato ?d))
  )

  ; Azione del salvatore per salvare la principessa.
  (:action salvare_principessa
    :parameters (?s - salvatore ?p - da_salvare ?d - drago ?l_torre - luogo)
    :precondition (and
      (accordo_stipulato)
      (si_trova_a ?s ?l_torre)
      (si_trova_a ?p ?l_torre)
      (drago_neutralizzato ?d)
    )
    :effect (and (principessa_salvata ?p))
  )

  ; Azione per scortare la principessa. L'intero gruppo viaggia insieme.
  (:action scortare_principessa
    :parameters (?s - salvatore ?p - da_salvare ?c - compagno ?da - luogo ?a - luogo)
    :precondition (and
        (principessa_salvata ?p)
        (compagni_di_viaggio ?s ?c)
        (si_trova_a ?s ?da)
        (si_trova_a ?p ?da)
        (si_trova_a ?c ?da)
    )
    :effect (and
        (not (si_trova_a ?s ?da))
        (si_trova_a ?s ?a)
        (not (si_trova_a ?p ?da))
        (si_trova_a ?p ?a)
        (not (si_trova_a ?c ?da))
        (si_trova_a ?c ?a)
    )
  )

  ; Azione per consegnare la principessa e completare l'accordo.
  (:action consegnare_principessa
    :parameters (?s - salvatore ?p - da_salvare ?lord - committente ?l - luogo)
    :precondition (and
      (principessa_salvata ?p)
      (si_trova_a ?s ?l)
      (si_trova_a ?p ?l)
      (si_trova_a ?lord ?l)
    )
    :effect (and (principessa_consegnata ?p))
  )

  ; Azione finale: il salvatore ottiene la proprietà del suo luogo natale.
  (:action riconquistare_palude
    :parameters (?s - salvatore ?lord - committente ?doc - oggetto_legale ?l_consegna - luogo)
    :precondition (and
      (exists (?p - da_salvare) (principessa_consegnata ?p))
      (accordo_stipulato)
      (si_trova_a ?s ?l_consegna)
      (si_trova_a ?lord ?l_consegna)
      (possiede ?lord ?doc)
    )
    :effect (and
      (palude_riconquistata)
      (not (possiede ?lord ?doc))
      (possiede ?s ?doc)
    )
  )
)