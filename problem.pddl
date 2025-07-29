(define (problem shrek-mission-for-the-swamp)
  (:domain shrek-chronicles)

  ; Istanze concrete delle entità definite nel dominio.
  (:objects
    shrek    - salvatore
    ciuchino - compagno
    fiona    - da_salvare
    farquaad - committente

    drago_guardiano - drago
    
    atto_della_palude - oggetto_legale

    palude duloc torre - luogo
  )

  ; Stato iniziale del mondo, con le posizioni e le proprietà di partenza.
  (:init
    ; --- Posizioni Iniziali ---
    (si_trova_a shrek palude)
    (si_trova_a ciuchino palude)
    (si_trova_a fiona torre)
    (si_trova_a farquaad duloc)
    (drago_a_guardia drago_guardiano torre)

    ; --- MODIFICA CHIAVE: Farquaad è un personaggio statico, non può viaggiare ---
    (personaggio_fermo farquaad)

    ; --- Proprietà Iniziali degli Oggetti e dei Luoghi ---
    (possiede farquaad atto_della_palude)
    (luogo_natale shrek palude)
    (atto_relativo_a atto_della_palude palude)
  )

  ; L'obiettivo finale che il planner deve raggiungere.
  (:goal (and 
    (palude_riconquistata)
    (possiede shrek atto_della_palude)
  ))
)