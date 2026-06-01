---
page_title: "hashicups_order Resource - terraform-provider-hashicups"
subcategory: ""
description: |-
  Manages a coffee order in HashiCups.
---

# hashicups_order (Resource)

The `hashicups_order` resource allows you to create and manage coffee orders in HashiCups.

## Example Usage

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

### Using with Data Source

```terraform
data "hashicups_coffees" "all" {}

# Create an order for the first coffee
resource "hashicups_order" "first_coffee" {
  items = [
    {
      coffee_id = data.hashicups_coffees.all.coffees[0].id
      quantity  = 3
    }
  ]
}
```

## Schema

### Required

- `items` (List of Object) List of items in the order. (see [below for nested schema](#nestedatt--items))

### Read-Only

- `id` (String) Numeric identifier of the order.
- `last_updated` (String) Timestamp of the last Terraform update of the order.

<a id="nestedatt--items"></a>
### Nested Schema for `items`

Required:

- `coffee_id` (Number) Coffee ID.
- `quantity` (Number) Number of coffees.

## Import

Orders can be imported using the order ID:

```bash
terraform import hashicups_order.example 1