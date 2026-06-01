data "hashicups_coffees" "all" {}

output "all_coffees" {
  value = data.hashicups_coffees.all
}

# Example: Filter coffees by name
output "coffee_names" {
  value = [for coffee in data.hashicups_coffees.all.coffees : coffee.name]
}