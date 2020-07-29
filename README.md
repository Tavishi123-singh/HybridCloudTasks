# HybridCloudTasks

Tasks completed during Summer Training @LinuxWorldIndia

#  task-1
AWS Infrastructure As Code Using Terraform

1. Create the key and security group which allow the port 80.
2. Launch EC2 instance.
3. In this Ec2 instance use the key and security group which we have created in step 1.
4. Launch one Volume (EBS) and mount that volume into /var/www/html
5. Developer have uploaded the code into github repo also the repo has some images.
6. Copy the github repo code into /var/www/html
7. Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.
8. Create a Cloudfront Distribution using S3 bucket(which contains images) and use the Cloudfront URL to update in code in /var/www/html

# task-2
 AWS Infrastructure As Code Using Terraform

1. Create Security group which allow the port `80`.
1. Launch EC2 instance.
1. In this Ec2 instance use the existing key or provided key and security group which we have created in step 1.
1. Launch one Volume using the EFS service and attach it in your vpc, then mount that volume into `/var/www/html`
1. Developer have uploaded the code into github repo also the repo has some images.
1. Copy the github repo code into `/var/www/html`
1. Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.
1. Create a Cloudfront Distribution using S3 bucket(which contains images) and use the Cloudfront URL to update in code in `/var/www/html`

# task-3
 Use Terraform to create and configure customized VPC for secure Wordpress Deployment

1. Write a Infrastructure as code using terraform, which automatically create a VPC.

1. In that VPC we have to create 2 subnets:

 1. `public subnet` [ Accessible for Public World! ] 

 1. `private subnet` [ Restricted for Public World! ]

1. Create a public facing internet gateway for connect our VPC/Network to the internet world and attach this gateway to our VPC.

1. Create a routing table for Internet gateway so that instance can connect to outside world, update and associate it with public subnet.

1. Launch an ec2 instance which has Wordpress setup already having the security group allowing port `80` so that our client can connect to our wordpress site.Also attach the key to instance for further login into it.

1. Launch an ec2 instance which has MYSQL setup already with security group allowing port `3306` in private subnet so that our wordpress vm can connect with the same.Also attach the key with the same.

Note: Wordpress instance has to be part of public subnet so that our client can connect our site. mysql instance has to be part of private subnet so that outside world can't connect to it. Don't forgot to add auto ip assign and auto dns name assignment option to be enabled.

# task-4
Perform task-3 with an additional feature to be added that is NAT Gateway to provide the internet access to instances running in the private subnet.
Performing the following steps:
1. Write an Infrastructure as code using terraform, which automatically create a VPC.
1. In that VPC we have to create 2 subnets:
    1.   `public  subnet` [ Accessible for Public World! ] 
    2.   `private subnet` [ Restricted for Public World! ]
1. Create a public facing internet gateway for connect our VPC/Network to the internet world and attach this gateway to our VPC.
1. Create  a routing table for Internet gateway so that instance can connect to outside world, update and associate it with public subnet.
1. Create a NAT gateway for connect our VPC/Network to the internet world  and attach this gateway to our VPC in the public network
1. Update the routing table of the private subnet, so that to access the internet it uses the nat gateway created in the public subnet
1. Launch an ec2 instance which has Wordpress setup already having the security group allowing  port `80` sothat our client can connect to our wordpress site. Also attach the key to instance for further login into it.
1. Launch an ec2 instance which has MYSQL setup already with security group allowing  port `3306` in private subnet so that our wordpress vm can connect with the same. Also attach the key with the same.

Note: Wordpress instance has to be part of public subnet so that our client can connect our site. 
mysql instance has to be part of private  subnet so that outside world can't connect to it.
Don't forgot to add auto ip assign and auto dns name assignment option to be enabled.

# Getting Started:
1. Clone this repo.
1. Download and install [aws-cli-v2](https://awscli.amazonaws.com/AWSCLIV2.msi) place it somewhere and add the exact path to the `PATH` environment variable.
1. For working with AWS create an `aws cli profile` using `aws configure --profile <newProfileName>` and configure it with `access` and `secret keys`. Terraform will use the profile specified by us in the `.tf` code.
1. I have a profile named `hybrid` created on my system. (The profiles are located in `$HOME/.aws/` by default.)
1. Download and install [`terraform`](https://www.terraform.io/downloads.html) binary extract it somewhere and add the exact path to the `PATH` environment variable.
1. `terraform init` : This will cause terraform to check through your code and download the plugins required for the used providers eg. `terraform-provider-aws` or even `terraform-provider-aws`.
1. `terraform apply --auto-approve` : This starts the infrastructure building process.
1. After done use `terraform destroy --auto-approve` : This starts the infrastructure destroying process.

