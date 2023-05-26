# Serverless and Application Services
### Architecture Deep Dive Part 1
- Event-Driven Arhitektura -> bitno je poznavati osnovne tipove arhitektura kako bi mogli kreirati rjesenje za neki projekat 
- ### Monotolithic arhitketura
- Historijski gledano, najpoznatija sistemska arhitektura je poznata kao monotlina arhitektura
- Za primjer opisa ove arhitketure, pricamo o CatTube platformi za posztavlajnje videa razlicitih kvaliteta. Kako bi sto bolje objasnili primjer arhitekture, zamislit cemo da se radi u black box-u u kojem su poredane komponente 
![Screenshot 2023-05-22 at 14.42.34.png](Task-10-img/Pasted%20image%2020230522230144.png)
- Ova arhitektura ima nekoliko "problema"
	- Obzirom da se radi o jednoj cjelini, citava arhitektura pada kao cjelina, u prijevodu ako jedna komponenta zakaže, cijeli sistem neće funkcionisati na nacin kako bi trebalo. 
	- Svaka od konmponenti ove cjeline skalira zajedno jedna sa drugom, jer su povezane. Sve komponente ocekuju da se nalaze zajedno na jednom serveru dikretno povezane. Nije moguce jednu komponentu sklirati pojedinacno. 
	- Sve komponente ove arhitekture su uvijek aktivne i running, i upravo zbog toga neprestano prave troskove na AWS racunu. Iako konkretno Processing komponenta ne radi trenutno nista, 0/24 su alocirani resursi i upravo je to razlog sto se sve komponente naplacuju. Ovo je razlog zasto je ova arhitketura najmanje isplativa
- ### Tiered arhitetkura
- Spominjemo tiered arhitekturu u kojoj se slojevi monolitne arhitekture razdvajaju u vise slojeva. Kopmonente mogu biti na jednom serveru ili razlicitim
- U ovoj arhitketuri, komponente su i dalje povezane jedna sa drugom i svaki sloj arhitketure je povezan endpointom sa drugim redom ili slojem arhitekture
![Pasted image 20230522145910.png](Task-10-img/Pasted%20image%2020230522145910.png)
- Jedna od najvecih prednosti tiered arhitekture u odnosu na monotlitnu je ta sto slojevi arhitekture mogu da neovisno skliaraju horizontalno, u prijevodu ako nam zatreba kapacitet za processing sloj mozemo dodati jos jednu instancu
- Dodatno mozemo poboljsati ovu arhitketuru tako sto veza izmedju slojeva arhitketure biti load balancer. Upravo zbog load blanacera, mozemo vrlo jednostavno dodati jos jednu instancu dodati, i na taj nacin povecati kapacitet jednog sloja, bez povecanja ostalih slojeva arhitetkure.
- Na ovaj nacin smo postigli i visoku dostupnost slojeva
- Mane ove arhitketure 
	- Slojevi aplikacije su i dalje povezani jedni sa drugim, npr. upload sloj ocekuje i zahtjeva da processing sloj postoji i odgovara na requste. Ako processing sloj zakaže ili uspori u radu, to takodjer utice na rad ostlaih slojeva.
	-  Iako nema procesa u pozadini, slojevi moraju biti aktivni i ne mogu se skalirati do nule

