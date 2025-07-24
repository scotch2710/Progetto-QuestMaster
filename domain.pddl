(define (domain sushi_quest)
  ; Definiamo i requisiti del linguaggio PDDL che stiamo utilizzando.
  ; :strips -> Azioni con precondizioni ed effetti additivi/sottrattivi.
  ; :typing -> Permette di definire una gerarchia di tipi per gli oggetti.
  ; :equality -> Permette di usare il predicato (=) per confrontare oggetti.
  (:requirements :strips :typing :equality)

  ;================================================================================
  ; TIPI: Definiamo le categorie di entità nel nostro mondo.
  ; La gerarchia è definita come 'sottotipo - tipo', rendendo il modello robusto.
  ; Il tipo generico (es. personaggio) è sempre posto dopo i suoi sottotipi.
  ;================================================================================
  (:types
    cavaliere - personaggio        ; Un cavaliere è un tipo speciale di personaggio.
    principessa - personaggio      ; Una principessa è un tipo speciale di personaggio.
    personaggio                    ; Categoria generica per le entità animate.

    castello - luogo               ; Un castello è un tipo speciale di luogo.
    ristorante_sushi - luogo       ; Un ristorante di sushi è un tipo speciale di luogo.
    luogo                          ; Categoria generica per le location.
  )

  ;================================================================================
  ; PREDICATI: Definiamo le proprietà e le relazioni che possono cambiare stato.
  ; Questi predicati descrivono lo stato del mondo in ogni momento.
  ;================================================================================
  (:predicates
    (si_trova_a ?p - personaggio ?l - luogo) ; Il personaggio ?p si trova nel luogo ?l.
    (cena_iniziata)                           ; Predicato 'flag' che diventa vero quando il goal è raggiunto.
  )

  ;================================================================================
  ; AZIONI: Definiamo le operazioni che possono modificare lo stato del mondo.
  ;================================================================================

  ; Azione: Spostarsi da un luogo all'altro.
  ; Questa azione è generica e può essere eseguita da qualsiasi 'personaggio'.
  (:action spostarsi
    :parameters (?persona - personaggio ?partenza - luogo ?destinazione - luogo)
    :precondition (and
        (si_trova_a ?persona ?partenza)         ; PRECONDIZIONE: La persona deve trovarsi nel luogo di partenza.
        (not (= ?partenza ?destinazione))       ; PRECONDIZIONE: Non ci si può spostare nello stesso luogo.
    )
    :effect (and
        (not (si_trova_a ?persona ?partenza))   ; EFFETTO: La persona non si trova più nel luogo di partenza.
        (si_trova_a ?persona ?destinazione)     ; EFFETTO: La persona si trova ora nel luogo di destinazione.
    )
  )

  ; Azione: Iniziare la cena al ristorante di sushi.
  ; Questa azione ha precondizioni molto specifiche per garantire la correttezza logica.
  ; Richiede esplicitamente un cavaliere e una principessa, come da lore.
  (:action iniziare_la_cena
    :parameters (?cav - cavaliere ?princ - principessa ?ristorante - ristorante_sushi)
    :precondition (and
        (si_trova_a ?cav ?ristorante)           ; PRECONDIZIONE: Il cavaliere deve essere al ristorante.
        (si_trova_a ?princ ?ristorante)         ; PRECONDIZIONE: La principessa deve essere al ristorante.
    )
    :effect (and
        (cena_iniziata)                         ; EFFETTO: L'obiettivo finale viene formalmente raggiunto.
    )
  )
)