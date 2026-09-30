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
- **UI-componentenbibliotheek (interfacing):** Syncfusion, niet meer DevExpress - vastgesteld door Roy op 22 september 2026: "voor de interfacing van het project stappen we af van DevExpress maar gebruiken we nu Syncfusion als basis." Geldt voor nieuw/vervangend interface-werk in alle projecten onder `C:\Dev`. `DtPrintServer7` was hier het eerste project dat dit toepaste (aanvankelijk vanwege een verlopen DevExpress-licentie, zie `C:\Dev\dt7\DtPrintServer7\CLAUDE.md`) en dient als precedent voor de concrete inrichting (per-component NuGet-packages vanaf nuget.org, licentiesleutel via User Secrets/environment variable, Bootstrap 5.3-thema) - zie ook de dt7-brede Syncfusion-grid-afspraak in `C:\Dev\dt7\CLAUDE.md`, "Algemene afspraken", afspraak 6.
- **Database:** MS SQL Server (huidige productiedatabases). **Database-toegang altijd via Entity Framework (Core), nooit via een andere weg** (geen kale ADO.NET, geen Dapper, geen andere ORM) - vastgesteld door Roy op 22 september 2026, generiek voor alle projecten onder `C:\Dev` (dt7 had deze regel al specifiek voor zichzelf, zie `C:\Dev\dt7\CLAUDE.md`, "Algemene afspraken", afspraak 1). **PostgreSQL-compatibiliteit blijven nastreven:** ondanks dat SQL Server nu de gebruikte database is, bewust geen SQL Server-specifieke features/syntax gebruiken (bv. T-SQL-only functies, proprietary datatypes) waar een provider-neutrale EF Core-aanpak ook volstaat - zodat een toekomstige overstap naar PostgreSQL mogelijk blijft zonder grote herschrijving. dt7's `DtPrintServer7` gebruikt om die reden al PostgreSQL (een eigen, gemotiveerde per-projectkeuze, zie dt7's CLAUDE.md) - een concreet voorbeeld dat dezelfde EF Core-laag prima op beide databases kan draaien.
- **Financieel:** Exact (koppeling)
- **Versiebeheer:** GitHub

## Naamconventies

- **Taal van code** (variabelen, klassen, methoden, comments): **Engels**
- **Casing in code:**
  - Klassen, methoden, properties: `PascalCase`
  - Lokale variabelen, parameters: `camelCase`