### Architecture Deep Dive Part 2
- #### Queue Arhitektura
- Prethodna arhiktetura (Tiered arhitketkura) se moze dodatno unaprijediti koristenjem nizova (queues)
- Queue ili niz je sistem koji prima prouke koje su mu poslane od korisnika ili nekog servisa unutar AWS. Dalje se te poruke izvlace iz niza i prosljedjuju druigm servisima.
- U mnogim nizovima postoji redoslijed u kojima postoji FIFO arhitektura (First In First Out), iako ne mora zanciti da niz koristi ovu vrstu arhitekture za primanje i posljedjivanje poruka
-  Do sada je bio slucaj da upload komponenta prosljedjuje odmah drugoj komponenti sadrzaj koji je uploadovan, ali zahvlajujuci ovoj arhitekturi, komponente su u potpunosti razdvojene i ne zavise jedna od druge, a to je postignuto na nacin da upload komponenta prosljedjuje sadrzaj na s3 bucket i u queue salje poruku o informacijama koje su potrebne (gdje je pohranjen uploadovan sadrzaj idruge info) -> queue je razdvojio komponente i upload komponenta u ovom slucaju ne ocekuje instant odgovor od neke druge komponente; upload komponenta je zavrsila svoj posao
- Upload komponenta u ovom slucaju koristi async komunikaciju gdje salje poruku u queue i u pozadini ceka za novi upload
- U pozadini arhitetkure je postavljena Auto Scaling grupa koja je pocetno postavljena na min: 0, desired: 0 i max: 1337 EC2 instanci i trenutno nema pokrenutih EC2 instanci ali ima ASG policy koji pokrece ili terminira instance na osnovu duzine niza. Obzirom da postoje poruke u queue-u, ASG pokrece instance i poruke se dodjeljuju pokrenutim instancama. 
- Dodjeljene instance imaju infrmacije o procesu koji se treba izvrsiti ali i takodjer lokaciju gdje je sadrzaj pohranjen kako bi mogli izvrsiti download sadrzaja sa S3
- Zahvaljujuci ovoj arhitetkuri, razdvojili smo komponente aplikacije i jedna od komponenti radi svoj posao neosvisno od drugih komponenti, i ne komuniciraju dirketno 
- Takodjer smo rijesili problem skaliranja prema dole, u prijevodu ako nema potrebe za pokrneutim instancama, iste se mogu brisati da ne prave bespotrebne troskove
![Pasted image 20230522204454.png](Task-10-img/Pasted%20image%2020230522204454.png)
- #### Microservice arhitektura
- Ova arhitketura je kolekcija mikroservisa i mikroservisis rade individuano posao veoma dobro 
- U nasem primjeru, postoji upload mikroservis, processing mikroservis i sotre and menage mikroservis
	- Upload mikroservis je producer, proizvode poruke koje se dalje obradjuju 
	- Process mikroservis je consumer, koristi poruke koje su kreirane i obradjuje ih 
	- Store and menage mikroservis je i jedno i drugo, ovaj mikroservis moze raditi i jedno i drugo 
	- Stvari koje produceri i conusmeri konzumiraju arhitekturalno se nazivaju eventi
- Queue sluzi kao komunikacija izmedju evenat
- Obzirom da se mikroservice ahtitketura moze brzo uslozniti sa velikim brojem mikroservisa, koristeci queue-s u arhitekturi bi bilo previse slozeno i komplikovano
- Mikroservis je mali dio aplikacije koji ima svoju logiku, svoju pohranu podataka kao i input i output komponente
![Pasted image 20230522204635.png](Task-10-img/Pasted%20image%2020230522204635.png)
- #### Event-Driven arhitektura
- kolekcija event producera i event consumera
- event produceri mogu biti komponente neke aplikacije koji dirketno komuniciraju sa korisniskom aplikacije, ili mogu biti dio infratrukture (EC2), u prijevodu event produceri su dijelovi softvera koji generisu ili proizvode evente na reakciju na nesto 
	- Event bi mogao biti klik korisnika na neko dugme SUBMIT
	- Event bi mogao biti odgovor aplikacije na neki error
	- Prodceri su stvari koje proizvode evente
- Event konusmeri mogu biti dijelovi softvera koji cekaju da se event pojavi, ako vide event da se pojavio, pokrece se njihova akcija (to bi mogao biti neki prikaz korisniku ili mozda ponovni pokusaj uploada)
- Komponente unutar ove arhitketure mogu takodjer biti i produceri i konsumeri 
	- Neke kompoinente mogu u isto vrijeme izvrsiti event npr. neuspjesan upload i onda koristiti evente da se proba ponovni upload 
- Kljucna stvar kod Event Driven arhitketure jeste da ni proizvodjaci ni korisnici evenata ne trose resurse uzlaud
- Ako bi svaka komponenta aplikacije trebala imati queue jedna izmedju druge i svaka druga komponenta da postavlja evente u queue, bila bi to veoma slozena arhitektura. Upravo zbog toga Event Driven Arhitektura ima nesto sto se zove Event Router
- Event Router je rasporedjivac evenata koji ima nesto sto se zove event bus. Event bus mozemo posmatrati kao konstanti flow informacija. Kada proizvodjaci kreiraju event, isti se postavlja u event bus i event router dostavlja event iz event busa nekom od event korisnika
- Event Driven arhitketura koristi resurse kada se javlja potreba za time. 
	- Imamo prozvodjace evenata koji proizvode neki event baziran na nekom dogadjaju (klik na neko dugme, error u qplikaciji, upload necega)
	- Event router prosljedjuje evente korisinicma evenata i nakon toga, sistem se vraca u stanje cekanja (ponovnog kreiranja evenata i daljih postupaka)
