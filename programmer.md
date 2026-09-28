# programmer.md — Functies plaatsen: overloading, en binnen een applicatie of in een gedeelde library

Uitwerking van de "Ontwikkelprincipes" in `C:\Dev\CLAUDE.md` (die hiernaar
verwijst) - specifiek de vraag "waar hoort deze functie thuis, en moet dit een
nieuwe functie worden of een overload van een bestaande". Vastgesteld door Roy op
22 september 2026, in zijn eigen woorden:

> "Tijdens het ontwikkelen maak je functies aan in libraries en ook in de business
> layer. Je let steeds op of je daar geen duplicaten maakt van functies die
> bijvoorbeeld hetzelfde doen maar een andere set van parameters gebruiken. Je
> gebruikt dan overloading zodat de uitvoerende code maar 1 keer voorkomt. Dat is
> in C# een gebruikelijke manier van werken. Je streeft tijdens het programmeren
> het OOP-principe na. Daarmee behouden we een logische structuur in onze logica.
> Als functies binnen een applicatie blijven dan bouw je ze ook binnen die
> applicatie. Maar als blijkt dat je functies bouwt die in verschillende
> applicaties worden gebruikt omdat ze meer generiek zijn, dan bouw je ze in een
> library als een eigen dll. Als je denkt dat het zinvol is om een library aan te
> leggen dan overleg je dat met mij en motiveer je waarom je denkt dat het een
> goed idee is. Ik kan me ook voorstellen dat je kunt twijfelen, dan denk ik met
> je mee om een besluit te nemen."

## 1. Geen duplicaten — overload een bestaande functie in plaats van een nieuwe te schrijven

Kom je tijdens het ontwikkelen een functie tegen die al bestaat, maar net een
andere set parameters nodig heeft voor hetzelfde doel (bv. een `Id` in plaats van
een al geladen entiteit, of een extra optioneel veld)? Schrijf dan **geen tweede,
bijna identieke functie** — voeg een C# method overload toe, zodat de eigenlijke
uitvoerende logica maar op één plek in de codebase staat.

- Zoek eerst actief naar een bestaande functie met vergelijkbare functionaliteit
  vóór je een nieuwe schrijft (zoek op naam, doel, of het soort parameters dat
  een vergelijkbare berekening/actie al ergens anders gebruikt).
- Verschilt een gevonden functie alleen in de parameters, met hetzelfde
  achterliggende doel — voeg een overload toe die intern de bestaande, volledige
  variant aanroept, in plaats van de logica te dupliceren.
- Dit bouwt voort op de al bestaande, algemene principes in `C:\Dev\CLAUDE.md`
  ("Geen codeduplicatie" en "Method overloading") - dit document werkt vooral de
  plaatsingsvraag in punt 3 hieronder verder uit, die daar nog niet in stond.

## 2. OOP: logische structuur boven de snelste plek

Denk bij elke nieuwe functie na over welke klasse en welke laag er
verantwoordelijk voor hoort te zijn (encapsulatie, een heldere verdeling van
verantwoordelijkheden) - niet een functie toevoegen aan de dichtstbijzijnde of
toevallig al open klasse omdat dat op dat moment het snelst is. Een consistente,
logische structuur weegt zwaarder dan een paar regels besparen nu.

## 3. Binnen de applicatie, of in een gedeelde library?

De vuistregel die Roy hierboven gaf:

- **Blijft een functie gebruikt binnen één applicatie** (bv. alleen binnen
  `DtPrintServer7`) — bouw hem dan ook dáár, in de juiste laag (bijvoorbeeld de
  Business Layer - zie de dt7-brede afspraak "Altijd een Business Layer" in
  `C:\Dev\dt7\CLAUDE.md`). Niet alvast "voor de zekerheid" generiek opzetten of
  naar een library verplaatsen zolang er nog geen tweede toepassing is die 'm
  ook nodig heeft - dat is voorbarige abstractie.
