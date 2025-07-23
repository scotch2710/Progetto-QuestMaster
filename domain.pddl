(define (domain cavaliere_e_principessa)
  (:requirements :strips :typing :equality)

  (:types
    luogo
    fortezza - luogo
    bosco - luogo
    sushi - luogo

    cavaliere - personaggio
    mostro - personaggio
    principessa - personaggio
    personaggio

    oggetto
    spada - oggetto
  )

  (:predicates
    (si_trova_a ?p - object ?l - luogo)
    (ha_con_se ?p - personaggio ?o - oggetto)
    (mostro_presente ?l - luogo)
    (principessa_salvata)
    (missione_completata)
    (mostro_sconfitto)
    (is_mobile ?p - personaggio)
  )

  (:action viaggiare
    :parameters (?p - personaggio ?da - luogo ?a - luogo)
    :precondition (and (si_trova_a ?p ?da) (is_mobile ?p))
    :effect (and (not (si_trova_a ?p ?da)) (si_trova_a ?p ?a))
  )

  (:action combattere_mostro
    :parameters (?c - cavaliere ?m - mostro ?l - luogo)
    :precondition (and (si_trova_a ?c ?l) (si_trova_a ?m ?l) (mostro_presente ?l) (ha_con_se ?c spada))
    :effect (and (not (mostro_presente ?l)) (mostro_sconfitto))
  )

  (:action raccogliere_oggetto
    :parameters (?p - cavaliere ?o - oggetto ?l - luogo)
    :precondition (and (si_trova_a ?p ?l) (si_trova_a ?o ?l))
    :effect (and (ha_con_se ?p ?o) (not (si_trova_a ?o ?l)))
  )

  (:action salvare_principessa
    :parameters (?c - cavaliere ?pr - principessa ?l - luogo)
    :precondition (and (si_trova_a ?c ?l) (si_trova_a ?pr ?l) (mostro_sconfitto))
    :effect (and (principessa_salvata))
  )

  (:action completare_missione
    :parameters (?c - cavaliere)
    :precondition (and (principessa_salvata) (si_trova_a ?pr sushi))
    :effect (and (missione_completata))
  )
)