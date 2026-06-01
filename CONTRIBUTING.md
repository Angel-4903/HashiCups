# Contributing to HashiCups Terraform Provider

Thank you for your interest in contributing to the HashiCups Terraform provider! This document provides guidelines and instructions for contributing.

## Development Environment Setup

### Prerequisites

- [Go](https://golang.org/doc/install) 1.21 or later
- [Terraform](https://www.terraform.io/downloads.html) 1.5 or later
- [Git](https://git-scm.com/downloads)
- [Docker](https://docs.docker.com/get-docker/) (for running HashiCups API)

### Setting Up Your Development Environment

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/terraform-provider-hashicups.git
   cd terraform-provider-hashicups
   ```

3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/hashicorp/terraform-provider-hashicups.git
   ```

4. Install dependencies:
   ```bash
   go mod download
   ```

5. Build the provider:
   ```bash
   make build
   ```

## Development Workflow

### Running HashiCups API Locally

For development and testing, you'll need the HashiCups API running. Use Docker Compose:

```bash
docker-compose up
```

Or manually with Docker:

```bash
# Start the database
docker run -d --name hashicups-db \
  -e POSTGRES_DB=products \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  hashicorpdemoapp/product-api-db:v0.0.22

# Wait for database to start
sleep 5

# Start the API
docker run -d --name hashicups-api \
  -e DB_CONNECTION="host=host.docker.internal port=5432 user=postgres password=password dbname=products sslmode=disable" \
  -e BIND_ADDRESS="0.0.0.0:9090" \
  -p 19090:9090 \
  hashicorpdemoapp/product-api:v0.0.22
```

Verify it's running:
```bash
curl http://localhost:19090/coffees
```

### Making Changes

1. Create a new branch for your feature or bugfix:
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. Make your changes following the coding standards below

3. Write or update tests for your changes

4. Run tests:
   ```bash
   make test
   ```

5. Format your code:
   ```bash
   make fmt
   ```

6. Build the provider to ensure it compiles:
   ```bash
   make build
   ```

### Testing Your Changes

#### Unit Tests

Run unit tests with:
```bash
go test ./...
```

#### Acceptance Tests

Acceptance tests create real resources and require the HashiCups API to be running:

```bash
# Make sure HashiCups API is running
docker-compose up -d

# Run acceptance tests
make testacc

# Clean up
docker-compose down
```

Or run specific tests:
```bash
TF_ACC=1 go test ./internal/provider/ -v -run TestAccOrderResource
```

#### Manual Testing

1. Build and install the provider locally:
   ```bash
   make install
   ```

2. Create a test configuration in a separate directory:
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

   # Your test resources here
   ```

3. Test with Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Coding Standards

### Go Code Style

- Follow standard Go formatting (use `gofmt` or `make fmt`)
- Use meaningful variable and function names
- Add comments for exported functions and types
- Keep functions focused and concise
- Handle errors appropriately

### Terraform Provider Conventions

- Use the Terraform Plugin Framework patterns
- Follow HashiCorp's provider development best practices
- Use descriptive schema descriptions
- Implement proper error handling and diagnostics
- Add validation where appropriate

### File Organization

```
internal/provider/
├── client/              # API client code
│   ├── client.go       # HTTP client implementation
│   └── models.go       # Data models
├── provider.go         # Provider configuration
├── *_data_source.go    # Data source implementations
├── *_resource.go       # Resource implementations
└── *_test.go          # Test files
```

## Documentation

### Code Documentation

- Add godoc comments for all exported types and functions
- Include examples in comments where helpful
- Document any non-obvious behavior

### User Documentation

When adding new features, update:

1. **README.md** - If it affects usage or setup
2. **docs/index.md** - Provider-level documentation
3. **docs/resources/** or **docs/data-sources/** - Resource/data source specific docs
4. **examples/** - Add example configurations

Documentation should include:
- Description of the feature
- Schema attributes with types and descriptions
- Example usage
- Any important notes or limitations

## Submitting Changes

### Commit Messages

Write clear, concise commit messages:

```
Add support for coffee ingredients resource

- Implement ingredients data source
- Add CRUD operations for ingredients
- Include acceptance tests
- Update documentation
```

### Pull Request Process

1. Update your branch with the latest upstream changes:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. Push your changes to your fork:
   ```bash
   git push origin feature/my-new-feature
   ```

3. Create a pull request on GitHub with:
   - Clear title describing the change
   - Description of what changed and why
   - Reference to any related issues
   - Screenshots or examples if applicable

4. Ensure all CI checks pass

5. Respond to review feedback

### Pull Request Checklist

- [ ] Code follows the project's style guidelines
- [ ] Tests added/updated and passing
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] Branch is up to date with main
- [ ] No merge conflicts

## Adding New Resources or Data Sources

### Creating a New Resource

1. Create a new file: `internal/provider/myresource_resource.go`

2. Implement the resource interface:
   ```go
   type myResourceResource struct {
       client *client.Client
   }

   func NewMyResourceResource() resource.Resource {
       return &myResourceResource{}
   }

   // Implement required methods:
   // - Metadata
   // - Schema
   // - Create
   // - Read
   // - Update
   // - Delete
   // - Configure
   ```

3. Register in `provider.go`:
   ```go
   func (p *hashicupsProvider) Resources(_ context.Context) []func() resource.Resource {
       return []func() resource.Resource{
           NewMyResourceResource,
           // ... other resources
       }
   }
   ```

4. Add tests in `myresource_resource_test.go`

5. Add documentation in `docs/resources/myresource.md`

6. Add example in `examples/resources/myresource/`

### Creating a New Data Source

Follow similar steps as resources, but implement the data source interface instead.

## Getting Help

- Check existing issues and pull requests
- Read the [Terraform Plugin Framework documentation](https://developer.hashicorp.com/terraform/plugin/framework)
- Ask questions in pull request comments
- Join the HashiCorp community forums

## Code of Conduct

Be respectful and inclusive. We're all here to learn and improve the provider together.

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.