- **Blijkt een functie generiek genoeg te zijn dat meerdere applicaties 'm
  nodig hebben** (bv. logica die zowel `DtPrintServer7` als een ander
  dt7-onderdeel gebruikt) — dan hoort hij in een gedeelde library, als eigen
  dll. Zie `C:\Dev\dt7\DtLibs\` (bijvoorbeeld `ABCPdfLib`) als bestaand
  precedent binnen de dt7-workspace voor hoe zo'n gedeelde library eruitziet.

## 4. Een nieuwe library aanleggen: altijd eerst overleggen met Roy

Een nieuwe gedeelde library (een heel nieuw dll-project — niet zomaar een nieuwe
klasse in een al bestaande library) wordt **nooit zelfstandig aangemaakt**. Eerst
overleggen met Roy, met een duidelijke motivatie:

- Welke applicaties hebben deze functionaliteit nodig (nu al, of concreet op
  afzienbare termijn)?
- Waarom hoort het niet gewoon in één van de bestaande applicaties of in een
  al bestaande library?

**Twijfel is een reden om te vragen, geen reden om te wachten of zelf te
beslissen.** Lijkt iets nu nog maar in één applicatie gebruikt te worden, maar
voelt het aan als generiek genoeg om dat snel te worden - leg die afweging dan
gewoon voor. Roy: "ik kan me ook voorstellen dat je kunt twijfelen, dan denk ik
met je mee om een besluit te nemen."

## 5. Vast patroon: "automatisch bepaald" vs. "handmatig overschreven"

Zodra een veld zowel automatisch door de applicatie bepaald kán worden, als
met de hand overschreven kán worden door een gebruiker, gebruik dan steeds
hetzelfde, herkenbare patroon in plaats van dit per geval opnieuw te bedenken
(vastgesteld 22 september 2026, na drie keer los toegepast te zijn in
DtPrintServer7: `PrinterAutoSelected`, `GrainAutoSelected`,
`BatchSequenceAutoSet`):

- De waarde zelf (bv. `Printer`/`PrinterId`, `Grain`) staat gewoon op de
  entiteit.
- Ernaast een losse `bool`-vlag `XxxAutoSelected`/`XxxAutoSet` die aangeeft of
  de huidige waarde automatisch bepaald is (`true`) of hard door een
  gebruiker gekozen (`false`).
- **Default hangt af van wat de normale eerste toestand is:** begint een
  nieuw record meestal zónder expliciete keuze (dus automatisch bepaald door
  de applicatie) - default `true`. Begint een nieuw record meestal mét een
  hard meegegeven waarde (automatisch bepalen is dan de uitzondering) -
  default `false`. Dit verschilt dus per veld; niet blind een van de twee
  defaults overnemen zonder na te denken over wat voor dít veld de normale
  eerste toestand is - en expliciet documenteren welke van de twee het is en
  waarom, zodat een latere lezer dit niet aanziet voor een kopieerfout.
- Elke automatische herberekening van de waarde (een achtergrondproces, een
  script, een opnieuw doorlopen pijplijnstap) **respecteert** een
  `false`-vlag - een hard gekozen waarde wordt nooit stilzwijgend
  overschreven. Kiest een gebruiker expliciet weer "Auto" (bv. via een
  dropdown-optie), dan gaat de vlag terug naar `true` én wordt de waarde
  meteen herberekend.
- Elke handmatige keuze via een UI-veld zet de vlag altijd hard op `false`,
  ook als de waarde toevallig gelijk is aan wat de automatische berekening
  ook zou hebben gekozen.

## 6. EF Core-migraties: vast controlelijstje

EF Core is een dt7-brede keuze (niet voor elk project onder `C:\Dev` per se
relevant), dus het volledige controlelijstje voor elke nieuwe migratie staat
in `C:\Dev\dt7\CLAUDE.md`, "Algemene afspraken voor alle dt7-projecten",
afspraak 10 - hier alleen de verwijzing zodat dit document zelf technologie-
neutraal blijft.

## 7. Structuurkeuzes tijdens het ontwikkelen: altijd samen overleggen

Merk je tijdens het ontwikkelen dat er een keuze gemaakt moet worden in de
structuur die je hanteert (bv. hoe een relatie tussen twee entiteiten
gemodelleerd wordt, welk ontwerppatroon je toepast, hoe een nieuwe feature over
klassen/lagen verdeeld wordt, of - zoals afspraak 3/4 hierboven - of iets een
gedeelde library wordt) - overleg dat dan met Roy, en bepaal sámen wat de beste
keuze is. Vastgesteld door Roy op 22 september 2026, letterlijk: "Als je
tijdens het ontwikkelen merkt dat je een keuze moet maken in de structuur die
je hanteert dan overleg je dat met mij en dan maak ik samen een besluit wat de
beste keuze is."

Dit is het bredere principe achter afspraak 3/4 hierboven (functies plaatsen,
nieuwe library aanleggen) - die zijn allebei een specifiek geval van deze
algemenere regel. Concreet betekent dit:

- Een structuurkeuze niet stilzwijgend zelf maken en pas achteraf melden ("ik
  heb het zo opgelost") - vooraf voorleggen, mét de overwogen alternatieven en
  een eigen voorkeur/motivatie, zodat Roy een geïnformeerd besluit kan nemen
  (niet alleen "wat wil je?" vragen zonder zelf al nagedacht te hebben).
- Geldt voor structurele/architecturale keuzes - niet voor elk triviaal
  implementatiedetail (een lokale variabelenaam, de volgorde van twee
  onafhankelijke regels code) waar geen redelijk alternatief tegenover staat.
  Twijfel je of iets structureel genoeg is om voor te leggen - leg het dan
  toch voor, zelfde principe als afspraak 4's "twijfel is een reden om te
  vragen, geen reden om zelf te beslissen".
