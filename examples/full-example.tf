terraform {
  required_providers {
    hashicups = {
      source = "local/edu/hashicups"
    }
  }
}

provider "hashicups" {
  host     = "http://localhost:19090"
  username = "education"
  password = "test123"
}

# Fetch all available coffees
data "hashicups_coffees" "all" {}

# Output all coffees
output "all_coffees" {
  description = "All available coffees from HashiCups"
  value       = data.hashicups_coffees.all.coffees
}

# Output just the coffee names
output "coffee_names" {
  description = "List of all coffee names"
  value       = [for coffee in data.hashicups_coffees.all.coffees : coffee.name]
}

# Create an order with multiple items
resource "hashicups_order" "my_order" {
  items = [
    {
      coffee_id = data.hashicups_coffees.all.coffees[0].id
      quantity  = 2
    },
    {
      coffee_id = data.hashicups_coffees.all.coffees[1].id
      quantity  = 1
    }
  ]
}

# Output the order details
output "order_id" {
  description = "The ID of the created order"
  value       = hashicups_order.my_order.id
}

output "order_items" {
  description = "Items in the order"
  value       = hashicups_order.my_order.items
}

output "order_last_updated" {
  description = "Last update timestamp of the order"
  value       = hashicups_order.my_order.last_updated
}

# Create another order with specific coffee IDs
resource "hashicups_order" "espresso_order" {
  items = [
    {
      coffee_id = 1
      quantity  = 3
    }
  ]
}

# Example: Find a specific coffee by name
locals {
  # Find the first coffee that matches the name
  packer_latte = [
    for coffee in data.hashicups_coffees.all.coffees :
    coffee if coffee.name == "Packer Spiced Latte"
  ]
}

output "packer_latte_details" {
  description = "Details of Packer Spiced Latte"
  value       = length(local.packer_latte) > 0 ? local.packer_latte[0] : null
}