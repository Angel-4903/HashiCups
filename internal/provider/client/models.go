package client

// Coffee represents a coffee product
type Coffee struct {
	ID          int     `json:"id"`
	Name        string  `json:"name"`
	Teaser      string  `json:"teaser"`
	Description string  `json:"description"`
	Price       float64 `json:"price"`
	Image       string  `json:"image"`
}

// CoffeeRef represents a reference to a coffee in an order
type CoffeeRef struct {
	ID int `json:"id"`
}

// OrderItem represents an item in an order
type OrderItem struct {
	Coffee   CoffeeRef `json:"coffee"`
	Quantity int       `json:"quantity"`
}

// Order represents a coffee order
type Order struct {
	ID    int         `json:"id"`
	Items []OrderItem `json:"items"`
}

// SignInRequest represents the sign-in request payload
type SignInRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// SignInResponse represents the sign-in response
type SignInResponse struct {
	Token string `json:"token"`
}

// Made with Bob
