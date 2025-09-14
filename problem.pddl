(define (problem shrek-deve-salvare-fiona)
  (:domain shrek-quest)

  ;; Lista di tutti gli oggetti concreti del mondo, con i loro tipi/ruoli assegnati.
  ;; Qui compaiono i nomi propri (Shrek, Fiona, etc.).
  (:objects
    shrek - salvatore
    ciuchino - compagno
    fiona - da_salvare
    farquaad - mandante
    drago - guardiano

    palude foresta ponte_pericolante - luogo
    torre_del_drago - torre
    duloc - castello
  )

  ;; Descrizione dello stato iniziale del mondo.
  (:init
    ;; Posizioni iniziali di tutti i personaggi e del guardiano.
    (si_trova_a shrek palude)
    (si_trova_a ciuchino palude)
    (si_trova_a farquaad duloc)
    (si_trova_a drago torre_del_drago)
    ;; La posizione di Fiona è implicitamente definita dal predicato (imprigionata).

    ;; Mappa del mondo: definisce le connessioni tra i luoghi.
    ;; Le connessioni sono definite in entrambe le direzioni per permettere il viaggio di ritorno.
    (connessi palude foresta)
    (connessi foresta palude)
    (connessi foresta ponte_pericolante)
    (connessi ponte_pericolante foresta)
    (connessi ponte_pericolante torre_del_drago)
    (connessi torre_del_drago ponte_pericolante)
    (connessi palude duloc)
    (connessi duloc palude)

    ;; Stato iniziale delle condizioni del mondo e dei personaggi.
    (palude_invasa) ; La palude di Shrek è invasa dalle creature magiche.
    (imprigionata fiona torre_del_drago) ; Fiona è prigioniera nella sua torre.
    (guardiano_presente drago torre_del_drago) ; Il drago sorveglia la torre.
  )

  ;; L'obiettivo finale che il planner deve raggiungere.
  ;; L'obiettivo è semplice e chiaro: la missione deve essere completata.
  ;; Il predicato (missione_completata) implica che la palude sia stata liberata,
  ;; come definito nell'effetto dell'azione 'completare_missione'.
  (:goal
    (and
      (missione_completata)
      ;; Aggiungiamo 'segreto_svelato' come parte dell'obiettivo per riflettere
      ;; la profondità narrativa desiderata.
      (segreto_svelato fiona)
    )
  )
)