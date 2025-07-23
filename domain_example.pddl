; Definizione del mondo del cavaliere, delle sue regole e azioni possibili
(define (domain cavaliere-epico)
  (:requirements :strips :typing)

  ; Tipi di entità che esistono in questo mondo
  (:types
    
    cavaliere drago - personaggio
    citta
    arma
    mezzo_trasporto
  )

  ; Proprietà e relazioni che descrivono lo stato del mondo
  (:predicates
    (si-trova-a ?p - personaggio ?c - citta)
    (ha-con-se ?cav - cavaliere ?a - arma)
    (ha-cavallo ?cav - cavaliere ?m - mezzo_trasporto)
    (percorso ?da - citta ?a - citta)
    (drago-vivo ?d - drago)
    (citta-conquistata ?c - citta)
  )

  ; Azione: Viaggiare da una città all'altra
  (:action viaggiare
    :parameters (?cav - cavaliere ?m - mezzo_trasporto ?da - citta ?a - citta)
    :precondition (and
      (si-trova-a ?cav ?da)      ; Il cavaliere deve essere nella città di partenza
      (ha-cavallo ?cav ?m)      ; Deve avere un cavallo per viaggiare
      (percorso ?da ?a)         ; Deve esistere un percorso
    )
    :effect (and
      (not (si-trova-a ?cav ?da)) ; Non è più nella città di partenza
      (si-trova-a ?cav ?a)        ; Ora è nella città di arrivo
    )
  )

  ; Azione: Sconfiggere un drago con la spada
  (:action sconfiggere-drago
    :parameters (?cav - cavaliere ?d - drago ?spada - arma ?c - citta)
    :precondition (and
      (si-trova-a ?cav ?c)        ; Il cavaliere deve essere dove si trova il drago
      (si-trova-a ?d ?c)          ; Il drago deve essere nella stessa città
      (ha-con-se ?cav ?spada)     ; Il cavaliere deve avere la spada
      (drago-vivo ?d)             ; Il drago deve essere vivo per essere sconfitto
    )
    :effect (and
      (not (drago-vivo ?d))       ; Il drago non è più vivo
    )
  )

  ; Azione: Conquistare una città con l'arco
  (:action conquistare-citta
    :parameters (?cav - cavaliere ?arco - arma ?c - citta ?d - drago)
    :precondition (and
      (si-trova-a ?cav ?c)        ; Il cavaliere deve essere nella città da conquistare
      (ha-con-se ?cav ?arco)      ; Deve avere l'arco per la conquista
      (not (drago-vivo ?d))       ; L'ostacolo del drago deve essere stato superato
      (not (citta-conquistata ?c)) ; La città non deve essere già conquistata
    )
    :effect (and
      (citta-conquistata ?c)      ; La città è ora conquistata
    )
  )
)