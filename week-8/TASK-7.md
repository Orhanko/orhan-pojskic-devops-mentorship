# Autoscaling Group and Load Balancer

1. Kreiran AMI image od istance `ec2-orhan-pojskic-web-server` pod nazivom `ami-orhan-pojskic-web-server`
2. Kreiran Application Load Balancer pod nazivom `alb-web-servers` i povezan je sa `tg-web-servers` Target Group
3. Kreiran launch template za Auto Scaling Group koji koristi gore navedeni AMI image
4. Koristeci launch template, kreiran je Auto Scaling Group pod nazivom `asg-web-server`, sa sljedecim postavkama: 
	- Auto Scaling group name
	- Launch template (odabir)
	- Default VPC
	- Availability Zones and subnets (odabir)
	- Load balancing (odabir kreirane `tg-web-servers` grupe koja je povezana sa kreiranim load balancerom)
	- EC2 health checks
	- Konfiguracija `group size` i `scaling policies`
	- Dodavanje notifikacija
	- Dodavanje tagova
5. Testirana visoka dostupnost i simuliran CPU load uspjesno.