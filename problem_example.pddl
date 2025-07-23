(define (problem shrek_avventura_problema_complesso)
  (:domain shrek_avventura)

  ; Lista di tutti gli oggetti concreti, con i loro ruoli assegnati
  (:objects
    shrek    - salvatore
    ciuchino - distrattore
    fiona    - da_salvare
    
    palude castello bosco torre - luogo
    ponte_pericoloso - ponte
    chiave_della_torre - oggetto
  )

  ; Lo stato iniziale del mondo
  (:init
    ; Posizioni iniziali
    (si_trova_a shrek palude)
    (si_trova_a ciuchino palude)
    (si_trova_a fiona torre)
    (si_trova_a chiave_della_torre bosco)

    ; -- MODIFICA CHIAVE: Assegnamo la proprietà 'is_mobile'
    (is_mobile shrek)
    (is_mobile ciuchino)
    ; Poiché (is_mobile fiona) non è presente, per il planner è falso.

    ; Stati iniziali del mondo
    
    (drago_presente torre)
    (porta_chiusa torre)
    (is_key_for chiave_della_torre torre)
  )

  ; L'obiettivo finale da raggiungere
  (:goal (and (missione_completata)))
)
