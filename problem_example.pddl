; Definizione dello scenario specifico per la conquista di Milano
(define (problem conquista-di-milano)
  (:domain cavaliere-epico) ; Specifica le regole del mondo da usare

  ; Lista di tutti gli oggetti concreti in questo scenario
  (:objects
    artu - cavaliere
    fafnir - drago
    cosenza bologna milano - citta
    excalibur arco-di-legno - arma
    destriero - mezzo_trasporto
  )

  ; Lo stato iniziale del mondo
  (:init
    ; Posizione iniziale del cavaliere
    (si-trova-a artu cosenza)

    ; Equipaggiamento iniziale del cavaliere
    (ha-con-se artu excalibur)
    (ha-con-se artu arco-di-legno)
    (ha-cavallo artu destriero)

    ; Mappa del mondo
    (percorso cosenza bologna)
    (percorso bologna milano)

    ; Stato e posizione del drago
    (drago-vivo fafnir)
    (si-trova-a fafnir bologna)
  )

  ; L'obiettivo finale da raggiungere
  (:goal (and
    (citta-conquistata milano)
  ))
)