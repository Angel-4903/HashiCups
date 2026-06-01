# Quick Start Guide

This guide will help you get started with the HashiCups Terraform provider in just a few minutes.

## Prerequisites

1. **Go 1.21+** installed
2. **Terraform 1.5+** installed
3. **HashiCups API** running locally

## Step 1: Start HashiCups API

The easiest way is using the setup script:

```bash
./scripts/setup-hashicups.sh
```

This will:
1. Start the PostgreSQL database and HashiCups API
2. Create the default user automatically

**Manual Setup:**

```bash
# Start services
docker-compose up -d

# Wait for services
sleep 10

# Create user (IMPORTANT: Required for authentication)
curl -X POST http://localhost:19090/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"education","password":"test123"}'

# Verify
curl http://localhost:19090/coffees
```

**Credentials:**
- Username: `education`
- Password: `test123`

## Step 2: Build and Install the Provider

```bash
# Clone the repository
git clone https://github.com/hashicorp/terraform-provider-hashicups
cd terraform-provider-hashicups

# Build the provider
go build -o terraform-provider-hashicups

# Install locally (adjust path for your OS/architecture)
mkdir -p ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.1.0/darwin_arm64
cp terraform-provider-hashicups ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.1.0/darwin_arm64/
```

For Linux AMD64:
```bash
mkdir -p ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.1.0/linux_amd64
cp terraform-provider-hashicups ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.1.0/linux_amd64/
```

## Step 3: Create Your First Configuration

Create a file named `main.tf`:

```terraform
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
```

## Step 4: Initialize and Apply

```bash
# Initialize Terraform
terraform init

# See what will be created
terraform plan

# Create the resources
terraform apply
```

## Step 5: Verify the Order

You should see output similar to:

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

## Step 6: Update the Order

Modify the `main.tf` file to change the quantity or add more items:

```terraform
resource "hashicups_order" "my_order" {
  items = [
    {
      coffee_id = 1
      quantity  = 3  # Changed from 2 to 3
    },
    {
      coffee_id = 2
      quantity  = 1  # Added new item
    }
  ]
}
```

Apply the changes:

```bash
terraform apply
```

## Step 7: Clean Up

When you're done, destroy the resources:

```bash
terraform destroy
```

## Next Steps

- Check out the [full example](./examples/full-example.tf) for more advanced usage
- Read the [documentation](./docs/) for detailed information
- Explore the [examples](./examples/) directory for more use cases

## Troubleshooting

### Provider not found

If you get an error about the provider not being found, make sure:
1. The provider binary is in the correct directory
2. The directory path matches your OS and architecture
3. The provider binary has execute permissions: `chmod +x terraform-provider-hashicups`

### Connection refused

If you get a connection error:
1. Verify HashiCups API is running: `curl http://localhost:19090/coffees`
2. Check the port is correct (19090)
3. Ensure no firewall is blocking the connection

### Authentication failed

If authentication fails:
1. Verify credentials are correct (username: `education`, password: `test123`)
2. Check the HashiCups API logs for errors
3. Try authenticating manually: `curl -X POST http://localhost:19090/signin -d '{"username":"education","password":"test123"}'`

## Environment Variables

You can also configure the provider using environment variables:

```bash
export HASHICUPS_HOST="http://localhost:19090"
export HASHICUPS_USERNAME="education"
export HASHICUPS_PASSWORD="test123"

terraform apply
```

This is useful for CI/CD pipelines or when you don't want to hardcode credentials.