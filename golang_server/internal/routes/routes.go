package routes

import (
	"golang_server/internal/handlers"
	"golang_server/internal/middleware"
	"net/http"

	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/mongo"
)

func SetupRoutes(client *mongo.Client) http.Handler {
	router := mux.NewRouter()
	handler := handlers.NewHandler(client)

	// Public routes
	router.HandleFunc("/signup", handler.CreateUser).Methods("POST")
	router.HandleFunc("/login", handler.Login).Methods("POST")

	// New credential checking routes
	router.HandleFunc("/check-email", handler.CheckUniqueEmail).Methods("POST")
	router.HandleFunc("/check-mobile", handler.CheckUniqueMobile).Methods("POST")
	router.HandleFunc("/check-user-handle", handler.CheckUniqueUserHandle).Methods("POST")

	// Protected routes
	router.Handle("/logout", middleware.JWTMiddleware(http.HandlerFunc(handler.Logout))).Methods("POST")
	router.Handle("/protected-endpoint", middleware.JWTMiddleware(http.HandlerFunc(handler.ProtectedEndpoint))).Methods("GET")
	router.Handle("/user", middleware.JWTMiddleware(http.HandlerFunc(handler.GetUser))).Methods("GET")
	router.Handle("/get-searched-users", middleware.JWTMiddleware(http.HandlerFunc(handler.SearchUsers))).Methods("POST")

	// Apply CORS middleware
	corsRouter := middleware.CORS(router)
	return corsRouter
}
