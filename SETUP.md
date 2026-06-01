# Complete Setup Guide

This guide will help you install all prerequisites and set up the HashiCups Terraform provider from scratch.

## Prerequisites Installation

### 1. Install Terraform

**macOS (using Homebrew):**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**macOS (manual download):**
```bash
# Download Terraform
curl -O https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_darwin_arm64.zip

# Unzip
unzip terraform_1.6.6_darwin_arm64.zip

# Move to PATH
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

**Linux:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**Verify Terraform installation:**
```bash
terraform version
# Should output: Terraform v1.6.x or later
```

### 2. Install Go (if not already installed)

**macOS:**
```bash
brew install go
```

**Linux:**
```bash
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
```

**Verify Go installation:**
```bash
go version
# Should output: go version go1.21.x or later
```

### 3. Install Docker & Docker Compose

**macOS:**
```bash
# Install Docker Desktop from https://www.docker.com/products/docker-desktop
# Or using Homebrew:
brew install --cask docker
```

**Linux:**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

**Verify Docker installation:**
```bash
docker --version
docker-compose --version
```

## Setup HashiCups Provider

### Step 1: Clone or Navigate to the Repository

```bash
cd /Users/angelraphael/Documents/go/hashicups
```

### Step 2: Start HashiCups API

**Option 1: Using the setup script (Recommended)**

```bash
./scripts/setup-hashicups.sh
```

This automatically starts services and creates the default user.

**Option 2: Manual setup**

```bash
# Start services
docker-compose up -d

# Wait for services to start
sleep 10

# Create default user (REQUIRED for authentication)
curl -X POST http://localhost:19090/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"education","password":"test123"}'

# Verify the API is running
curl http://localhost:19090/coffees
```

You should see a JSON response with coffee data.

### Step 3: Build the Provider

```bash
# Build the provider binary
go build -o terraform-provider-hashicups

# Verify the binary was created
ls -lh terraform-provider-hashicups
```

### Step 4: Install the Provider Locally

**For macOS ARM64 (M1/M2/M3):**
```bash
mkdir -p ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.1.0/darwin_arm64
cp terraform-provider-hashicups ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.1.0/darwin_arm64/
```

**For macOS AMD64 (Intel):**
```bash
mkdir -p ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.1.0/darwin_amd64
cp terraform-provider-hashicups ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.1.0/darwin_amd64/
```

**For Linux AMD64:**
```bash
mkdir -p ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.1.0/linux_amd64
cp terraform-provider-hashicups ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.1.0/linux_amd64/
```

### Step 5: Test the Provider

Create a test directory and configuration:

```bash
# Create a test directory
mkdir -p ~/hashicups-test
cd ~/hashicups-test

# Create a test configuration
cat > main.tf << 'EOF'
terraform {
  required_providers {
    hashicups = {
      source = "hashicorp.com/edu/hashicups"
    }
  }
}

provider "hashicups" {
  host     = "http://localhost:19090"
  username = "education"
  password = "test123"
}

# Fetch all coffees
data "hashicups_coffees" "all" {}

# Create an order
resource "hashicups_order" "my_order" {
  items = [
    {
      coffee_id = 1
      quantity  = 2
    }
  ]
}

# Output the results
output "coffees" {
  value = data.hashicups_coffees.all.coffees
}

output "order_id" {
  value = hashicups_order.my_order.id
}
EOF
```

### Step 6: Initialize and Apply

```bash
# Initialize Terraform (downloads provider)
terraform init

# See what will be created
terraform plan

# Create the resources
terraform apply
```

Type `yes` when prompted.

### Step 7: Verify the Results

You should see output like:

```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

coffees = [
  {
    "description" = "..."
    "id" = 1
    "image" = "/hashicorp.png"
    "name" = "HCP Aeropress"
    "price" = 200
    "teaser" = "Automation in a cup"
  },
  ...
]
order_id = "1"
```

### Step 8: Clean Up

```bash
# Destroy the Terraform resources
terraform destroy

# Stop the HashiCups API
cd /Users/angelraphael/Documents/go/hashicups
docker-compose down
```

## Troubleshooting

### Terraform not found after installation

Add Terraform to your PATH:

```bash
# For macOS/Linux, add to ~/.zshrc or ~/.bashrc:
export PATH="/usr/local/bin:$PATH"

# Reload your shell
source ~/.zshrc  # or source ~/.bashrc
```

### Provider not found

Make sure:
1. The provider binary is in the correct directory for your OS/architecture
2. The binary has execute permissions: `chmod +x terraform-provider-hashicups`
3. You're using the correct path in the provider source

Check your architecture:
```bash
# macOS
uname -m
# Output: arm64 (M1/M2/M3) or x86_64 (Intel)

# Linux
uname -m
# Output: x86_64 or aarch64
```

### Docker connection issues

```bash
# Check if Docker is running
docker ps

# Check if containers are running
docker-compose ps

# View logs
docker-compose logs
```

### API not responding

```bash
# Check if the API is accessible
curl -v http://localhost:19090/coffees

# Check container logs
docker-compose logs api

# Restart services
docker-compose restart
```

## Next Steps

Once everything is working:

1. Explore the examples in the `examples/` directory
2. Read the documentation in the `docs/` directory
3. Try modifying the Terraform configurations
4. Check out `QUICKSTART.md` for more usage examples

## Getting Help

- Check the [README.md](./README.md) for project overview
- See [QUICKSTART.md](./QUICKSTART.md) for quick start guide
- Read [CONTRIBUTING.md](./CONTRIBUTING.md) for development guidelines
- Review the [examples](./examples/) directory for more use cases