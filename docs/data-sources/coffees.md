---
page_title: "hashicups_coffees Data Source - terraform-provider-hashicups"
subcategory: ""
description: |-
  Fetches the list of coffees from HashiCups.
---

# hashicups_coffees (Data Source)

The `hashicups_coffees` data source allows you to retrieve information about all available coffees from the HashiCups API.

## Example Usage

```terraform
data "hashicups_coffees" "all" {}

output "all_coffees" {
  value = data.hashicups_coffees.all
}

# Filter coffee names
output "coffee_names" {
  value = [for coffee in data.hashicups_coffees.all.coffees : coffee.name]
}

# Find a specific coffee by name
locals {
  espresso = [for coffee in data.hashicups_coffees.all.coffees : coffee if coffee.name == "Packer Spiced Latte"][0]
}

output "espresso_price" {
  value = local.espresso.price
}
```

## Schema

### Read-Only

- `coffees` (List of Object) List of coffees. (see [below for nested schema](#nestedatt--coffees))

<a id="nestedatt--coffees"></a>
### Nested Schema for `coffees`

Read-Only:

- `id` (Number) Numeric identifier of the coffee.
- `name` (String) Product name of the coffee.
- `teaser` (String) Fun tagline for the coffee.
- `description` (String) Product description of the coffee.
- `price` (Number) Suggested cost of the coffee.
- `image` (String) URI for an image of the coffee.