package utils

import (
	"errors"
	"golang_server/internal/config"
	"sync"
	"time"

	"github.com/dgrijalva/jwt-go"
)

var jwtKey = []byte(config.Cfg.JWTKey)

type Claims struct {
	Email string `json:"email"`
	jwt.StandardClaims
}

// Define a blacklist to store invalidated tokens
var (
	tokenBlacklist = make(map[string]struct{})
	blacklistMutex sync.RWMutex
)

func GenerateJWT(email string) (string, error) {
	expirationTime := time.Now().Add(24 * time.Hour)
	claims := &Claims{
		Email: email,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: expirationTime.Unix(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		return "", err
	}
	return tokenString, nil
}

func ValidateJWT(tokenString string) (*Claims, error) {
	claims := &Claims{}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return jwtKey, nil
	})

	if err != nil {
		if err == jwt.ErrSignatureInvalid {
			return nil, err
		}
		return nil, err
	}

	if !token.Valid {
		return nil, errors.New("invalid token")
	}

	// Check if the token is blacklisted
	blacklistMutex.RLock()
	_, isBlacklisted := tokenBlacklist[tokenString]
	blacklistMutex.RUnlock()
	if isBlacklisted {
		return nil, errors.New("token is blacklisted")
	}

	return claims, nil
}

// AddToBlacklist adds a token to the blacklist
func AddToBlacklist(tokenString string) {
	blacklistMutex.Lock()
	defer blacklistMutex.Unlock()
	tokenBlacklist[tokenString] = struct{}{}
}

// RemoveFromBlacklist removes a token from the blacklist (if necessary)
func RemoveFromBlacklist(tokenString string) {
	blacklistMutex.Lock()
	defer blacklistMutex.Unlock()
	delete(tokenBlacklist, tokenString)
}
