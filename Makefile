# Makefile for Terraform Provider HashiCups

default: testacc

# Run acceptance tests
.PHONY: testacc
testacc:
	TF_ACC=1 go test ./internal/provider/ -v $(TESTARGS) -timeout 120m

# Build the provider
.PHONY: build
build:
	go build -o terraform-provider-hashicups

# Install the provider locally
.PHONY: install
install: build
	mkdir -p ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.1.0/darwin_arm64
	mv terraform-provider-hashicups ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/0.1.0/darwin_arm64

# Generate documentation
.PHONY: docs
docs:
	go generate ./...

# Format code
.PHONY: fmt
fmt:
	gofmt -s -w -e .
	terraform fmt -recursive ./examples/

# Run linters
.PHONY: lint
lint:
	golangci-lint run

# Clean build artifacts
.PHONY: clean
clean:
	rm -f terraform-provider-hashicups
	rm -rf dist/

# Run unit tests
.PHONY: test
test:
	go test -v ./...

# Download dependencies
.PHONY: deps
deps:
	go mod download
	go mod tidy

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  testacc  - Run acceptance tests"
	@echo "  build    - Build the provider binary"
	@echo "  install  - Install the provider locally"
	@echo "  docs     - Generate documentation"
	@echo "  fmt      - Format code"
	@echo "  lint     - Run linters"
	@echo "  clean    - Clean build artifacts"
	@echo "  test     - Run unit tests"
	@echo "  deps     - Download and tidy dependencies"

# Made with Bob
