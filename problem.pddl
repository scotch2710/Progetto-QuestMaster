(define (problem shrek_avventura_a_duloc)
  (:domain shrek_quest)

  ;; Oggetti: istanze concrete dei tipi definiti nel dominio.
  ;; Qui compaiono i nomi propri dei personaggi, luoghi e ostacoli.
  (:objects
    shrek - salvatore
    ciuchino - aiutante
    fiona - da_salvare
    farquaad - mandante

    palude_di_shrek - palude
    duloc - castello
    torre_del_drago - torre
    foresta_oscura - foresta

    drago_rosso - drago
    cavalieri_di_farquaad - cavaliere
  )

  ;; Stato Iniziale: la configurazione del mondo all'inizio della storia.
  (:init
    ;; Posizione iniziale dei personaggi
    (si_trova_a shrek palude_di_shrek)
    (si_trova_a ciuchino palude_di_shrek)
    (si_trova_a farquaad duloc)
    
    ;; Stato iniziale di Fiona
    (imprigionato fiona torre_del_drago)

    ;; Posizione degli ostacoli
    (ostacolo_presente drago_rosso torre_del_drago)
    (ostacolo_presente cavalieri_di_farquaad foresta_oscura)

    ;; Mappa del mondo (connessioni tra luoghi)
    ;; Assumiamo un percorso logico per la quest
    (connesso palude_di_shrek duloc)
    (connesso duloc palude_di_shrek)

    (connesso duloc foresta_oscura)
    (connesso foresta_oscura duloc)

    (connesso foresta_oscura torre_del_drago)
    (connesso torre_del_drago foresta_oscura)
    
    ;; Il problema che innesca la storia
    (palude_disturbata)
  )

  ;; Obiettivo Finale: lo stato del mondo che il planner deve raggiungere.
  (:goal 
    (and 
      (missione_completata)
    )
  )
)