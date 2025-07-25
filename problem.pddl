(define (problem avventura_sushi)
  (:domain cavaliere_e_principessa)
  (:objects
    cavaliere principessa - personaggio
    castello sushi_bar - luogo
    drago - nemico
  )
  (:init
    (si_trova_a cavaliere castello)
    (si_trova_a principessa castello)
    (presente drago castello)
  )
  (:goal (and (mangia_sushi cavaliere) (mangia_sushi principessa)))
)