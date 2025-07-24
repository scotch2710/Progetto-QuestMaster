(define (problem sushi_quest_problema_base)
  ; Specifichiamo a quale dominio questo problema si riferisce.
  (:domain sushi_quest)

  ;================================================================================
  ; OGGETTI: Definiamo le istanze concrete delle entità del nostro mondo.
  ; Qui vengono inseriti i nomi propri, associati ai tipi definiti nel dominio.
  ;================================================================================
  (:objects
    arturo - cavaliere                     ; 'arturo' è la nostra istanza di cavaliere.
    ginevra - principessa                  ; 'ginevra' è la nostra istanza di principessa.

    castello_reale - castello              ; 'castello_reale' è la nostra istanza di castello.
    sushi_zen - ristorante_sushi           ; 'sushi_zen' è la nostra istanza di ristorante_sushi.
  )

  ;================================================================================
  ; STATO INIZIALE (:init): Descriviamo lo stato del mondo all'inizio della storia.
  ; Tutti i predicati che sono veri all'inizio vengono elencati qui.
  ;================================================================================
  (:init
    ; Posizione iniziale dei personaggi, come descritto nel lore.
    (si_trova_a arturo castello_reale)
    (si_trova_a ginevra castello_reale)

    ; Il predicato (cena_iniziata) è implicitamente falso perché non è elencato qui.
  )

  ;================================================================================
  ; OBIETTIVO (:goal): Descriviamo lo stato del mondo che vogliamo raggiungere.
  ; Il piano sarà considerato valido se, e solo se, raggiungerà questo stato.
  ;================================================================================
  (:goal
    (and
        (cena_iniziata)
    )
  )
)