(define (domain sushi_quest_generico)
  ; Definiamo i requisiti che abilitano la tipizzazione, le precondizioni negative ed esistenziali.
  ; Questi sono essenziali per modellare vincoli complessi come il blocco da parte di un nemico.
  (:requirements :strips :typing :negative-preconditions :existential-preconditions)

  ; Definiamo una gerarchia di tipi per classificare le entità del mondo.
  ; La sintassi "specifico - generico" (es. eroe - personaggio) permette all'eroe
  ; di ereditare tutte le proprietà e azioni del personaggio, più quelle esclusive per lui.
  (:types
    ristorante - luogo    ; Un ristorante è un tipo specializzato di luogo, la destinazione finale.
    luogo                 ; Tipo generico per tutte le location.

    eroe - personaggio    ; Un eroe è un tipo specializzato di personaggio, l'unico che può combattere.
    personaggio           ; Tipo generico per le entità animate che possono muoversi.

    arma - oggetto        ; Un'arma è un tipo specializzato di oggetto, usata per combattere.
    oggetto               ; Tipo generico per gli item.

    drago - nemico        ; Un drago è un tipo specializzato di nemico.
    nemico                ; Tipo generico per gli antagonisti.
  )

  ; Definiamo i predicati, ovvero le proprietà e le relazioni che possono cambiare durante il piano.
  (:predicates
    (si_trova_a ?entita - object ?l - luogo) ; Definisce la posizione di qualsiasi entità (personaggio, oggetto o nemico).
    (ha_con_se ?p - eroe ?o - oggetto)      ; Definisce se un eroe ha con sé un oggetto (es. un'arma).
    (nemico_sconfitto ?n - nemico)         ; Flag booleano: indica se un nemico è stato neutralizzato.
    (missione_completata)                  ; Flag booleano: rappresenta il raggiungimento del goal finale.
  )

  ; AZIONE: Un personaggio si sposta tra due luoghi.
  (:action viaggiare
    :parameters (?p - personaggio ?partenza - luogo ?arrivo - luogo) ; Chi si sposta, da dove, verso dove.
    :precondition (and
                    (si_trova_a ?p ?partenza) ; Il personaggio deve trovarsi nel luogo di partenza.
                    ; PRECONDIZIONE LOGICA CRUCIALE: Un personaggio non può LASCIARE un luogo
                    ; se in esso è presente un nemico non ancora sconfitto. Questo modella
                    ; il "blocco" imposto dal drago sulla strada.
                    (not (exists (?n - nemico)
                           (and
                             (si_trova_a ?n ?partenza)
                             (not (nemico_sconfitto ?n))
                           )
                         )
                    )
                  )
    :effect (and
              (not (si_trova_a ?p ?partenza)) ; Rimuove il personaggio dal luogo di partenza.
              (si_trova_a ?p ?arrivo)         ; Aggiunge il personaggio al luogo di arrivo.
            )
  )

  ; AZIONE: Un eroe raccoglie un'arma.
  (:action raccogliere_arma
    :parameters (?e - eroe ?a - arma ?l - luogo) ; L'azione è ristretta al tipo 'eroe'.
    :precondition (and
                    (si_trova_a ?e ?l)  ; L'eroe deve essere nello stesso luogo dell'arma.
                    (si_trova_a ?a ?l)  ; L'arma deve trovarsi in quel luogo (e non essere già posseduta).
                  )
    :effect (and
              (ha_con_se ?e ?a)           ; L'eroe ora possiede l'arma.
              (not (si_trova_a ?a ?l))    ; L'arma non si trova più "per terra", ma nell'inventario dell'eroe.
            )
  )

  ; AZIONE: L'eroe usa un'arma per sconfiggere un nemico.
  (:action sconfiggere_nemico
    :parameters (?e - eroe ?n - nemico ?a - arma ?l - luogo) ; Solo l'eroe può combattere, grazie alla tipizzazione.
    :precondition (and
                    (si_trova_a ?e ?l)          ; L'eroe deve essere nello stesso luogo del nemico.
                    (si_trova_a ?n ?l)          ; Il nemico deve essere nello stesso luogo dell'eroe.
                    (ha_con_se ?e ?a)           ; L'eroe deve avere con sé l'arma necessaria.
                    (not (nemico_sconfitto ?n)) ; L'azione è possibile solo se il nemico è ancora una minaccia.
                  )
    :effect (and
              (nemico_sconfitto ?n) ; Il nemico viene marcato come sconfitto, sbloccando l'azione 'viaggiare' da questo luogo.
            )
  )

  ; AZIONE: I personaggi raggiungono l'obiettivo finale.
  (:action raggiungere_obiettivo_sushi
    :parameters (?p1 - personaggio ?p2 - personaggio ?r - ristorante) ; Due personaggi arrivano alla destinazione finale.
    :precondition (and
                    (si_trova_a ?p1 ?r) ; Il primo personaggio deve essere arrivato al ristorante.
                    (si_trova_a ?p2 ?r) ; Anche il secondo personaggio deve essere arrivato al ristorante.
                    (not (= ?p1 ?p2))   ; Assicura che siano due personaggi distinti.
                    ; PRECONDIZIONE LOGICA CRUCIALE: La missione è completabile solo se il nemico principale è stato sconfitto.
                    ; Questo impedisce al planner di trovare un piano "scorciatoia" che ignori lo scontro col drago.
                    (exists (?n - nemico) (nemico_sconfitto ?n))
                  )
    :effect (and
              (missione_completata) ; Lo stato finale della missione viene impostato, risolvendo il problema.
            )
  )
)