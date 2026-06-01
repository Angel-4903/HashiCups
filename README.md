# Terraform Provider HashiCups

This is a demo Terraform provider for HashiCups, built using the [Terraform Plugin Framework](https://github.com/hashicorp/terraform-plugin-framework).

## Requirements

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5
- [Go](https://golang.org/doc/install) >= 1.21
- [HashiCups API](https://github.com/hashicorp/learn-go-webapp-demo) running locally

## Building The Provider

1. Clone the repository
```sh
git clone https://github.com/hashicorp/terraform-provider-hashicups
```

2. Enter the repository directory
```sh
cd terraform-provider-hashicups
```

3. Build the provider using the Go `install` command:
```sh
go install
```

## Using the Provider

### Running HashiCups API

The easiest way to start HashiCups API with the default user is using the setup script:

```sh
./scripts/setup-hashicups.sh
```

This script will:
1. Start the PostgreSQL database and HashiCups API
2. Wait for services to be ready
3. Create the default user (username: `education`, password: `test123`)

**Manual Setup:**

If you prefer to set up manually:

```sh
# Start services
docker-compose up -d

# Wait for services to start
sleep 10

# Create default user
curl -X POST http://localhost:19090/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"education","password":"test123"}'

# Verify it works
curl http://localhost:19090/coffees
```

The API will be available at `http://localhost:19090`.

### Provider Configuration

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
```

### Example Usage

#### Data Source: Coffees

```terraform
data "hashicups_coffees" "all" {}

output "all_coffees" {
  value = data.hashicups_coffees.all
}
```

#### Resource: Order

```terraform
resource "hashicups_order" "example" {
  items = [
    {
      coffee_id = 1
      quantity  = 2
    },
    {
      coffee_id = 2
      quantity  = 1
    }
  ]
}

output "order_id" {
  value = hashicups_order.example.id
}
```

## Developing the Provider

If you wish to work on the provider, you'll first need [Go](http://www.golang.org) installed on your machine (see [Requirements](#requirements) above).

To compile the provider, run `go install`. This will build the provider and put the provider binary in the `$GOPATH/bin` directory.

To generate or update documentation, run `go generate`.

### Testing

To run the full suite of Acceptance tests, run `make testacc`.

*Note:* Acceptance tests create real resources, and often cost money to run. You need to have the HashiCups API running locally.

```sh
make testacc
```

Or run tests manually:

```sh
TF_ACC=1 go test -v ./internal/provider/
```


## Project Structure

```
.
├── .github/
│   └── workflows/          # GitHub Actions CI/CD
├── docs/                   # Provider documentation
├── examples/               # Example Terraform configurations
├── internal/
│   └── provider/
│       ├── client/         # HashiCups API client
│       ├── provider.go     # Provider implementation
│       ├── coffees_data_source.go
│       └── order_resource.go
├── main.go                 # Provider entry point
├── go.mod                  # Go module definition
└── README.md
```

## Features

- ✅ Provider configuration with authentication
- ✅ Data source for listing coffees
- ✅ Resource for managing orders (CRUD operations)
- ✅ Comprehensive documentation
- ✅ Example configurations
- ✅ GitHub Actions CI/CD pipeline
- ✅ Built with Terraform Plugin Framework

This is a demo provider for educational purposes.
