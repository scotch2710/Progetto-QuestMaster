(define (problem sushi-quest-avventura-1)
  (:domain sushi-quest)

  ; --- OGGETTI ---
  ; Qui vengono dichiarate le istanze concrete delle entità, assegnando loro i tipi/ruoli
  ; definiti nel file di dominio.
  (:objects
    cavaliere - guerriero
    principessa - compagno_viaggio

    castello - punto_partenza
    foresta_del_drago - luogo
    sushi_bar - punto_arrivo

    spada_leggendaria - arma

    drago - antagonista
  )

  ; --- STATO INIZIALE ---
  ; Definisce lo stato del mondo all'inizio della quest.
  (:init
    ; Posizioni iniziali dei personaggi
    (si_trova_a cavaliere castello)
    (si_trova_a principessa castello)

    ; Posizione iniziale dell'arma (nell'armeria del castello)
    (si_trova_a_oggetto spada_leggendaria castello)

    ; Posizione dell'antagonista (a guardia del percorso)
    (antagonista_presente_a drago foresta_del_drago)

    ; Definizione del percorso (la mappa del mondo)
    ; È un percorso a senso unico e ritorno.
    (connessi castello foresta_del_drago)
    (connessi foresta_del_drago castello)
    (connessi foresta_del_drago sushi_bar)
    (connessi sushi_bar foresta_del_drago)

    ; Nello stato iniziale, la missione non è completa e il drago non è sconfitto.
    ; Per la Closed World Assumption del PDDL, non è necessario dichiarare (not (missione_completata))
    ; o (not (antagonista_sconfitto drago)).
  )

  ; --- OBIETTIVO ---
  ; Lo stato del mondo che il planner deve raggiungere.
  (:goal
    (and
      (missione_completata) ; L'unico obiettivo è che la missione sia contrassegnata come completa.
    )
  )
)