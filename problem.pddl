(define (problem riconquistare_la_palude)
  (:domain avventura_orco_corretto)

  ; Oggetti: istanze specifiche dei tipi definiti nel dominio.
  (:objects
    shrek    - salvatore
    ciuchino - compagno
    fiona    - da_salvare
    farquaad - governante
    drago_femmina - guardiano

    palude foresta_oscura duloc torre_del_drago - luogo
  )

  ; Stato iniziale del mondo: come sono le cose all'inizio della storia.
  (:init
    ; --- Posizioni Iniziali ---
    (si_trova_a shrek palude)
    ; Ciuchino si trova nella foresta, dove Shrek lo incontrerà.
    (si_trova_a ciuchino foresta_oscura) 
    (si_trova_a farquaad duloc)
    (si_trova_a fiona torre_del_drago)
    (si_trova_a drago_femmina torre_del_drago)

    ; --- Connessioni tra Luoghi (Mappa del Mondo) ---
    (connessi palude foresta_oscura)
    (connessi foresta_oscura palude)
    (connessi foresta_oscura duloc)
    (connessi duloc foresta_oscura)
    (connessi foresta_oscura torre_del_drago)
    (connessi torre_del_drago foresta_oscura)

    ; --- Stato Iniziale della Missione ---
    (creature_nella_palude) ; Il problema che dà inizio a tutto.
  )

  ; Obiettivo finale: lo stato del mondo che vogliamo raggiungere.
  (:goal
    (and
      ; L'obiettivo finale di Shrek è riavere la sua palude tranquilla.
      (not (creature_nella_palude))
    )
  )
)