package utils

import (
	"golang_server/internal/models"

	"github.com/go-playground/validator/v10"
	"golang.org/x/crypto/bcrypt"
)

var validate *validator.Validate

type contextKey string

const (
	ClaimsKey contextKey = "claims"
)

func init() {
	validate = validator.New()
}

// Check user details
func ValidateUser(user *models.User) error {
	return validate.Struct(user)
}

// Generate password hash
func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(bytes), err
}

// Check password hash
func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}
