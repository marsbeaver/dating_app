package main

import (
	"golang_server/internal/config"
	"golang_server/internal/db"
	"golang_server/internal/routes"
	"log"
	"net/http"
	"time"
)

func main() {
	config.LoadConfig()
	client, err := db.Connect()
	if err != nil {
		log.Fatal(err)
	}

	router := routes.SetupRoutes(client)
	serverAddr := ":" + config.Cfg.Port
	server := &http.Server{
		Addr:         serverAddr,
		Handler:      router,
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}

	log.Printf("Server is running on %s", serverAddr)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
