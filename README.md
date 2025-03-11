**Terraform workspace vs. Terraform module
**

**1. Create an EC2 Instance with Terraform Workspace
**
Terraform workspaces allow you to manage multiple environments (e.g. dev, staging, prod) within the same codebase.
Steps to Create an EC2 Instance Using Workspaces:

1.	Initialize Terraform and Create Workspaces

terraform init
terraform workspace new dev
terraform workspace new prod
terraform workspace select dev

2.	main.tf (EC2 Instance Configuration)

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"
  
  tags = {
    Name = "EC2-${terraform.workspace}"
  }
}

3.	variables.tf (Optional for Better Management)

variable "instance_type" {
  default = "t2.micro"
}

4.	Apply the Configuration

terraform workspace select dev
terraform apply -auto-approve

terraform workspace select prod
terraform apply -auto-approve
________________________________________



2. Create an EC2 Instance Using Terraform Module:

Using modules makes your Terraform code more scalable and reusable.
Steps to Create an EC2 Instance Using Modules:

1.	Create Module Structure

/modules
  /ec2
    - main.tf
    - variables.tf
    - outputs.tf

2.	Module's main.tf

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
  
  tags = {
    Name = var.name
  }
}

3.	Module's variables.tf

variable "ami" {}
variable "instance_type" {}
variable "name" {}

4.	Module's outputs.tf
output "instance_id" {
  value = aws_instance.example.id
}

5.	Root Module's main.tf
provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source        = "./modules/ec2"
  ami           = "ami-0abcdef1234567890" # Update with your AMI ID
  instance_type = "t2.micro"
  name          = "EC2-Module"
}

6.	Apply the Configuration
terraform init
terraform apply -auto-approve
________________________________________
**Key Differences**

✅ Workspaces: Best for managing multiple environments.
✅ Modules: Ideal for reusability and modularization.

For larger projects, combining workspaces with modules ensures scalability and better structure.
The major differences between Terraform Workspaces and Terraform Modules lie in their purpose, functionality, and best use cases. Here's a detailed comparison:
Aspect	Terraform Workspaces	Terraform Modules
Purpose	Manages multiple environments (e.g. dev, staging, prod) within the same codebase.	Promotes code reusability by encapsulating infrastructure logic as reusable components.
State Management	Each workspace has a separate state file in the .terraform directory.	All environments share a single state file unless managed separately.
Code Structure	Same codebase for different environments with variations handled using conditionals or variables.	Separate, modularized codebase for better scalability and reusability.
Reusability	Limited reusability; intended for environment-specific configurations only.	Highly reusable; can be shared across multiple projects and teams.
Isolation	Each workspace maintains isolated resources (e.g. dev resources won't affect prod).	Resources are not automatically isolated; isolation must be managed manually (e.g. different backend configurations).
Variable Handling	Typically handled using terraform.workspace to differentiate settings.	Variables are passed as inputs directly to the module.
Complexity	Simple to set up but may become hard to manage with complex infrastructure.	Requires more planning upfront but scales better for large projects.
Best Use Case	Ideal for small projects or simpler environments with fewer differences between them.	Recommended for larger, complex infrastructures where modularization and reusability are key.
Example	terraform workspace new dev and terraform workspace new prod manage separate environments.	Module usage involves module "ec2" { source = "./modules/ec2" } for reusable infrastructure.
________________________________________

When to Use What?
✅ Use Workspaces if:
•	You have a simple setup with minor differences across environments.
•	You need quick isolation for different environments but want to maintain the same codebase.
✅ Use Modules if:
•	You have a complex infrastructure with multiple reusable components.
•	You plan to apply the same logic across multiple environments or projects.

________________________________________
**Pro Tip:**
For a scalable solution, combining both can be powerful:
•	Use modules for reusable code.
•	Use workspaces to differentiate environment-specific values like VPC IDs, instance types, etc.


**Types of Workspaces:**

**Terraform has two types of workspaces:**

1. Default Workspace
•	Created automatically when you initialize a new Terraform project.
•	Named default by Terraform.
•	If you don't explicitly create or select a workspace, Terraform uses the default workspace by default.
•	The state file for the default workspace is stored as terraform.tfstate.

**Example:**
terraform init
terraform apply   # Uses the default workspace automatically
________________________________________

2. Named Workspaces (User-Defined Workspaces)
•	Created explicitly using the terraform workspace new <workspace_name> command.
•	Each named workspace maintains its own state file within .terraform's workspace directory.
•	Ideal for managing multiple environments like dev, staging, or prod.

**Example Workflow:**
terraform workspace new dev
terraform workspace select dev
terraform apply
State File Structure for Named Workspaces:

•	The state file for the dev workspace will be stored as:
.terraform/
  |-- environments/
      |-- dev/
          |-- terraform.tfstate
________________________________________

**Key Differences:**

**Feature	Default Workspace	Named Workspaces**
Creation	Created automatically during terraform init.	Created manually using terraform workspace new <name>.
State File Name	Stored as terraform.tfstate.	Stored under .terraform/environments/<workspace_name>/terraform.tfstate.
Environment Management	Not ideal for managing multiple environments.	Designed to manage multiple environments efficiently.
Recommended Usage	Suitable for simple deployments or single-environment setups.	Ideal for multi-environment setups like dev, staging, and prod.
________________________________________

**Best Practices**
✅ Use default workspace for simple projects.
✅ Use named workspaces for isolated environments like dev, test, or prod.
✅ Combine workspaces with input variables for flexible and scalable infrastructure management.

**Types of Modules:**

In Terraform, modules are containers for multiple resources that are used together. They help organize and reuse code. There are three main types of modules:
________________________________________

1. Root Module
•	The primary module in every Terraform configuration.
•	The files in your main working directory (e.g. main.tf, variables.tf, outputs.tf) form the root module.
•	This is where you reference other modules.
✅ Best for: Defining your project's top-level infrastructure logic.

Example Root Module (main.tf)
provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source        = "./modules/ec2"
  instance_type = "t3.micro"
  ami           = "ami-0abcdef1234567890"
}
________________________________________

