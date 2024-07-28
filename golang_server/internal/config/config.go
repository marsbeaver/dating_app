package config

import (
	"fmt"
	"log"
	"os"
)

type Config struct {
	SessionKey string
	JWTKey     string
	MongoUri   string
	Port       string
	Database   string
}

var Cfg Config

func LoadConfig() error {
	Cfg = Config{
		JWTKey:   getEnv("JWT_KEY", ""),
		MongoUri: getEnv("MONGO_URI", ""),
		Port:     getEnv("PORT", ""), // Default port is 8080
		Database: getEnv("DATABASE", ""),
	}

	if Cfg.JWTKey == "" || Cfg.MongoUri == "" || Cfg.Database == "" {
		return fmt.Errorf("missing required environment variables")
	}

	return nil
}

func getEnv(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}
	return value
}

func init() {
	err := LoadConfig()
	if err != nil {
		log.Fatalf("Error loading config: %v", err)
	}
}
