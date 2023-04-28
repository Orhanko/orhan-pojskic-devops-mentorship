# Implement SSL Let's Encrypt, migrate to AWS ACM
1.  Kreiranje nove EC2 instance od AMI image `ec2-orhan-pojskic-web-server` pod nazivom `ec2-orhan-pojskic-task-8`


2. Kreiranje DNS Record-a pod nazivom `orhan-pojskic.awsbosnia.com` koristeci AWS CLI komande
	- `aws configure` -> unos kredencijala
		- unos `AWS Access Key ID`
		- unos `AWS Secret Access Key`
		- unos `Default region name`
		- unos `Default output format`
	- `aws route53 change-resource-record-sets --hosted-zone -id Z3LHP8UIUC8CDK --change-batch ' {"Changes": [{"Action": "CREATE", "ResourceRecor dSet": {"Name": "orhan-pojskic.awsbosnia.com.", "Type": "A" , "TTL": 60, "ResourceRecord s": [{"Value": "18.198.201.241"373313'` -> kreiranje DNS Recorda


3. Konfiguracija Lets Encrypt SSL certifikata:
	1. konfiguracija `certbot`-a
		1. `sudo dnf install python3 augeas-libs`
		2. `sudo python3 -m venv /opt/certbot/`
		3. `sudo /opt/certbot/bin/pip install --upgrade pip`
		4. `sudo /opt/certbot/bin/pip install certbot certbot-nginx`
		5. `sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot`
		6. `sudo certbot certonly --nginx`
	2. Konfiguracija nginx config fajla na nacin da slusa port `443` i konfiguracija lokacije kreiranih certifikacijskih fajlova
	3. Otvaranje porta `443` unutar security grupe za ec2 instancu `ec2-orhan-pojskic-task-8`


4. `openssl ×509 -text -in fullchain.pem -noout` -> iskoirstena komanda za provjeru SSL certifikata i svih ostalih informacija


5. Importovan Lets Encrypt certifikat unutar ACM:
	1. Kopiran `cert.pem`
	2. Kopiran `privkey.pem`
	3. Kopiran `fullchain.pem`


6. Podeševanje ALB:
	1. Application Load Balancer Type
	2. Target grupa kojoj salje prosljedjuje saobracaj je sacinjena od `ec2-orhan-pojskic-task-8`
	3. `Listeners` sektor za ALB je podesen na nacin da sluša port 80
	4. konfiguracija DNS recorda na nacin da se mijenja `value` sa IP adrese na `ALB DNS` komandama:
	- brisanje DNS recorda koji je vezan za IP adresu EC2 instance
	```
	aws route53 change-resource-record-sets --hosted-zone-id Z3LHP8UIUC8CDK --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":{"Name":"orhan-pojskic.awsbosnia.com.","Type":"A","TTL":60,"ResourceRecords":[{"Value":"18.156.35.149"}]}}]}'
	```
	- brisanje DNS recorda koji je vezan za IP adresu EC2 instance
	```
	aws route53 change-resource-record-sets --hosted-zone-id Z3LHP8UIUC8CDK --change-batch '{"Changes":[{"Action":"CREATE","ResourceRecordSet":{"Name":"orhan-pojskic.awsbosnia.com.","Type":"CNAME","TTL":60,"ResourceRecords":[{"Value":"alb-task-8-1552194352.eu-central-1.elb.amazonaws.com"}]}}]}'
	```
	5. Nakon uspjesnog spajanja na browser, podesava se 443 port na ALB i bira se lets encrypt certifikat
	6. Konfigurise se node-app.conf na nacin da slusa samo port 80
	7. Brisanje porta 80 na ALB


7. Kreiranje novog SSL certifikata unutar AWS Certificate Menager-a:
	1. Unos DNS za koji zelimo certifikat
	2. DNS validacija:
		- Unos CNAME name i CNAME value za dobijeni certifikat
	```
	aws route53 change-resource-record-sets --hosted-zone-id Z3LHP8UIUC8CDK --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":{"Name":"orhan-pojskic.awsbosnia.com.","Type":"A","TTL":60,"ResourceRecords":[{"Value":"18.156.35.149"}]}}]}'
	```
	3. Odabir Amazon Issued certifikata u polju `Listeners` sektora ALB-a


8. Koristena komanda za ispis certifikata i datum njegovog isteka
```
echo | openssl s_client -showcerts -servername orhan-pojskic.awsbosnia.com -connect orhan-pojskic.awsbosnia.com:443 2>/dev/null | openssl x509 -inform pem -noout -text
```

