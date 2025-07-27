(define (problem shrek-quest-istoria-originale)
  (:domain shrek-quest)

  ; --- OGGETTI ---
  ; Qui vengono dichiarate tutte le istanze concrete delle entità, con i loro tipi/ruoli specifici.
  (:objects
    shrek    - salvatore
    ciuchino - compagno
    fiona    - da_salvare
    farquaad - mandante

    palude_di_shrek                             - luogo
    foresta_pericolosa                          - luogo
    torre_del_drago                             - torre
    castello_di_duloc                           - castello
    
    drago                                       - guardiano
  )

  ; --- STATO INIZIALE (:init) ---
  ; Descrive la configurazione del mondo all'inizio della storia.
  (:init
    ; Motivazione iniziale
    (palude_invasa)

    ; Posizione iniziale dei personaggi
    (si_trova_a shrek palude_di_shrek)
    (si_trova_a ciuchino palude_di_shrek)
    (si_trova_a farquaad castello_di_duloc)
    (si_trova_a fiona torre_del_drago) ; Stato fittizio, la sua posizione reale è definita da 'prigioniero_in'.

    ; Stato di prigionia di Fiona
    (prigioniero_in fiona torre_del_drago)

    ; Posizione degli ostacoli
    (guardiano_in drago torre_del_drago)
    (cavalieri_presenti foresta_pericolosa) ; La foresta è un ostacolo da superare nel viaggio.
  )

  ; --- OBIETTIVO (:goal) ---
  ; Descrive lo stato del mondo che il planner deve raggiungere.
  (:goal
    (and
      (missione_completata) ; L'obiettivo primario è che la missione sia ufficialmente conclusa.
      (not (palude_invasa))   ; La conseguenza diretta è riavere la palude libera.
      
      ; Obiettivo opzionale per un piano più "completo" narrativamente:
      ; (legame_affettivo shrek fiona) 
    )
  )
)