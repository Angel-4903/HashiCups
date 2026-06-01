package client

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// Client is the HashiCups API client
type Client struct {
	HostURL    string
	HTTPClient *http.Client
	Token      string
	Auth       AuthStruct
}

// AuthStruct contains authentication credentials
type AuthStruct struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// NewClient creates a new HashiCups API client
func NewClient(host, username, password string) (*Client, error) {
	c := Client{
		HTTPClient: &http.Client{Timeout: 10 * time.Second},
		HostURL:    host,
		Auth: AuthStruct{
			Username: username,
			Password: password,
		},
	}

	if username != "" && password != "" {
		// Sign in to get token
		if err := c.SignIn(); err != nil {
			return nil, err
		}
	}

	return &c, nil
}

// SignIn authenticates with the HashiCups API
func (c *Client) SignIn() error {
	rb, err := json.Marshal(c.Auth)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", fmt.Sprintf("%s/signin", c.HostURL), bytes.NewBuffer(rb))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")

	body, err := c.doRequest(req)
	if err != nil {
		return err
	}

	var response SignInResponse
	err = json.Unmarshal(body, &response)
	if err != nil {
		return err
	}

	c.Token = response.Token

	return nil
}

// GetCoffees retrieves all coffees from the API
func (c *Client) GetCoffees() ([]Coffee, error) {
	req, err := http.NewRequest("GET", fmt.Sprintf("%s/coffees", c.HostURL), nil)
	if err != nil {
		return nil, err
	}

	body, err := c.doRequest(req)
	if err != nil {
		return nil, err
	}

	var coffees []Coffee
	err = json.Unmarshal(body, &coffees)
	if err != nil {
		return nil, err
	}

	return coffees, nil
}

// GetOrder retrieves an order by ID
func (c *Client) GetOrder(orderID string) (*Order, error) {
	req, err := http.NewRequest("GET", fmt.Sprintf("%s/orders/%s", c.HostURL, orderID), nil)
	if err != nil {
		return nil, err
	}

	body, err := c.doRequest(req)
	if err != nil {
		return nil, err
	}

	var order Order
	err = json.Unmarshal(body, &order)
	if err != nil {
		return nil, err
	}

	return &order, nil
}

// CreateOrder creates a new order
func (c *Client) CreateOrder(items []OrderItem) (*Order, error) {
	// The API expects an array of items directly, not wrapped in an object
	rb, err := json.Marshal(items)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("POST", fmt.Sprintf("%s/orders", c.HostURL), bytes.NewBuffer(rb))
	if err != nil {
		return nil, err
	}

	body, err := c.doRequest(req)
	if err != nil {
		return nil, err
	}

	var order Order
	err = json.Unmarshal(body, &order)
	if err != nil {
		return nil, err
	}

	return &order, nil
}

// UpdateOrder updates an existing order
func (c *Client) UpdateOrder(orderID string, items []OrderItem) (*Order, error) {
	// The API expects an array of items directly, not wrapped in an object
	rb, err := json.Marshal(items)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("PUT", fmt.Sprintf("%s/orders/%s", c.HostURL, orderID), bytes.NewBuffer(rb))
	if err != nil {
		return nil, err
	}

	body, err := c.doRequest(req)
	if err != nil {
		return nil, err
	}

	var order Order
	err = json.Unmarshal(body, &order)
	if err != nil {
		return nil, err
	}

	return &order, nil
}

// DeleteOrder deletes an order
func (c *Client) DeleteOrder(orderID string) error {
	req, err := http.NewRequest("DELETE", fmt.Sprintf("%s/orders/%s", c.HostURL, orderID), nil)
	if err != nil {
		return err
	}

	_, err = c.doRequest(req)
	if err != nil {
		return err
	}

	return nil
}

// doRequest executes an HTTP request
func (c *Client) doRequest(req *http.Request) ([]byte, error) {
	req.Header.Set("Content-Type", "application/json")

	if c.Token != "" {
		req.Header.Set("Authorization", c.Token)
	}

	res, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	if res.StatusCode != http.StatusOK && res.StatusCode != http.StatusCreated {
		return nil, fmt.Errorf("status: %d, body: %s", res.StatusCode, body)
	}

	return body, nil
}

// Made with Bob
