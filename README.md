# Deploy AWS EC2 Ubuntu Webserver using Terraform

## Overview
Quickly and efficiently deploy an EC2 Ubuntu Webserver to the AWS Cloud platform with all the essential componets for full functionality, including: VPC, a custom Route Table, Security Group and rules, subnet, Public IP, and more. 

## Features
- **Auto Assign Public IP** Create and assign EIP to webserver
- **Ingress and Egress Traffic Rules** Allow HTTP, HTTPS, and SSH
- **Custom Route Table** Create a custom Route Table and Internet Gateway

## Prerequisites
- Terraform 1.x
- AWS account with appropriate permissions
- AWS CLI configured with AWS Credentials
- Key Pair to assign to EC2 for connection

## Installation
1. **Clone the Repository**
2. **Install Required Tools**
3. **Configuration:**
- Use `aws configire` to provide your account credentials.

## Usage
Run the script using Terraform commands:

The script will provision an Ubuntu EC2 instance within its own VPC along with the necessary network configurations to allow immediate connection using SSH, HTTP, and HTTPS.

## Steps

1. **Configure the AWS Provider:**
   - Add the AWS Provider block and set your preferred region

2. **Create the VPC (Virtual Private Cloud):**
   - Provide a name for the resource. 
   - Specify the CIDR block and Name tag.

3. **Create the Internet Gateway:**
   - Provide a name for the resource.
   - Associate IGW with the VPC.

4. **Create Custom Route Table:**
   - Provide a name for the resource.
   - Associate RT with the VPC.
   - Add IPv4 and IPv6 (optional) that routes traffic to the IGW.

5. **Create the Subnet:**
   - Provide a name for the resource.
   - Associate Subnet with the VPC.
   - Specify a CIDR block within your VPC's range.
   - Specify an Availability Zone within the region (highly recommended)
   - Add Name tag.
  
6. **Associate Subnet with Route Table:**
   - Provide a name for the association.
   - Specify the subnet created in previous step.
   - Specify the RT created in Step 4.
   - Note: If you do not create an association, the subnet will be assigned to the Default RT.
  
7. **Create Security Group to Allow Ports - 22, 80, 443:**
   - Provide a name for the resource and a description.
   - Associate Security Group with the VPC and add Name tag.
   - In separate code blocks, add necessary rules.
   - Egress Rule: Provide a name for the rule and associate it with the Security Group; allow all traffic and protocols.
   - HTTPS Ingress Rule: Provide a name for the rule and associate it with the Security Group; allow all HTTPS traffic on TCP port 443.
   - HTTP Ingress Rule: Provide a name for the rule and associate it with the Security Group; allow all HTTP traffic on TCP port 80.
   - SSH Ingress Rule: Provide a name for the rule and associate it with the Security Group; allow all SSH traffic on TCP port 22.
   - Note: For security purposes, it is recommended that you only allow SSH traffic from the Public IP assigned by your ISP.

8. **Create Network Interface with a Private IP in the Subnet Created in Step 5:**
   - Provide a name for the resource.
   - Associate the Network Interface with the Subnet.
   - Assign a Private IP within the Subnet's CIDR block.
   - Note: You may pick any IP address except IP addresses reserved by AWS.
  
9. **Assign an Elastic IP (Public IP) to the Network Interface Created in Step 8:**
   - Provide a name for the resource.
   - Specify the VPC and associate EIP with the Network Interface.
   - Tie the EIP to the Private IP.
   - Reference the IGW resource (not id) [required]
   - Note: AWS EIP relies on the deployment of the IGW. You will be unable to assign EIP to a device that doesn't have an IGW.
  
10. **Create an Ubuntu EC2 Instance and Install Apache2:**
   - Provide a name for the resource.
   - Enter the Ubuntu ami (or your desired image) - you must retrieve this from the AWS Console.
   - Choose your desired instance type.
   - Enter the the Availability Zone specified in the Subnet created in Step 5 (required).
   - Specify your key pair name (.ppk or .pem file)
   - Within the code block, associate the Network Interface to the instance and specify the first network interface `device_index = 0`
   - Withn the code block, create a script that will install Apache2.
   - Add a Name tag for the instance.
  
11. **Connect to the Web Server and Test:**
   - Once EC2 instance is in the running state, connect using SSH and your key pair and check Apache2 is running.
   - Navigate to the EIP (Public IP) in your browser to view the webpage.
   - Note: You may have to manually install Apache2 once you're connected via SSH if `user_data` did not execute.


## Customization
This script is highly customizable to your needs. Feel free to change the ami (image), ports opened, and to only allow your IP for SSH connection, etc.

## Note
Tags are reflected in the AWS console. However the resource names are only used within Terraform for reference. 

## Known Issues
Apache2 installation script may not run after EC2 is created. Please free to contribute a fix if you are aware of one. 

## License
This project is licensed under None.
