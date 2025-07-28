(define (problem shrek-adventure-1)
  (:domain shrek-quest-for-the-swamp)

  ;; --- OGGETTI SPECIFICI DEL MONDO ---
  ;; Tutte le istanze concrete di personaggi, luoghi e ostacoli.
  (:objects
    shrek - salvatore
    ciuchino - compagno
    fiona - da_salvare
    farquaad - mandante

    palude_di_shrek - palude
    castello_di_duloc - castello
    torre_del_drago - torre
    foresta_infestata - foresta

    draghessa - drago
    cavalieri_di_farquaad - cavaliere
  )

  ;; --- STATO INIZIALE DEL MONDO ---
  (:init
    ;; Posizione iniziale di tutti gli oggetti
    (si_trova_a shrek palude_di_shrek)
    (si_trova_a ciuchino palude_di_shrek)
    (si_trova_a fiona torre_del_drago)
    (si_trova_a farquaad castello_di_duloc)
    (si_trova_a draghessa torre_del_drago)
    ;; I cavalieri non hanno una posizione fissa, bloccano un percorso
    
    ;; Mappa del mondo: connessioni tra i luoghi
    (collegato palude_di_shrek castello_di_duloc)
    (collegato castello_di_duloc palude_di_shrek)
    (collegato castello_di_duloc foresta_infestata)
    (collegato foresta_infestata castello_di_duloc)
    (collegato foresta_infestata torre_del_drago)
    (collegato torre_del_drago foresta_infestata)

    ;; Mobilità iniziale dei personaggi
    (is_mobile shrek)
    (is_mobile ciuchino)
    ;; (is_mobile fiona) è assente, quindi per il planner è FALSO.

    ;; Stato degli ostacoli e della quest
    (palude_occupata)
    (drago_a_guardia draghessa torre_del_drago)
    (cavalieri_bloccano_percorso cavalieri_di_farquaad foresta_infestata torre_del_drago)
  )

  ;; --- OBIETTIVO FINALE ---
  ;; L'obiettivo primario è che la missione sia completata, il che implica che la palude sia libera.
  ;; Si potrebbe aggiungere (legame_stabilito shrek fiona) per un finale alternativo.
  (:goal (and
    (missione_completata)
  ))
)