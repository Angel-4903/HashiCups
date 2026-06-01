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

output "order_items" {
  value = hashicups_order.example.items
}