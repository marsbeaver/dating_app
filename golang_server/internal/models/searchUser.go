package models

// Stores search terms received from client

type SearchUser struct {
	SearchTerm string `bson:"searchTerm"`
}
