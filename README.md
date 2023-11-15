## Team

Aantal studenten: 1

Student 1: Jarne CLAESEN

## Titel app

LOJM

## Programmeertaal

Flutter

## Link naar filmpje

## Github link en branch

### Link

[Github link](https://github.com/PXLTINMobDev/opdracht-mobile-development-claesenjarne)

### Branch

*Vul hier de naam van de branch is waar de laatste versie van de code terug te vinden is.*

Branch: **main**

## Korte beschrijving

*Beschrijf hier in enkele zinnen wie de doelgroep van je applicatie is en welke functionaliteiten de app biedt.*

Deze app is bedoeld voor een jeugdorkest waar ieder lid een eigen account kan aanmaken. Zo kunnen er berichten geplaatst worden (met notificaties), partituren opgehaald worden en de dynamische kalender geraadpleegd worden die informatie weergeeft over het evenement / repetitie en of het lid al dan niet aanwezig moet zijn.
Bij het registreren moet het lid aanduiden welk instrument hij/zij speelt. Hiermee worden de juiste partituren getoont en ook de aanwezigheid via de kalender. In de database kan de beheerder leden een admin functie geven. Deze personen krijgen dan de mogelijkheid om de berichten en kalender te beheren.

## Minimale eisen

*Is er voldaan aan alle minimale eisen? Indien niet, licht dit hier kort toe. Een aantal zaken worden elders nog meer in detail toegelicht.*

Ja.

## Schermen

## Aantal schermen

Het aantal schermen in onze app bedraagt **9**

### Lijst van schermen

*Lijst hier de verschillende schermen van de app op:*

(voorbeeld)

* Login / registratie
* Home
* Calendar
* Event Details
* Event Form
* Profile
* Scores
* PDF Viewer

## Lokale opslag / Shared Preferences

*Beschrijf op welke manier lokale opslag werd aangepakt in de app*

Eerst en vooral heb ik shared_preferences geïmporteerd. Hiermee moet er een key aangemaakt worden om het dark/light theme op te slaan. De key heb ik 'theme' genoemd. met de setBool kan ik de key een boolean waarde geven: ```prefs.setBool(key, _themeData == darkTheme);``` waarmaa kan gekeken worden of het dark theme geselecteerd is. ```bool? isDark = prefs.getBool(key);``` haalt de boolean op.


## 

**

## Extra's

*Beschrijf hieronder de verschillende extra's die in je app aan bod komen, telkens in een aparte sectie*

### Extra 1

SnackBar

### Beschrijving extra 1

Via deze methode: 
```
void displayMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
```
  
kan een snackbar weergegeven worden. bv.: ```displayMessage(e.code);```

### Extra 2

LoadingCircle

### Beschrijving extra 2

Doorheen de hele app wordt bij het opvragen van data van de webservice gebruik gemaakt van een CircularProgressIndicator.

### Extra 3

Messaging

### Beschrijving extra 3

Op de home page kunnen berichten geplaatst worden. Als er een bericht wordt geplaatst, wordt dit gestuurd naar de Firestore Database. Een bericht kan ook geliked worden. Dat wordt in een array bij het bericht opgeslaan.

### Extra 4

Dynamic colors

### Beschrijving extra 4

Doorheen de app wordt gebruik gemaakt van dynamic theming via ```Theme.of(context).colorScheme```

### Extra 5

Animatie

### Beschrijving extra 5

Het darkmode/lightmode icoontje draait rond bij het veranderen. Dat gebeurt met ```AnimatedBuilder``` en ```Transform.rotate```.

### Extra 6

Localizations

### Beschrijving extra 6

Om widgets zoals timePicker en dataPicker in een andere taal en/of formaat te krijgen, moeten de locales veranderd worden. Dit heb ik veranderd naar nl, be.

### Extra 7

Temporary files

### Beschrijving extra 7

Bij het downloaden van de partituren, download ik naar de temp folder zodat bij het heropenen niet nog eens de database moet aangeroepen worden:

```
final Directory tempDir = Directory.systemTemp;
final File tempFile = File('${tempDir.path}/$pdfName');
```

### Extra 8

Download via flitter_file_dialog

### Beschrijving extra 8

Een download functie om de partituur via een button te downloaden naar lokale opslag. Ook hier komt de download van de temp file.
Vanaf Android 13 zijn de permissions veranderd en kan er niet zomaar permissie gevraagd worden naar external storage. De FileDialog is de nieuwe manier om bestanden gemakkelijk op te slaan.

```final pickedDirectory = await FlutterFileDialog.pickDirectory();```

```
await FlutterFileDialog.saveFileToDirectory(
          directory: pickedDirectory,
          data: fileData,
          mimeType: "application/pdf",
          fileName: fileName,
          replace: false,
        );
```

### Extra 9

Push notifications

### Beschrijving extra 9

Voor realtime notifications heb ik gekozen voor Onesignal. Dit dient dan als backend voor de notification service.

Om ervoor te zorgen dat de zender geen notificatie krijgt, moet ik eerst alle playerId's ophalen via ```fetchAllPlayerIdsFromOneSignal()``` en dan de senderplayerId eruit filteren. Dan wordt er een post gestuurd naar Onesignal (als de gebruiker een bericht stuurt) met de nodige informatie (app_id, include_players_ids, headings, contents).

### Extra 10

App branding

### Beschrijving extra 10

De app gebruikt het logo van het orkest op de nodige plaatsen. Ook de app icon (inclusief material you theming).

### Extra 11

Forgot password

### Beschrijving extra 11

Firebase stuurt een mail naar het ingegeven mailadres om het wachtwoord te veranderen.

## Ondersteuning landscape en portrait / correct gebruik van Fragments

Ondersteunt de app zowel landscape als portrait mode? Wordt er correct gebruik gemaakt van Fragments? Beschrijf kort wat de stand van zaken is en hoe dit gerealiseerd werd.

De app ondersteunt landscape en portait. Voor de lijst met partituren kijk ik of het landscape is via: ```MediaQuery.of(context).orientation == Orientation.landscape;```
Als dat het geval is, dan gebruik ik een Row met twee Expanded widgets zodat de lijst links staat en de pdf rechts.

## Web service / API

*Beschrijf hier van welke web service / API er gebruik gemaakt wordt, indien van toepassing. Dit kan bijvoorbeeld ook Firebase zijn.*

Ik gebruik Firebase. Hiervan gebruik ik Authentication voor users, Firestore Database voor users, events en messages en Storage voor partituren. 

## Extra informatie

*Als er nog bepaalde informatie nuttig is om toe te voegen, is daar hier ruimte voor. Je wil bijvoorbeeld aangeven dat bepaalde zaken niet werken zoals voorzien, of niet helemaal zijn afgeraakt. Of je weet dat er nog een bepaalde bug in de code zit die je niet tijdig opgelost kreeg.*
