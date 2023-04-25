# Implement SSL Let's Encrypt, migrate to AWS ACM
1. Kreiranje nove EC2 instance od AMI image `ec2-orhan-pojskic-web-server` pod nazivom `ec2-orhan-pojskic-task-8`
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
4. `openssl ×509 -text -in fullchain.pem -noout` -> iskoristena komanda za provjeru SSL certifikata i svih ostalih informacija