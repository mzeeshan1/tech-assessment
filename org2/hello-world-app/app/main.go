package main

import (
	"fmt"
	"net/http"
)

func helloWorldHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		fmt.Fprintln(w, "Hello, Welt!")
	} else {
		http.Error(w, "Only GET method is supported", http.StatusMethodNotAllowed)
	}
}

func main() {
	http.HandleFunc("/", helloWorldHandler)
	fmt.Println("Server is running on http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		fmt.Println("Error starting server:", err)
	}
}