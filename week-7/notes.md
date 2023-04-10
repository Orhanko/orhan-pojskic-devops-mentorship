
## Koraci u izradi zadatka
1. Prijava na aws IAM usera i odlazak u sektor EC2
2. Niz koraka izrade EC2 instance:
	- Postavljanje naziva i dodatnih tagova instance
	- Odabir AMI image
	- Odabir tipa instance
	- Postavljanje key pair-a -> `.pem` kao kljuc pri loginu na instancu preko ssh protokola
	- Postavljanje network settings -> dozvole za pristup saobracaja preko odredjenih portova (80, 22)
	- Postavljanje storage-a
3. Prije logina na server, potrebno je promijeniti permisije `.pem` file-a da ga mozemo koristiti pri login-u 
4. Login na server -> ssh -i "kljuc.pem" ec2-user@`javna-ip-adresa`
5. Instalacija i pokretanje `nginx` servera koristeci komande:
	- sudo yum install nginx -y 
	- sudo systemctl start nginx  pokretanje Nginx-a
6. instalacija git-a -> sudo yum install git
7. Kreiranje `rsa` kljuceva za git kako ne bo dobili `permision denied` i kloniranje repositorija
8. Kloniranje node-js-simple-app u root direktorij 
9. Koristeci upute na stranici: [Node.js on EC2](https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html), instaliran je node.js na `ec2 instancu`
10. Dodatne komande za konfiguraciju `node.js`
	- `sudo yum install -y gcc-c++ make` -> build tools
	- `npm install -g pm2` -> Install pm2 process manager
	- `pm2 start server.js` -> Start Node.js application
11. Unutar foldera `nodejs-simple-app` pokrenuti komandu npm install, potom `npm app.js` i `npm server.js`
12. Provjera da li je proces aktivan komandom `ps aux | grep node`
13. Konfigurisanje porta kojeg pokrenuta instanca moze slusati (`8008`)
14. Pokretanje aplikacije na browseru: `public-IP-adresa:8008`
15. Unutar direktorija `etc/nginx/conf.d`, napravljen je custom config file za `nodejs-simple-app`, cija je uloga da slusa port `80` na nasem serveru, i da za lokaciju aplikacije koju ce posluzivati koristi localhost `127.0.0.1:8008`
16. Restart nginx servisa sa komandom `sudo service nginx restart` 
Zahvaljujuci portu `8008` koji je dozvoljen unutar http protokola, aplikacija je uspjesno pokrenuta koristeći samo public IP adresu našeg servera. 
