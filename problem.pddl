(define (problem cavaliere_e_principessa_problema)
  (:domain cavaliere_e_principessa)
  (:objects
    lancillotto - cavaliere
    francescaDR - principessa
    mostro_malvagio - mostro
    
    fortezza bosco sushi - luogo
    excalibur - spada
  )
  (:init
    (si_trova_a lancillotto bosco)
    (si_trova_a francescaDR fortezza)
    (si_trova_a mostro_malvagio fortezza)
    (si_trova_a excalibur bosco)
    (mostro_presente fortezza)
    (is_mobile lancillotto)
  )
  (:goal (and (missione_completata)))
)