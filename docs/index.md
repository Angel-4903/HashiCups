---
page_title: "HashiCups Provider"
subcategory: ""
description: |-
  Terraform provider for interacting with HashiCups.
---

# HashiCups Provider

The HashiCups provider is used to interact with the resources supported by HashiCups. The provider needs to be configured with the proper credentials before it can be used.

Use the navigation to the left to read about the available resources.

## Example Usage

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

## Schema

### Optional

- `host` (String) URI for HashiCups API. May also be provided via `HASHICUPS_HOST` environment variable.
- `username` (String) Username for HashiCups API. May also be provided via `HASHICUPS_USERNAME` environment variable.
- `password` (String, Sensitive) Password for HashiCups API. May also be provided via `HASHICUPS_PASSWORD` environment variable.

## Authentication

The HashiCups provider requires authentication credentials to interact with the API. You can provide these credentials in three ways:

1. **Provider Configuration** (shown above)
2. **Environment Variables**:
   ```bash
   export HASHICUPS_HOST="http://localhost:19090"
   export HASHICUPS_USERNAME="education"
   export HASHICUPS_PASSWORD="test123"
   ```
3. **Combination**: Environment variables can be overridden by provider configuration values.