![Pasted image 20230522204827.png](Task-10-img/Pasted%20image%2020230522204827.png)

### AWS Lambda - PART1
- Lambda je FaaS -> Function as a Service 
- Ovom servisu pravimo specijalizirani kod i ovaj servis pokrece kod i naplacuje se samo period koliko je trajalo izvrsavanje koda 
- Lambda funkcija je komad koda koji Lambda kao servis pokrece
	- Svaka Lambda funkcija koristi runtime (verzija programskog jezika)
	- Lambda funkcija se pokrece unutar runtime enviroment-a za runtime koji smo prethodno odabrali za koristenje
- Kod lambde kao servisa je bitno zapamtiti da ce nam biti naplaceno onoliko koliko lambda funkcija bude trajala odnosno njeno izvrsavanje
- Lambda je kljucni dio za Serverless arhitekturu 
- Lambda funkciju mozemo posmatrati kao dio koda koji smo postavili unutar nje + sva sotala konfiguracija i "zipovanje"
	- Lambda funkcija je deployment package koji lambda pokrece 
Svaki put kada se Lambda "okine", pokrece se Lambda funkcija kreiran je novi runtime enviroment sa svim potrebnim komponentama koje Lambda funkcija treba (verzije programskog jezika), a nakon zavrsetka funkcije runtime enviroment se terminira. Iduci put se ponovno kreiran novi enviroment
- **BITNO:** 15 minuta je maximum koliko bi se trebala Lambda funkcija izvrsavati. 
- Security za Lambda Funckije je kontrolisan koristeci executon roles i to su IAM role i u ovo se ukljucuju dozvole za Lambda funkcije kako bi mogla komunicirati sa ostalim servisima unutar AWS-a
- Zakljucak:
	- Temelj serverless aplikacija 
	- File Processing 
	- Trigeri za koristenje baza podataka 
	- Implementacija CloudWatch-a unutar Lambda funkcija 
	- Realtime Stream Data Processing -> Lambda se moze okinuti svaki put kada je sadrzaj dodan na Kinesis Stream
### AWS Lambda - PART2
- Lambda ima 2 networking moda a to su Public (Default) i VPC Networking
- Za primjer Public Network moda (napomena: Public Network mode je defaultna konfiguracija) Lambda je postavljena unutar AWS Enviromenta pored VPC-a  i komunicira slobodno sa ostalim servisima koji su postavljeni unutar public AWS okruzenja kao i sa web stranicama koje se nalaze na public internetu, osim onih servisa koji se nalaze unutar VPC-a. Ovaj nacin koristenja Lambde (preko public networkinga) je najbolji za koristenje i najefektivniji je.
- Bitno je napomenuti da Lambda koja je postavljena unutar public AWS okruzenja nema pristup servisima koji se nalaze unutar VPC-a, osim ako security VPC-a nije postavljen tako da se moze pristupiti. 
![Pasted image 20230522230144.png](Task-10-img/Pasted%20image%2020230522230144.png)
- Lambda se moze podesiti da se nalazi unutar VPC-a i da se nalazi u privatnom subnetu zajedno sa ostalim resursima koji su unutar tog VPC-a i private subneta. U ovom slucaju je bitno napomenuti da Lambda funkcije, kao i svi ostali ostali resursi u ovom okruzenju, moze slobodno komunicirati sa ostalim resursima. Takodjer je bitno napomenuti da je pristup resrsima izvan VPC-a za Lambda funkcije onemogucen. U ovom scenariju bismo mogli korsititi Gateway Endpoint unutar private subneta kako bi omogucili pristup resursima izvan VPC-a. Takodjer u slucaju ako zelimo omoguciti pristup Lambda funkcijama public internetu i public aws okruzenju, mozemo konfigurisati NAT Gateway u public subnetu i zakaciti Internet Gateway za VPC. 
![Pasted image 20230522230117.png](Task-10-img/Pasted%20image%2020230522230117.png)
- Potrebno je dati Lambda funkcijama EC2 network permisije preko execution rola. Zbog toga sto Lambda servis treba kreirati network interfejs unutar VPC-a. Sto se tice networking konfiguracije, AWS analizira sve funkcije koje se pokrecu unutar regiona jednog acc ipostavlja se set unikatnih kombinacija subneta i security grupa. Npr. ako sve lambda funkcije iz vise subneta koriste jednu SG, u tom slucaju jedan network interface je potreban po subnetu 
- #### Security za Lambda funkcije
- Kada je u pitanju sercurity za Lambda funkcije potrebno je pomenuti Lambda execution role, a to su zapravo IAM role dodijeljene lambda funkcijama kako bi mogle komunicirati sa ostalim servisima
- Lambda takodjer ima resource policy koji kontrolise pristup Lambda funkciji od strane nekih servisa koji se nalaze u drugim accountima
- #### Logging
- Bilo koji logovi ili informacije ili errou koji se stvaraju tokom pokretanja Lambda funkcija se pohranjuju unutar CloudWatchLogs. 
- Metrike, u prijevodu detalji okidanja lambda funkcije, uspjesna i neuspjesna okidanja, ponavljanja, se poohranjuju unutar CloudWatch-a
- Lambdi je potrebno dozvoliti pristup odnosno permisije CloudWatchLogovima, kako bi se logovi mogli spremati unutar CloudWatchLogs

