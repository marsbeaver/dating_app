package models

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Stores user data to be stored in db on creation

type User struct {
	ID          primitive.ObjectID `bson:"_id"`
	UserHandle  string             `bson:"userHandle"`
	BirthDate   string             `bson:"birthDate"`
	Location    string             `bson:"location"`
	Description string             `bson:"description"`
	Email       string             `bson:"email" validate:"required,email"`
	FirstName   string             `bson:"firstName" validate:"required"`
	Interests   string             `bson:"interests"`
	LastName    string             `bson:"lastName" validate:"required"`
	Mobile      string             `bson:"mobile" validate:"required,numeric,len=10"`
	Password    string             `bson:"password" validate:"required,min=8"`
}
