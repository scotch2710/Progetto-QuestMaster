(define (problem shrek_reclaims_the_swamp)
  (:domain shrek_duloc_quest)

  ; --- OGGETTI ---
  ; Istanze specifiche di personaggi, luoghi e guardiani presenti in questa storia.
  (:objects
    shrek - salvatore
    ciuchino - accompagnatore
    fiona - da_salvare
    farquaad - mandante

    palude_di_shrek - palude
    foresta_perigliosa - territorio_pericoloso
    torre_del_drago - torre
    castello_di_duloc - castello

    draghessa - guardiano
  )

  ; --- STATO INIZIALE (INIT) ---
  ; La configurazione del mondo all'inizio della storia.
  (:init
    ; Posizione iniziale dei personaggi
    (si_trova_a shrek palude_di_shrek)
    (si_trova_a ciuchino palude_di_shrek)
    (si_trova_a fiona torre_del_drago)
    (si_trova_a farquaad castello_di_duloc)

    ; Stato iniziale dei luoghi e degli ostacoli
    (prigioniera_in fiona torre_del_drago)
    (fa_la_guardia draghessa torre_del_drago)
    (palude_occupata palude_di_shrek)

    ; Accordo tra Shrek e Farquaad
    (accordo_stretto shrek farquaad)

    ; Mappa del mondo (connessioni simmetriche)
    (connessi palude_di_shrek foresta_perigliosa)
    (connessi foresta_perigliosa palude_di_shrek)
    
    (connessi foresta_perigliosa torre_del_drago)
    (connessi torre_del_drago foresta_perigliosa)

    (connessi torre_del_drago castello_di_duloc)
    (connessi castello_di_duloc torre_del_drago)
  )

  ; --- OBIETTIVO (GOAL) ---
  ; Lo stato finale che il planner deve raggiungere.
  (:goal (and
    (missione_completata)
  ))
)