### AWS Lambda - PART3
- Postoje 3 metode na koji nacin se moze pokrenuti ili okinuti Lambda funkcija 
	- Synchronous invocation
	- Asynchronous invocation
	- invokacija koristeci Event Source Mappings
- #### Synchronous invocation
![Pasted image 20230522232714.png](Task-10-img/Pasted%20image%2020230522232714.png)
- Kada je u pitanju ovaj nacin invokacije, okidanje zapocinjemo u terminalu ili koristeci API, tako sto unosimo komandu za to. Lambda se pokrece koristeci kod. Terminal ili API ce sve vrijeme dok se lambda funkcija izvrsava cekati za response funkcije
- Takodjer sinhrona invokacija se koristi u slucajevima preko API Gateway-a
- Glavna osobina sinhrone invokacije jeste sto klijent u bilo kojem slucaju ceka za response koji ce Lambda funkcija dati. Errori koji se dese tokom pokretanja Lambda funkcije se rjesavaju na klijentskoj strani.
- #### Asynchronous invocation
![Pasted image 20230522234011.png](Task-10-img/Pasted%20image%2020230522234011.png)
- Ova vrsta pokretanja lambda funkcije se koristi kada AWS servisi pokrecu Lambda funkciju. Npr. Postavili smo sliku na S3 bucket. Podeseno je da S3 bucket pokrece event koji se salje Lamdbi i pokrece se Lambda funkcija. S3 u ovom slucaju ne ceka nikakav response. 
- U ovom slucaju asinhrone invokacije, Lambda je odgovorna za bilo kakav proces ponavljanja u slucaju ako se javi greska u eventu koji je trigger za lambda funkciju. Lambda ce se sama pokrenuti ponovno.
- Ako nakon ponavljanja procesa pokretanja lambda funkcije ne uspije se izvrsiti invokacija, event se salje u Dead Letter Queue, kako bi se mogao dijagnosticirati problem. 
- #### Event Source Mapping
![Pasted image 20230523002858.png](Task-10-img/Pasted%20image%2020230523002858.png)
-  Ovaj nacin invokacije se koristi u slucajevima kada se koristi streamovi ili queues koji ne generisu evente. 
- Primjer: Produceri postavljaju materijal ili sadrzaj na Kinesis Data Stream. Kinesis Data Stream je stream-based produkt, koji korisnicima pruza usluge citanja streamova, ali ovaj produkt ne pravi evente kada se podaci dodaju na njega. U ovom slucaju ovo nije idealno okruzenje za Lambdu jer je ona bazirana na eventima kao svojim okidacima. Zbog toga imamo u pozadini komponentu koja se zove Event Source mapping. Event Source Mapping izvlaci iz Kinesisa "batches" i to salje kao event lambdi. U ovom slucaju lmbda bi mogla primiti stotine evenata, ali zavisi od toga koliko svaki event bude trajao. 
- U ovom nacinu invokacije izvorni servis ne dostavlja event, nego event source mapping sluzi za citanje sa izvornog servisa. U to mslucaju Event Source Mapping koristi permisije za Lambda execution role
- SQS ili SNS topici se mogu koristiti za eventualne ponovljene "batcheve" koji su neuspjesno pokusavali da triggeruju Lambdu
- #### Lambda Verzije
- Moguce je da imamo vise verzija Lambda funkcija
- Kada je rijec o verziji Lambda funkcije, misli se na kod unutar Lmabda funkcije + konfiguracija lambda funkcije. 
- Kada se deploy-a verzija lambda funkcije, nije moguce vise mijenjati
- Takodjer postoji koncept pod nazivom $Latest, koji upucuje na zadnju verziju lambda funkcije i ovo je promjenljivo tako da uvijek alocira na zadnju verziju lambda funkcije
- Takodjer mozemo kreirati alijase koji ce alocirati na odredjene verzije lambda funkcija i takodjer se mogu mijenjati
#### Lambda Startup times
- Lambda funkcija zajedno za kodom i svom ostalom konfiguracijom se pokrece unutar runtime enviromenta kojeg mozemo zamisliti kao container koji skuplja sve resurse koji pokrecu Lambda funkciju 
- Pri prvom pokretanju lambda funkcije, pomenuti runtime enviroment se mora kreirati i konfigurisati i to uzima vrijeme. Ovaj prvi proces postavljanja i konfigurisanja svega sto je potrebno se zove cold start. Citav proces traje duze nego sto bi trebalo radi downloada deployment paketa i verzije runtime-a. 
- Ako se ista lambda funkcija pokrene u skorijem roku bez velikog vremenskom razmaka, moze korisitti vec postavljeni runtime enviroment kako se ne bi morao raditi ponovni download svih neophodnih alata i ovaj proces se zove warm start.

