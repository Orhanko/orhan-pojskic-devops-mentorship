# TASK-9: Static website with S3 and CloudFront

1. Kreiranje `index.html` i `error.html` stranice
2. Kreiranje S3 bucket-a pod nazivom `orhan-pojskic-devops-mentorship-program-week-11` , postavljanje fajlova na servis i omogucavanje opcije static website hosting 
4. Kreiranje CloudFront distribucije:
    1. origin domain -> endpoint za static website
    2. Redirect HTTP to HTTPS
    3. Custom SSL Cerificate 
    4. Alternate domain name -> `www.orhan-pojskic.awsbosnia.com`
5. Konfiguracija DNS record-a unutar Route 53 kroz CloudShell
    1. Ponovno izvrsavanje aws configure -> Access i Secret Access Key
    2. Koristeci komandu postavljamo name i value record

    ```aws route53 change-resource-record-sets --hosted-zone-id Z3LHP8UIUC8CDK --change-batch '{"Changes":[{"Action":"CREATE","ResourceRecordSet":{"Name":"www.orhan-pojskic.awsbosnia.com.","Type":"CNAME","TTL":60,"ResourceRecords":[{"Value":"CLOUD_FRONT_DISTRIBUTION_NAME"}]}}]}'```