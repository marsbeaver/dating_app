package db

import (
	"context"
	"golang_server/internal/config"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// Connect to the mongodb database

func Connect() (*mongo.Client, error) {
	uri := config.Cfg.MongoUri
	clientOptions := options.Client().ApplyURI(uri)
	client, err := mongo.Connect(context.Background(), clientOptions)
	if err != nil {
		return nil, err
	}
	err = client.Ping(context.Background(), nil)
	return client, err
}
