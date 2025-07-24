(define (problem sushi-quest-1)
  (:domain sushi-quest)

  ;=================================================================================
  ; OGGETTI: Dichiaro tutte le istanze specifiche (nomi propri) presenti in questa
  ; avventura, assegnando a ciascuna il proprio tipo/ruolo definito nel dominio.
  ;=================================================================================
  (:objects
    cavaliere - eroe             ; L'istanza specifica del nostro eroe.
    principessa - compagno       ; L'istanza specifica del compagno.

    smaug - drago                ; Il nome del nostro drago antagonista.
    excalibur - arma             ; Il nome della spada del cavaliere.

    castello - luogo             ; Il luogo di partenza.
    sentiero_pericoloso - luogo  ; Il luogo intermedio dove si trova il drago.
    ristorante_sushi - luogo     ; Il luogo di destinazione e obiettivo.
  )

  ;=================================================================================
  ; STATO INIZIALE (:init): Descrivo lo stato del mondo all'inizio della quest.
  ; Tutti i predicati non elencati qui sono considerati falsi (Closed-World Assumption).
  ;=================================================================================
  (:init
    ; ----- Posizioni iniziali delle entità -----
    (si_trova_a cavaliere castello)
    (si_trova_a principessa castello)
    (drago_presente smaug sentiero_pericoloso) ; Il drago blocca il sentiero.

    ; ----- Proprietà iniziali -----
    (ha_con_se cavaliere excalibur) ; Il cavaliere inizia già con la sua spada.

    ; ----- Definizione della mappa del mondo -----
    (connesso castello sentiero_pericoloso)
    (connesso sentiero_pericoloso castello) ; I percorsi sono bidirezionali.

    (connesso sentiero_pericoloso ristorante_sushi)
    (connesso ristorante_sushi sentiero_pericoloso)

    ; ----- Stato iniziale dei sentieri -----
    (sentiero_libero castello) ; Si può partire dal castello.
    ; NOTA: (sentiero_libero sentiero_pericoloso) è assente, quindi è FALSO.
    ; Questo modella il blocco creato dal drago.
    (sentiero_libero ristorante_sushi) ; Se si arriva al ristorante, si può tornare indietro.
  )

  ;=================================================================================
  ; OBIETTIVO (:goal): Descrivo lo stato del mondo che il planner deve raggiungere.
  ;=================================================================================
  (:goal (and
      ; OBIETTIVO 1: Il cavaliere deve essere al ristorante sushi.
      (si_trova_a cavaliere ristorante_sushi)
      ; OBIETTIVO 2: La principessa deve essere al ristorante sushi.
      (si_trova_a principessa ristorante_sushi)
    )
  )
)