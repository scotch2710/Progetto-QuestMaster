(define (domain sushi-quest)
  (:requirements :strips :typing)

  ;=================================================================================
  ; TIPI: Definisco le categorie generiche di entità nel mondo.
  ; La gerarchia permette di assegnare azioni a ruoli specifici (es. solo un 'eroe' può combattere).
  ; Come da regola, il tipo più generico è dichiarato dopo quello specifico.
  ;=================================================================================
  (:types
    eroe - personaggio      ; Un 'eroe' è un tipo speciale di 'personaggio' che può combattere.
    compagno - personaggio  ; Un 'compagno' è un tipo di 'personaggio' che accompagna l'eroe.
    personaggio             ; Categoria generale per gli agenti senzienti.

    arma - oggetto          ; Un''arma' è un tipo speciale di 'oggetto' usato per combattere.
    oggetto                 ; Categoria generale per gli item inanimati.

    drago                   ; Un tipo a sé per l'antagonista.
    luogo                   ; Categoria per le location del mondo.
  )

  ;=================================================================================
  ; PREDICATI: Definisco le proprietà e le relazioni che possono essere vere o false.
  ; Questi predicati descrivono lo stato del mondo in ogni momento.
  ; Ciascun predicato è definito una sola volta, come da regola.
  ;=================================================================================
  (:predicates
    ; (si_trova_a ?x - object ?l - luogo)
    ; Indica che un'entità generica ?x (personaggio, drago, oggetto) si trova nel luogo ?l.
    ; Usiamo il supertipo implicito 'object' per la massima generalità e aderenza agli standard.
    (si_trova_a ?x - object ?l - luogo)

    ; (ha_con_se ?p - personaggio ?o - oggetto)
    ; Indica che il personaggio ?p sta trasportando l'oggetto ?o.
    (ha_con_se ?p - personaggio ?o - oggetto)

    ; (connesso ?da - luogo ?a - luogo)
    ; Indica che esiste un percorso diretto dal luogo ?da al luogo ?a.
    (connesso ?da - luogo ?a - luogo)

    ; (drago_presente ?d - drago ?l - luogo)
    ; Indica che il drago ?d si trova nel luogo ?l, agendo come potenziale ostacolo.
    (drago_presente ?d - drago ?l - luogo)

    ; (sentiero_libero ?l - luogo)
    ; Predicato cruciale: indica che il percorso IN USCITA dal luogo ?l non è bloccato.
    ; Se un drago è presente, questo predicato sarà falso finché non viene sconfitto.
    (sentiero_libero ?l - luogo)
    
    ; (drago_sconfitto ?d - drago)
    ; Indica che il drago ?d è stato sconfitto e non è più una minaccia.
    (drago_sconfitto ?d - drago)
  )

  ;=================================================================================
  ; AZIONI: Definisco le possibili azioni che modificano lo stato del mondo.
  ; Ogni azione ha precondizioni precise per evitare soluzioni illogiche.
  ;=================================================================================

  ;---------------------------------------------------------------------------------
  ; AZIONE: VIAGGIARE
  ; Un personaggio può spostarsi da un luogo all'altro.
  ;---------------------------------------------------------------------------------
  (:action viaggiare
    :parameters (?p - personaggio ?da - luogo ?a - luogo)
    :precondition (and
        ; PRECONDIZIONE 1: Il personaggio ?p deve trovarsi nel luogo di partenza ?da.
        (si_trova_a ?p ?da)
        ; PRECONDIZIONE 2: Deve esistere una connessione diretta tra la partenza ?da e l'arrivo ?a.
        (connesso ?da ?a)
        ; PRECONDIZIONE 3 (FONDAMENTALE): Il sentiero in uscita dal luogo di partenza ?da deve essere libero.
        ; Questo impedisce al planner di "saltare" oltre il drago senza prima affrontarlo.
        (sentiero_libero ?da)
    )
    :effect (and
        ; EFFETTO 1: Il personaggio ?p non si trova più nel luogo di partenza ?da.
        (not (si_trova_a ?p ?da))
        ; EFFETTO 2: Il personaggio ?p si trova ora nel luogo di arrivo ?a.
        (si_trova_a ?p ?a)
    )
  )

  ;---------------------------------------------------------------------------------
  ; AZIONE: SCONFIGGERE_DRAGO
  ; L'eroe usa un'arma per sconfiggere un drago, liberando il passaggio.
  ;---------------------------------------------------------------------------------
  (:action sconfiggere_drago
    :parameters (?h - eroe ?d - drago ?w - arma ?l - luogo)
    :precondition (and
        ; PRECONDIZIONE 1: L'eroe ?h deve essere nello stesso luogo ?l del drago.
        (si_trova_a ?h ?l)
        ; PRECONDIZIONE 2: Il drago ?d deve essere presente nel luogo ?l.
        (drago_presente ?d ?l)
        ; PRECONDIZIONE 3: L'eroe ?h deve avere con sé un'arma ?w.
        (ha_con_se ?h ?w)
        ; PRECONDIZIONE 4: Il drago non deve essere già stato sconfitto.
        (not (drago_sconfitto ?d))
    )
    :effect (and
        ; EFFETTO 1: Il drago ?d è ora segnato come sconfitto.
        (drago_sconfitto ?d)
        ; EFFETTO 2 (FONDAMENTALE): Il sentiero in uscita dal luogo ?l è ora libero.
        ; Questo "sblocca" l'azione di viaggio da questo luogo.
        (sentiero_libero ?l)
        ; EFFETTO 3: Il drago non è più fisicamente presente e non costituisce più un ostacolo.
        (not (drago_presente ?d ?l))
    )
  )
)