2. Internal Module (Local Module)
•	Stored within your Terraform project’s directory (e.g. ./modules/).
•	Typically used to organize and structure your project.
•	Ideal for creating reusable components like VPCs, EC2 instances, or IAM roles.
✅ Best for: Reusing common configurations within your own project.

Example Directory Structure:
/project
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  └── /modules
      └── /ec2
          ├── main.tf
          ├── variables.tf
          └── outputs.tf

Example Module Usage:
module "ec2_instance" {
  source        = "./modules/ec2"
  instance_type = "t3.micro"
  ami           = "ami-0abcdef1234567890"
}
________________________________________

3. External Module (Remote Module)
•	Hosted on public or private registries like the Terraform Registry, GitHub, or S3 buckets.
•	Helps you reuse community-maintained or organizational infrastructure patterns.
✅ Best for: Leveraging trusted, pre-built solutions from external sources.

Example from Terraform Registry:
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true
}

Example from GitHub:
module "ec2_instance" {
  source = "git::https://github.com/user/terraform-aws-ec2.git?ref=v1.0.0"
}
________________________________________

**Key Differences**

Feature	Root Module	Internal Module	External Module
Location	Main working directory.	Stored locally inside /modules/.	Stored in Terraform Registry, GitHub, or S3.
Reusability	Limited to the current project.	Reusable within the project.	Reusable across multiple projects.
Complexity	Suitable for top-level logic only.	Ideal for structuring larger infrastructures.	Ideal for leveraging existing solutions.
Best for	Project entry point.	Custom reusable components.	Proven, community-tested infrastructure code.
________________________________________

**Best Practices for Using Modules**

✅ Use local/internal modules for project-specific infrastructure patterns.
✅ Use external modules for common patterns like VPC creation, IAM roles, or security groups.
✅ Follow proper naming conventions and maintain clear documentation for your modules.