### CloudWatchEvents and EventBridge
- EventBridge je servis unutar AWS-a koji je sistem za evente i ovi eventi pisuju promjene AWS servisa 
- Npr. EC2 je servis koji je podrzan za EventBridge. EC2 nakon sto je pokrenuta ili terminirana pravi event koji se salje EventBridgu
- EventBridge ima mogucnost da handle-a evente od third-party aplikacija ili od custom aplikacija.
- EventBridge sadrzi event bus sto predstavlja niz evenata iz kojeg eventbridge "izvlaci" evente i preusmjerava ih na druge lokacije koje mi podesavama, npr. prema lambdi i ovo moze biti trigger za lambdu
- Eventi nisu nistra drugo nego JSON formatirane infomracije o tome koja se promjena desila kod kojeg tacno servisa i eventualno neke dodatne info kao sto je vrijeme desavanja promjene itd. ![Pasted image 20230523125738.png](Task-10-img/Pasted%20image%2020230523125738.png)
### DEMO: Automated EC2 Control using Lambda and Events - PART1
- U ovoj lekciji cemo raditi pratkicno sa Lambda funkcijama, kojece konkretno pokreatiti i terminirati EC2 instance
- Prvi korak ce biti da Lambda servisu dodamo rolu koja joj dozvoljava startanje i zaustavljanje EC2 
	- Prvo cemo unijeti custom menaged policy koju smo dobili u video materijalima i zatim taj policy upotrijebiti za kreiranje execution role
- U nastavku kreiramo lambda funkciju
	- naziv funkcije 
	- odabir runtime -> verzija programskog jezika
	- permisije -> odabir postojece permisije koju smo prethodno kreirali 
- Nakon sto smo kreirali lambda funkciju, postavljamo kod lambda funkcije unutar dijela za kod
- Kreiramo enviroment varijablu (pozeljnaradi sigurnosnih razloga, kako ne bi neka informacija bila zloupotrbeljena unutar koda lambda funkcije) -> sadrzaj EV je instance ID i od jedne i od druge EC2
- Pokrecemo test lambda funkcije i dobijamo success kao execution rezultat
- Pravili smo dvije lambda funkcije za pokretanje i terminiranje instanci, postupak je isti u oba slucaja
### DEMO: Automated EC2 Control using Lambda and Events - PART2
- Kreirali smo jos jednu lambda funkciju, sa zasebnim kodom, ali ovog piuta nismo kreirali enviroment vaijablu jer nema potrebe za njom 
- Iduci korak je bio kreiranje pravila u servisu EventBridge
	- Postavljamo AWS events kao event source
	- Event pattern
		- AWS services -> EC2
		- Event type -> EC2 Instance State-change Notification
		- Specific state -> stopped 
		- Specific isntance id -> kopiramo id instance za koju zelimo da se lambda pokrene 
	- Sample events -> ec2 Instance state change notification (generise se primjer eventa koji ce se generisati kada ec2 instanca promijeni stanje)
