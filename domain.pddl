(define (domain shrek_avventura)
  (:requirements :strips :typing :equality)

  ; Tipi di entità con una gerarchia chiara per i ruoli
  (:types
    ponte - luogo
    luogo

    salvatore - personaggio
    distrattore - personaggio
    da_salvare - personaggio
    personaggio
    
    oggetto
    drago
  )

  ; Proprietà e relazioni che descrivono lo stato del mondo
  (:predicates
    (si_trova_a ?p - object ?l - luogo)
    (ha_con_se ?p - personaggio ?o - oggetto)
    (is_key_for ?o - oggetto ?l - luogo)
    (drago_presente ?l - luogo)
    (drago_distratto)
    (fiona_liberata)
    (porta_chiusa ?l - luogo)
    (missione_completata)
    (is_mobile ?p - personaggio) ; -- MODIFICA CHIAVE: Aggiunto nuovo predicato
  )

  ; Azione: Viaggiare da un luogo all'altro
  (:action viaggiare
    :parameters (?p - personaggio ?da - luogo ?a - luogo)
    :precondition (and 
        (si_trova_a ?p ?da)
        (is_mobile ?p) ; -- MODIFICA CHIAVE: Per viaggiare, un personaggio deve essere mobile
    )
    :effect (and (not (si_trova_a ?p ?da)) (si_trova_a ?p ?a))
  )

  ; Azione per raccogliere un oggetto, può farlo solo il salvatore
  (:action raccogliere_oggetto
    :parameters (?p - salvatore ?o - oggetto ?l - luogo)
    :precondition (and (si_trova_a ?p ?l) (si_trova_a ?o ?l))
    :effect (and (ha_con_se ?p ?o) (not (si_trova_a ?o ?l)))
  )

  ; Azione per aprire una porta, può farlo solo il salvatore
  (:action aprire_porta
      :parameters (?p - salvatore ?k - oggetto ?l - luogo)
      :precondition (and (si_trova_a ?p ?l) (porta_chiusa ?l) (ha_con_se ?p ?k) (is_key_for ?k ?l))
      :effect (and (not (porta_chiusa ?l)))
  )

  ; Azione: Distrarre il drago, può farlo solo il distrattore
  (:action distrarre_drago
    :parameters (?d - distrattore ?l - luogo)
    :precondition (and (si_trova_a ?d ?l) (drago_presente ?l))
    :effect (and (drago_distratto))
  )

  ; Azione: Salvare il personaggio, richiede un salvatore e un da_salvare
  (:action salvare_personaggio
    :parameters (?s - salvatore ?ds - da_salvare ?l - luogo)
    :precondition (and (si_trova_a ?s ?l) (si_trova_a ?ds ?l) (drago_distratto) (not (porta_chiusa ?l)))
    :effect (and (fiona_liberata))
  )

  ; Azione: Completare la missione, può farlo solo il salvatore
  (:action completare_missione
    :parameters (?eroe - salvatore)
    :precondition (and (fiona_liberata))
    :effect (and (missione_completata))
  )
)
