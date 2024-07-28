package models

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Stores user data to be sent without sensitive data

type PublicUser struct {
	ID          primitive.ObjectID `json:"id"`
	UserHandle  string             `bson:"userHandle"`
	BirthDate   string             `bson:"birthDate"`
	Location    string             `bson:"location"`
	FirstName   string             `json:"firstName"`
	LastName    string             `json:"lastName"`
	Email       string             `json:"email"`
	Mobile      string             `json:"mobile"`
	Interests   string             `json:"interests"`
	Description string             `json:"description"`
}