- Kreirano pravilo u nutar EventBrridga ce poslati event lambda funkciji za koju smo odredili da bude ciljni target, i lambda funkcija ce se pokrenuti onog trenutka kada se event kreira, unasem slucaju, od strane EC2 i EventBridge prenese taj event lambda funkciji kao trigger
- Drugi dio lekcije ukljucuje konfiguraciju EventBridga gledajuci vrijeme kada ce se taj event kreirati i samim tim pokrenuti lambda funkciju; nakon sto odaberemo opciju schedule za rule type (pazimo da vrijeme gledamo za UTC vremesnku zonu), ostatak procesa postavljanja pravila u eventbrdigu je isti
### Serverless Architecture
- Serverless arhitketura je veoma poznata i veoma koristena arhitketura unutar AWS-a jer konkretno AWS ima dosta servisa i produkata koji su bazirani na serverless arhitketuri 
- Serverless arhitketura (ako bi moglo biti zabune zbog naziva) u svojoj pozadini koristi servere
- Serverless arhitketura je vise software nego hardware arhitektura u kojoj postavjalmo sto manje servera. Serveri su podlozni greskama, troskovima i potrebno je vrsiti administraciju
- Unutar Serverless arhitketure aplikacija je podijeljena na veoma male dijelove, kolekciju malih i specijlaziranih funkcija
- Prednost Serverless arhitketura je ta sto koristi najvise Lambda funkcije koje su skalabilne, u prijeovdu ne trose puino resursa i ne prave velike troskove jer se pokrecu po potrebi i kada zavrse svoj posao, vracaju se u stanje mirovanja. Nista unutar ove arhitketure ne crpi resurse ako nema potrebe za tim.
- Serverless arhitketura koriste FaaS -> lambdu koja se sadrzana od veoma malo koda
![[Screenshot 2023-05-23 at 22.46.02.png]]
- Jedan od primjera kako moze izlgedati Serverless arhitketura
### Simple Notification Service
- Visoko dotupan i siguran pub-sub servis za poruke
- Potrebna nam je network konekcija sa javnim AWS endpointima
- Ovaj servis je zaduzen za koordiniranje slanja i primanja poruka 
- Poruke za koje se ovaj servis brine su velicine do 256KB
- Bazni entitet ovog servisa su SNS Topici gdje se najvise konfiguracije i postavlja zajedno sa postavkom permisija
- Publisher je neko ili nesto sto salje poruku u Topic
- Svaki Topic moze imati svoje subscribere koji primaju sve poruke koje su poslane u Topicc 
- ![Screenshot 2023-05-23 at 23.27.49.png](Task-10-img/Screenshot%202023-05-23%20at%2023.27.49.png)
- SNS pruza delivery status -> status poslane poruke subscriberima
- Delivery retries -> ponavljanje slanja poruke
- Visokodostupan servis
- Takodjer se poruke koje moraju biti sacuvanu na nekom disku mogu enkriptivoati 
- Ovaj servis se moze koristiti u vise aws racuna postavljajuci Permisije 
### Step Functions
- Kako bi obradili Stp funkcije, moramo se upoznati sa problemima koje Lambda funkcija konkretno ima. 
	- Ono sto nikad ne bi trebal iraditi sa Lmabda funkcijama jeste da postavimo citavu aplikaciju unutar Lambda funkcije
		1. Losa praksa
		2. Lambda funkcija ima limit trajanja od 15 minuta
		- U toeriji bi se moglo povezati vise lambda funkcija kako bi dobili na vremenu izvrsavanja, ali se to moze poprilicno zakomplikovati, najvise radi prijenosa podataka izmedju podataka jer svaki put kada se lambda pokrene, pokrece se novi runtime enviroment 
- Step funkcije nam dozvoljavaju da kreiramo nesto sto se naziva state machines. State machine mozemo zamisliti nesto kao tok rada; nesto sto ima pocetnu, krajnju tacku i izmedju toga se nalaze stanja. STanja mogu raditi stvari, odlucivati o stvarima, modigikovati podatke, raditi input i ouptut informacija itd itd
-  Zbog situacija kada neka stanja mogu potrajati u svojoj izvedbi, maximalna duzina trajanja State machines je 1 godina
- Dva tipa toka rada State Machine
	- Standard -> defaultni state machine i traje godinu dana 
	- Express -> koristi se za velike i teske procese, Mobile App beckends  
- IAM Role se koriste za permisije State Machines
- TIpovi States (stvari koje se izvrsavaju)
	- Succeed & Fail state -> proces koji prolazi kroz State Machine je ili uspjesan ili nije
	- Wait State -> ovaj state ce cekati odredjeno vrijeme ili ce cekati do odredjenog vreenskog trenutka i pauzira tok rada state Machines
	- Choice je state ili stanje koje dozvoljava vise izbora u toku izvrsavanja state Machine
	- Parallel state dozvoljava da kreira dva simultana stanja
	- Map state podrazumijeva listu stvari. Za svaku od tih stvari u listi se izvodi neka akcija
