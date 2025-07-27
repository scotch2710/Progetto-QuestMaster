(define (problem problema_cavaliere_principessa_sushi)
  ; Collega questo problema al dominio generico definito sopra.
  (:domain sushi_quest_generico)

  ; Sezione :objects. Qui vengono definite le istanze specifiche del nostro lore.
  ; I nomi sono arbitrari, ma i tipi (eroe, drago, ristorante...) devono corrispondere
  ; a quelli del dominio per ereditare le loro proprietà e restrizioni.
  (:objects
    cavaliere            - eroe        ; Il protagonista, l'unico che può combattere.
    principessa          - personaggio ; La compagna di viaggio.

    castello             - luogo       ; Il punto di partenza.
    strada_pericolosa    - luogo       ; Il luogo intermedio dove si trova il nemico.
    sushi_bar_del_regno  - ristorante  ; La destinazione finale.

    spada_leggendaria    - arma        ; L'oggetto chiave per sconfiggere il nemico.

    drago_famelico       - drago       ; L'antagonista che blocca la strada.
  )

  ; Sezione :init. Definisce lo stato iniziale del mondo, la "fotografia" all'inizio della storia.
  (:init
    ; Posizione iniziale dei personaggi.
    (si_trova_a cavaliere castello)
    (si_trova_a principessa castello)

    ; Posizione iniziale del nemico.
    (si_trova_a drago_famelico strada_pericolosa)

    ; Posizione iniziale dell'oggetto chiave.
    ; La spada si trova nel castello, pronta per essere raccolta dall'eroe.
    (si_trova_a spada_leggendaria castello)

    ; Nota: i predicati come (nemico_sconfitto) o (missione_completata) sono 'false' di default
    ; e non devono essere esplicitati qui.
  )

  ; Sezione :goal. Definisce lo stato finale che il planner deve raggiungere.
  ; L'obiettivo è semplice e dichiarativo, poiché tutta la logica complessa
  ; è già stata incapsulata nelle precondizioni delle azioni nel file di dominio.
  (:goal
    (and
      ; L'unico obiettivo è che la missione sia contrassegnata come completata.
      (missione_completata)
    )
  )
)