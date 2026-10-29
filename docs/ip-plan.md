# IP-plan og regelmatrise

## Soner

| Sone | Subnett | Brannmurens adresse | Eksempelvert |
|---|---|---|---|
| ansatte | 10.10.10.0/24 | 10.10.10.1 | 10.10.10.10 (PC) |
| servere | 10.10.20.0/24 | 10.10.20.1 | 10.10.20.10 (filserver) |
| dmz | 10.10.30.0/24 | 10.10.30.1 | 10.10.30.10 (webserver) |
| gjester | 10.10.40.0/24 | 10.10.40.1 | 10.10.40.10 (gjest-PC) |
| management | 10.10.99.0/24 | 10.10.99.1 | 10.10.99.10 (admin-PC) |
| internett (simulert) | 203.0.113.0/24 | 203.0.113.1 | 203.0.113.10 (ekstern server) |

## Regelmatrise

Rad = hvem som starter tilkoblingen. Kolonne = hvem de snakker med.
Tall er tillatte TCP-porter. Alt annet er blokkert. Svar på tillatte
tilkoblinger slipper gjennom automatisk (stateful brannmur).

| Fra / Til | ansatte | servere | dmz | gjester | management | internett |
|---|---|---|---|---|---|---|
| ansatte | - | 445 | 80, 443 | ✘ | ✘ | 80, 443 |
| servere | ✘ | - | ✘ | ✘ | ✘ | ✘ |
| dmz | ✘ | ✘ | - | ✘ | ✘ | ✘ |
| gjester | ✘ | ✘ | ✘ | - | ✘ | 80, 443 |
| management | 22, ping | 22, ping | 22, ping | ✘ | - | 80, 443 |
| internett | ✘ | ✘ | 80, 443 | ✘ | ✘ | - |

## Prinsipper

1. Default deny: all trafikk mellom soner er blokkert til en regel sier noe annet.
2. Stateful: bare den som starter en tilkobling trenger en regel.
3. Minst mulig tilgang: bare de portene som faktisk trengs.
4. DMZ starter ingenting innover. Blir webserveren hacket, stopper skaden der.
5. Management er en egen sone, og ingen andre soner når den.
6. Utgående trafikk filtreres også. Servere og DMZ har ikke internett.
7. Droppet trafikk logges, slik at vi kan vise hva brannmuren stoppet.

## Forenklinger

- Internett er en egen namespace med dokumentasjonsadresser, ikke ekte internett.
- Ingen DNS. Vi bruker IP-adresser.
- Ingen VLAN eller fysiske svitsjer: hver sone har sin egen virtuelle kabel til brannmuren.