![Screenshot 2023-05-24 at 00.35.06.png](Task-10-img/Screenshot%202023-05-24%20at%2000.35.06.png)
### API Gateway
-  API Gateway je servis koji nam omogucava kreiramo i upravljamo sa API-jima
- API je Application programming interface koji nam sluzi za komunikaciju izmedju aplikacija (ako koristimo Netflix na TV-u, koristi se API kako bi komunicirao sa Netflix-ovim backendom )
- API Gateway se ponasa kao endpoint za alikacije koje trebaju komunicirati sa nasim servisima
- Arhitekturalno se nalazi izmedju aplikacija sa kojima komuniciramo i servisima koje koristimo unutar AWS okruzenja
- API Gateway sadrzi autorizaciju, throttling caching (keshiranje informacija u cilju smanjenja broja API poziva), CORS (Zastita i provjera request prije negoi se pravi proslijedi) itd 
- Ovaj servis pruza API-je koji koriste HTTP, REST ili Websockets
- ![Screenshot 2023-05-24 at 15.25.33.png](Task-10-img/Screenshot%202023-05-24%20at%2015.25.33.png)
- Tipovi Custom DNS EndPoint-a
	- Edge Optimized -> ovaj DNS Endpoint se salje najblizoj ClouFront-i
	- Regional -> Kada su klijenti u istoj regiji i ne koristi se CloudFront
	- Private -> dostupni samo unutar VPC-a
- API stage-vi 
	- API-jevi se deployaju na tzv Stage i svaki stage ima svoj unikatni URL (na kraju API Gateway-a se postavlja naziv za stage)
	- Svaki stage ima svojuu verziju aplikacije i pogodno je za testiranje aplikacije

### Build A Serverless App - Pet-Cuddle-o-Tron - PART1
![Screenshot 2023-05-24 at 16.42.21.png](Task-10-img/Screenshot%202023-05-24%20at%2016.42.21.png)
- Arhitektura Serverless aplikacije koju cemo na kraju koristiti
- U PART1 cemo raditi konfiguraciju SES (Simple Email Service)
	- Konfiguracija SES po defaut-u zapocinje sa default modom. U prijevdu ovaj mod znaci da moramo eksplicitno postaviti email adrese koje cemo koristiti. Ovaj mode nije inace ukljucen u realnim projektima, ali za potrebe ovog testiranja, radit cemo u sandbox modu.
	- Postavljamo dvije email adrese unutar SES, i te dvije email adrese cemo koristi iza slanje/primanje email-a.
### Build A Serverless App - Pet-Cuddle-o-Tron - PART2
- Postavljanje IAM Role kroz CloudFormation za Lambda funkciju da moze koiristiti servise SES i SNS i da moze slati logove CloudWatch-u
- Postavka Lmabda funkcije kroz konzolu
ARN LAMBDA FUNKCIJE: arn:aws:lambda:us-east-1:619005656233:function:email_reminder_lambda
### Build A Serverless App - Pet-Cuddle-o-Tron - PART3
- U pocetku smo kreiraili Permisije sa state machine kako bi mogli dozvoliti pokretanje Lambda funkcije i svu komunikaciju sa SNS servisom
- Konfigurisemo state machine koji se postavlja unutar Step funkcija
![Screenshot 2023-05-24 at 21.41.00.png](Task-10-img/Screenshot%202023-05-24%20at%2021.41.00.png)
- State Machine arn: arn:aws:states:us-east-1:619005656233:stateMachine:PetCuddleOTron
- Nakon sto kopirali json kod za state machine, u nastavku se podesava naziv i postavke za logove
### Build A Serverless App - Pet-Cuddle-o-Tron - PART4
- Kreiramo jos jednu Lambda funkciju koja ce komunicirati sa API Gatewayom
- Postupak kreiranja API Gateway-a
### Build A Serverless App - Pet-Cuddle-o-Tron - PART5
- Postupak kreiranja S3 Bucket-a koji ce biti staticki host za frontend nase aplikacije 
- Povezivanje API Gateway-a sa .js fil-om nase aplikacije koja ce ici na s3
- Testiranje aplikacije

### Build A Serverless App - Pet-Cuddle-o-Tron - PART6
- Ciscenje resursa koji su kreirani 
### Simple Queue Service
- Servis koji pruza nizive poruka (queue)
- Postoje dva tipa redova ili nizova poruka
	- Standard -> moze se desiti ponavljanje poruka, redoslijed nije onakav kakav bi trebao biti 
	- FIFO -> zagarantovan redoslijed, bez ponavljanja poruka
