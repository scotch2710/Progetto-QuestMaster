(define (domain cavaliere_e_principessa)
  (:requirements :strips :typing :equality)
  (:types
    luogo
    personaggio
    nemico
  )
  (:predicates
    (si_trova_a ?x - personaggio ?l - luogo)
    (presente ?n - nemico ?l - luogo)
    (sconfitto ?n - nemico)
    (mangia_sushi ?p - personaggio)
  )
  (:action viaggia
    :parameters (?p - personaggio ?l1 - luogo ?l2 - luogo)
    :precondition (and (si_trova_a ?p ?l1) (or (not (presente ?n - nemico ?l1)) (sconfitto ?n))) ; Corretto: o non c'è nemico o è sconfitto
    :effect (and (not (si_trova_a ?p ?l1)) (si_trova_a ?p ?l2))
  )
  (:action combatti
    :parameters (?c - personaggio ?n - nemico ?l - luogo)
    :precondition (and (si_trova_a ?c ?l) (presente ?n ?l))
    :effect (and (not (presente ?n ?l)) (sconfitto ?n))
  )
  (:action mangia_sushi
    :parameters (?p - personaggio ?l - luogo)
    :precondition (si_trova_a ?p ?l)
    :effect (mangia_sushi ?p)
  )
)