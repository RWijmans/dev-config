# CLAUDE.md — Generieke ontwikkelrichtlijnen

This file provides development guidelines to Claude Code and applies to all projects under C:\Dev.
De bedrijven waarvoor we software ontwikkelen.

### Gigaprint
- Printing on Demand bedrijf (~300 orders per dag, volledig geautomatiseerd)
- Eigen ERP systeem: **DocuTraffic** met modules: Relaties, Planning, Printserver, Afwerking, Verzenden, Facturatie
- Wens om eigen ERP systeem af te bouwen en te migreren naar odoo19 in combinatie met eigen custom modules
- Koppeling met **Exact** voor financiële administratie

### MyPhotoFun
- B2C webshop voor fotoboeken
- Fotoboek editor: ingekocht bij **TAOPIX** (web + offline editor)
- Betaalverwerking via **Multisafepay**
- Helpdesk: ASP.NET applicatie gekoppeld aan TAOPIX en SQL Server Deze applicatie heet UCIS
- Orders worden verwerkt via Gigaprint.
- De klanten van MyPhotoFun zijn consumers die fotoboeken komen.
- MyPhotoFun heeft de beschikking over een domein readerservice.nl 
- In odoo is dit ook een applicatie die we inrichten.

## Technische stack

- **Primaire taal:** C#
- **Platforms:**
  - .NET Framework 4.x — legacy Windows Forms applicaties (nog actief in gebruik)
  - .NET Core / .NET — nieuwere applicaties, veel gebruik van **Blazor**
  - **Python** — voor toekomstige integraties (o.a. richting Odoo 19 als ERP vervanging met custom modules)
- **Database:** SQL Server
- **Financieel:** Exact (koppeling)
- **Versiebeheer:** GitHub

## Naamconventies

- **Taal van code** (variabelen, klassen, methoden, comments): **Engels**
- **Casing in code:**
  - Klassen, methoden, properties: `PascalCase`
  - Lokale variabelen, parameters: `camelCase`
- **Database tabellen en kolommen:** `snake_case` met underscore als woordscheiding (bijv. `order_line`, `customer_id`)

## Werkstijlvoorkeur

- **Antwoordtaal:** Altijd Nederlands
- **Antwoordstijl:** Duidelijk en concreet — geen vage verwijzingen. Als ergens naar verwezen wordt (bestand, map, instelling), geef dan het volledige pad of de exacte locatie zodat het geen zoekplaatje wordt.
- **Code uitleg:** Altijd toelichten wat code doet. Leg ook altijd uit wanneer en waarom een functie, methode of patroon wordt toegepast — niet alleen hoe het werkt, maar ook de reden achter de keuze.
- **Bij meerdere opties:** Maak een keuze en licht toe waarom, in plaats van alleen opties te noemen.

## Ontwikkelprincipes

- **OOP:** Pas altijd Object Georiënteerde Programmeer principes toe (encapsulatie, overerving, polymorfisme, abstractie). Denk na over de juiste verdeling van verantwoordelijkheden over klassen.
- **Geen codeduplicatie:** Voorkom in alle gevallen dat dezelfde logica op meerdere plekken voorkomt. Extraheer herhaalde code naar een gedeelde methode, klasse of basisklasse.
- **Commentaar:** Voeg commentaar toe wanneer de werking van een functie of methode niet direct duidelijk is uit de code zelf. Leg dan uit wat de functie doet, waarom deze aanpak is gekozen, en wat eventuele randgevallen zijn.
- **Disposable objecten:** Gebruik altijd een `using`-statement of `using`-declaratie voor objecten die `IDisposable` implementeren (zoals database-connecties, streams, readers, writers). Dit garandeert dat resources altijd correct worden vrijgegeven, ook bij een fout.
- **Variabelen:** Voeg altijd een commentaarregel toe bij elke variabele — zowel op klasse-niveau (fields) als binnen een functie — die beschrijft waarvoor de variabele wordt gebruikt of wat deze bijhoudt.
- **Klasse-architectuur:** Denk altijd goed na over de opbouw van klassen voordat je code schrijft. De structuur moet logisch, overzichtelijk en goed gelaagd zijn. Verantwoordelijkheden worden duidelijk verdeeld over klassen en lagen. Duplicaten worden te allen tijde voorkomen.
- **Method overloading:** Optimaliseer functies door overloads te gebruiken wanneer dezelfde functionaliteit met een andere set parameters aangeboden kan worden. Dit voorkomt duplicatie en houdt de interface consistent en voorspelbaar.

## GitHub — Werkwijze

Ik ben relatief nieuw met Git en GitHub. Houd rekening met het volgende:

### Branch strategie
- `main` — stabiele, werkende code (nooit direct op werken)
- `develop` — integratiebranch voor lopende ontwikkeling
- `feature/naam` — per feature of taak een eigen branch (bijv. `feature/helpdesk-login`)

### Stappenplan per feature
1. Start altijd vanuit `develop`: `git checkout develop && git pull`
2. Maak een feature branch: `git checkout -b feature/naam`
3. Werk en commit regelmatig met een duidelijke boodschap
4. Push naar GitHub: `git push -u origin feature/naam`
5. Maak een Pull Request op GitHub van `feature/naam` → `develop`
6. Na review/akkoord: merge naar `develop`
7. Periodiek: merge `develop` → `main` als alles stabiel is

### Commit boodschappen
Schrijf commits in het Engels, kort en beschrijvend:
- `Add helpdesk login page`
- `Fix order status not updating`
- `Refactor invoice module`

### Algemeen
- Geef bij Git-gerelateerde taken altijd de exacte commando's met uitleg wat ze doen.
- Waarschuw als een actie destructief is (zoals `reset --hard` of `force push`).