- Queue funkcionise na nacin da klijent sa jedne strane postavlja poruke a sa druge strane klijent provjerava ima li poruka
- Nakon sto se pregledaju poruke, one se ne brisu nego su skrivene (VIsibilityTimeout) -> VisibilityTimeout je period vremena koliko klijent moze uzeti vremena da obradi poruku na neki nacin
- Ako poruka nije izbrisana od strane korisnika nakon sto je pregledana i nakon sto je period VisibilityTImeout prosao, poruka se opet pojajvljuje
- Takodjer postoji Dead Letter Queue termin koji je takodjer queue u koji se smjestaju poruke koje imaju neki error ili je potreban drugaciji pristup konfiguriacije te poruke
- ASG mogu skalirati ili se Lambda moze pokretati na osnovu duzine Queue.
-  ![Pasted image 20230525180728.png](Task-10-img/Pasted%20image%2020230525180728.png)
- Arhitektura jedne aplikacije u kojoj queue cilj ima da razdvoji dva dijela aplikacija i da se neosvisno auto scaling grupe skaliraju nq osnovu duzine queue-a
- ![Screenshot 2023-05-25 at 18.09.23.png](Task-10-img/Screenshot%202023-05-25%20at%2018.09.23.png)
- Arhitekutra aplikacije koja koristi SQS i SNS Fanout (scenarij sa vise "subscribera" za jedan topic; u ovom lsucaju "subscriberi" su queues)
- Vrste Queue
	- Standard -> ovaj queue garantuje bar jednu dostavu porukei. nema garancije za redoslijed, skalirnaje je neograniceno
	- FIFO -> ovaj queue garantuje samo jednu dostavku poruke i redoslijed poruka je zagarantovan, skaliranje je ograniceno do 3000 poruka
- Billing se obracunava na requestovima, koji mogu primati od 1 do 10 poruka, a mogu vratiti i 0 poruka
- Postoje dva nacina za polling SQS-a
	- Short Polling -> koristi 1 request i moze primiti 0+ poruka
	- Long Polling -> mozemo specificirati vrijeme cekanja da se poruke nakupe u queue i na taj nacin ce se koristiti manje request-ova i samim tim manje naplatiti
- Queue policy korisitmo ako je potreban pristup sqs-u van naseg aws racuna
### SQS Standard vs FIFO Queues
- FIFO
	- FIFO podrzava 3000 transakcija po sekundi prema SQS API kada se koristi FIFO mode
	- FIFO garantuje redoslijed i tacno jedan delivery, bez ponavljanja request-ova. 
	- FIFO SQS mora imati `.fifo` kako bi mogao biti validan
- Standard
	- Brži su od FIFO queue
	- Ne postoji redoslijed
	- Poruke mogu biti poslane vise puta, u prijevodu mogu biti ponovljene
### SQS Delay Queues
![zadnja slika](Task-10-img/Screenshot%202023-05-26%20at%2001.50.15.png)
- **Podsjetnik**: Visibility timeout
	- Imamo situaciju kada je poruka dosla u queue i pokrecemo postupak polling-a (dobavljanja poruke). U tom trenutku nastupa period Visilibity Timeouta, i u tom periodu ne primamo iduce poruke. Takodjer u tom periodu, proces sa porukom ce se izvrsiti uspjesno i poruka ce biti obrisana od strane korisnika ili ne. U slucaju ako se ne obrise, poruka ce se opet vratiti u queue
	- Visibility timeout po default-u traje 30 sekundi, al ise moze konfigurisati od 0 sekundi do 12 sati. 
	- Kljucna stvar je da Visibility Timeout sluzi za reprocesiranje, u slucaju error-a sa procesom koji je poruka dostavila, poruka se ponavlja u queue-u
- Delay queue -> sa ovim alatom desinisemo vrijednost delaySeconds. Poruke koje su dodane u queue ce biti nevidljive za taj period od `delaySeconds`. Ova vrijednost je po default-u 0 a moze najvise biti 15 minuta.
- Zbog delay queue-a, poruka je automatski nevidljiva odredjeni period kada je prvi put doana u queue. 
- Ovaj alat korisitmo kada trebamo postaviti delay unutar svoje aplikacije, koji ce nam npr. sluziti za odradjivanje nekih taskova prije nego sto izvrrsimo proces sa porukom
- Drugi primjer je da se napravi stanka izmedju akcija koje radi korisnik i procesiranja poruke.