- **Database tabellen en kolommen:** `snake_case` met underscore als woordscheiding, **altijd in het Engels** - nooit een Nederlandse tabel- of kolomnaam (bijv. `order_line`, `customer_id`, niet `klant_id`). Geldt voor de naam van de tabel/kolom zelf; de gegevens die erin staan (bv. een omschrijvingstekst) mogen uiteraard gewoon Nederlands zijn. Expliciet vastgelegd op 16 september 2026 nadat een `Oplage`-veld (Nederlands) in een entiteit sloop - zie DtPrintServer7's CLAUDE.md voor de correctie naar `CopyCount`.
- **Tabelnamen: altijd meervoud** (bijv. `devices`, `print_jobs`, `bindings`, niet `device`/`print_job`/`binding`) - een tabel is een verzameling rijen. Bij Entity Framework Core (anders dan het oudere EF6) komt dit niet automatisch uit een singuliere entiteitsklasse - EF Core gebruikt de naam van de `DbSet<T>`-property letterlijk als tabelnaam. Zorg dus dat elke `DbSet<T>`-property zelf al een meervoudsvorm heeft (bijv. `DbSet<Device> Devices`), dan volgt de meervoudige tabelnaam vanzelf uit de snake_case-conventie hierboven. Expliciet vastgelegd op 16 september 2026, samen met de regel hierboven.
- **Private fields (klasse-niveau velden):** `_camelCase`, dus een underscore-prefix gevolgd door camelCase (bijv. `_printJobs`, `_devices`) - onderscheidt een veld in één oogopslag van een lokale variabele of parameter (die geen underscore-prefix krijgen). Expliciet vastgelegd op 22 september 2026 - was al consequent zo toegepast (bijv. in DtPrintServer7's Blazor-pagina's), maar nog niet als regel opgeschreven.
- **Interfaces:** altijd een `I`-prefix vóór een PascalCase-naam (bijv. `IBatchAssignmentService`, `IPrintJobChangeNotifier`) - de gangbare .NET-conventie, al consequent toegepast, nu ook expliciet vastgelegd (22 september 2026).
- **Async methoden:** altijd een `Async`-suffix (bijv. `EvaluateAsync`, `SaveChangesAsync`) - maakt in de aanroepende code meteen duidelijk dat er `await` bij hoort. Geldt voor elke methode die een `Task`/`Task<T>` teruggeeft, met als enige gangbare uitzondering event-handlers/lifecycle-methoden waarvan de naam al door het framework is vastgelegd (bv. Blazor's `OnInitializedAsync` volgt deze regel toevallig al vanzelf). Expliciet vastgelegd op 22 september 2026.
- **Booleans (velden, properties, lokale variabelen):** een vraagvorm-prefix die meteen duidelijk maakt dat het om een ja/nee-waarde gaat - `Is`/`Has`/`Can`/`Should` (bijv. `IsBulkEdit`, `HasFormats`, `CanEditBatchSequence`). Geen kale zelfstandige naamwoorden voor een boolean (dus niet `Bulk`, wel `IsBulkEdit`). Expliciet vastgelegd op 22 september 2026 - was al consequent zo toegepast.
- **Enums: een naam staat voor precies één vaste verzameling members, overal.** Bestaat er ergens al een enum met een bepaalde naam (in dezelfde of een andere library/project), dan gebruikt een nieuwe plek die exact hetzelfde begrip nodig heeft **altijd die bestaande definitie** - nooit een eigen, opnieuw gedefinieerde enum met dezelfde naam, ook niet als de members op het moment van schrijven toevallig gelijk zijn. Heeft een situatie **andere** waarden nodig (bijv. een extra lid zoals "Any"/"Onbekend" dat in de ene context wel geldig is en in de andere niet), dan krijgt dat een **eigen, andere naam** - nooit dezelfde naam met afwijkende members, dat leidt tot verwarring over welke members in een gegeven context eigenlijk toegestaan zijn. Is een bestaand enum-lid in een specifieke situatie niet toepasbaar (bijv. een methode die met een bepaalde waarde niet overweg kan), dan gooit die methode op dat punt een duidelijke exceptie die benoemt welke waarde daar niet gebruikt mag worden - in plaats van daarvoor een aparte, beperktere variant-enum te definiëren. Vastgesteld door Roy op 23 september 2026, naar aanleiding van een geconstateerde dubbele `Grain`/`GrainDirection`-enum tussen `ABCPdfLib` en `DtPrintServer7.BL` (het fysieke-vel-enum `Grain` is dezelfde dag verder hernoemd naar `SheetGrain`, precies om de hier beschreven verwarring tussen bijna-identiek genoemde enums te voorkomen) - zie `C:\Dev\dt7\DtLibs\CLAUDE.md` voor het concrete voorbeeld en `C:\Dev\dt7\CLAUDE.md`, "Algemene afspraken", afspraak 11, voor hoe dit binnen dt7 wordt toegepast op de vraag wáár een gedeeld enum dan moet wonen.

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
- **Eén definitie per begrip:** alles wat hetzelfde vertegenwoordigt - een enum, een constante, een standaardwaarde, een waardeobject, een statuslijst - wordt op precies één plek gedefinieerd, in het project/de dll die het begrip het meest natuurlijk bezit (zie `C:\Dev\dt7\CLAUDE.md`, afspraak 11), en via de bestaande projectreferenties hergebruikt - nooit via een tweede, gelijkwaardige definitie. Dat geldt óók als die tweede definitie anders heet of een andere vorm heeft (bv. een `bool Duplex` naast een enum `PrintSides`, of een eigen `DefaultBleedMm = 3` naast `ComponentType.DefaultBleedMm`). Bij elke ontwikkelstap controleren; moet een begrip tijdens de ontwikkeling in een ander project beschikbaar komen, dan wordt de definitie **verplaatst** naar de gezamenlijke plek (een project dat beide al refereren, of dat de ander refereert) - niet gekopieerd. Is er geen natuurlijke plek, dan eerst overleggen (zie `programmer.md` over nieuwe libraries). Vastgesteld door Roy op 27 september 2026; breidt de enum-regel onder "Naamconventies" uit (die gaat over enums met dezelfde naam, deze over alles wat hetzelfde betekent).
- **Klasse-architectuur:** Denk altijd goed na over de opbouw van klassen voordat je code schrijft. De structuur moet logisch, overzichtelijk en goed gelaagd zijn. Verantwoordelijkheden worden duidelijk verdeeld over klassen en lagen. Duplicaten worden te allen tijde voorkomen.
- **Method overloading:** Optimaliseer functies door overloads te gebruiken wanneer dezelfde functionaliteit met een andere set parameters aangeboden kan worden. Dit voorkomt duplicatie en houdt de interface consistent en voorspelbaar.
- **Functies plaatsen: binnen een applicatie of in een gedeelde library?** Zie `C:\Dev\programmer.md` voor de volledige uitwerking (vastgesteld door Roy op 22 september 2026) - kort samengevat: een functie die binnen één applicatie blijft, bouw je ook dáár; blijkt een functie generiek genoeg voor meerdere applicaties, dan hoort hij in een gedeelde library (eigen dll, zoals `C:\Dev\dt7\DtLibs\`). Een **nieuwe** library wordt nooit zelfstandig aangemaakt - altijd eerst overleggen met Roy en motiveren waarom, en bij twijfel juist wél vragen in plaats van zelf te beslissen. `programmer.md` bevat ook het vaste "automatisch bepaald vs. handmatig overschreven"-patroon (afspraak 5 daar) - gebruik dat patroon steeds opnieuw zodra een veld die twee toestanden kent, in plaats van het per geval anders op te lossen.
- **Nullable-reference-warnings (CS8602/CS8604 e.d.):** geen losse opschoonronde, maar wél oplossen zodra je toch al in een bestand werkt dat zulke waarschuwingen heeft - vastgesteld door Roy op 22 september 2026, omdat een genegeerde nullable-warning op termijn tot een onverwachte `NullReferenceException` kan leiden. Kom je zo'n warning tegen in code die je toch al aanraakt, los 'm dan mee op (een echte null-check, of een gemotiveerde `!`/`?` als null daar aantoonbaar niet kan voorkomen) - niet apart een hele laag doorspitten die verder niets met de huidige taak te maken heeft.
- **Datum-/tijdvelden (CreatedAt, UpdatedAt e.d.):** altijd `DateTimeOffset`, nooit kaal `DateTime` - vastgesteld door Roy op 22 september 2026, na een geconstateerde inconsistentie in DtPrintServer7 (`PrintBatch.CreatedAtUtc` als `DateTime` naast `PrinterSelectionScript.UpdatedAtUtc` als `DateTimeOffset`). `DateTimeOffset` draagt zijn tijdzone-informatie zelf, wat UTC/lokale-tijd-verwarring voorkomt. Geldt voor nieuwe velden; bestaande `DateTime`-velden worden niet automatisch omgezet, alleen wanneer daar toch al aan gewerkt wordt of Roy dat expliciet vraagt.
- **Swagger/OpenAPI:** Elk endpoint krijgt altijd `.WithName()`, `.WithSummary()`, `.WithDescription()` én volledige response-documentatie via `.Produces<T>(statusCode)` voor succesresponses en `.ProducesProblem(statusCode)` voor foutresponses (404, 500 etc.). Dit geldt voor alle endpoints zonder uitzondering.

## CLAUDE.md onderhoud

- Werk de CLAUDE.md van het betreffende project **altijd** bij als er nieuwe afspraken, endpoints, tabellen, architectuurkeuzes of conventies worden gemaakt
- Werk `C:\Dev\CLAUDE.md` bij als er generieke afspraken veranderen die voor alle projecten gelden
- CLAUDE.md wijzigingen worden altijd meegenomen in de volgende git commit
- Dit zorgt ervoor dat een nieuwe sessie, een andere ontwikkelaar of een andere machine direct de volledige context heeft zonder verlies van kennis
- **Een CLAUDE.md mag opgesplitst worden in meerdere bestanden zodra hij te lang/onoverzichtelijk wordt** - vastgesteld door Roy op 22 september 2026 ("je mag CLAUDE.md opdelen in logische secties en verschillende bestanden... ik kan me voorstellen dat dit efficiënter werkt"), naar aanleiding van DtPrintServer7's CLAUDE.md die inmiddels ruim 2700 regels beslaat. Bij het opsplitsen: bestanden die inhoudelijk bij elkaar horen (bv. alles over één feature, of één architectuurthema) samen in een eigen map plaatsen, niet los naast elkaar in de projectroot. Het hoofd-CLAUDE.md van het project blijft bestaan als startpunt en verwijst met volledige paden naar de losse bestanden (zelfde principe als dit bestand al doet richting `programmer.md`/`dt7\CLAUDE.md`). Geen verplichting om dit nu overal meteen door te voeren - toepassen zodra een CLAUDE.md daadwerkelijk lastig te overzien wordt, niet preventief bij elk klein bestand. **Eerste toepassing (25 september 2026):** `C:\Dev\dt7\DtPrintServer7\CLAUDE.md` (toen ruim 3400 regels) is teruggebracht tot een startpunt van ongeveer 300 regels met een tabel naar thematische bestanden in `C:\Dev\dt7\DtPrintServer7\docs\claude\` (datamodel, impositie, api, interface-*, verwerkingsketen, printbatches, hosting-web); de bouwgeschiedenis van de impositie in DtLibs staat sindsdien in `C:\Dev\dt7\DtLibs\docs\impositie-bouwlog.md`. Tekst is daarbij ongewijzigd verplaatst, niet ingekort - dit is het voorbeeld voor een volgende opsplitsing.

## Git commit strategie

- Commit en push alleen bij **afgeronde, betekenisvolle stappen** — een compleet nieuw endpoint, een nieuwe feature, een configuratiewijziging die klaar is
- Niet committen na elke kleine iteratie of aanpassing
- Meld aan Roy wanneer iets commit-waardig is — hij heeft het laatste woord

## GitHub — Werkwijze

Ik ben relatief nieuw met Git en GitHub. Houd rekening met het volgende:

### Branch strategie
**Nu (bouwfase, één ontwikkelaar): alles direct op `main`/`master`** - vastgesteld door Roy op 30 september 2026: "commit en push de changes na iedere stap. Dat kan dan toch gewoon in de hoofd branch? We zijn nog aan het bouwen ... Ik ben nu ook de enige developer." Feature-branches voegen nu niets toe: ze zijn bedoeld voor review door anderen, parallel werk, of het beschermen van een stabiele `main` terwijl er al productie op draait. Geen van drieën geldt nu.
- Een plan wordt stap voor stap gebouwd; na elke afgeronde stap volgen een melding (wat er gedaan is, wat Roy kan testen) en een commit + push op `main`/`master`.
- Zodra een versie live gaat: een tag per live-versie (bv. `v7.1.0`).
- De strategie hieronder (`develop` + `feature/...`) komt terug zodra er een tweede ontwikkelaar bijkomt of een versie in productie draait.

**Later (meerdere ontwikkelaars / productie):**
- `main` — stabiele, werkende code (nooit direct op werken)
- `develop` — integratiebranch voor lopende ontwikkeling
- `feature/naam` — per feature of taak een eigen branch (bijv. `feature/helpdesk-login`)

### Stappenplan per feature (geldt pas weer bij "Later" hierboven)
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
