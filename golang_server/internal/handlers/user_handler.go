package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"golang_server/internal/config"
	"golang_server/internal/models"
	"golang_server/internal/utils"
	"net/http"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type Handler struct {
	DB *mongo.Client
}

func NewHandler(db *mongo.Client) *Handler {
	return &Handler{DB: db}
}

// Create a new user and sign up

func (h *Handler) CreateUser(w http.ResponseWriter, r *http.Request) {
	var user models.User
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		fmt.Println(err)
		return
	}

	if err := utils.ValidateUser(&user); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		fmt.Println(err)
		return
	}

	collection := h.DB.Database(config.Cfg.Database).Collection("user_data")

	// Hash the password
	hashedPassword, err := utils.HashPassword(user.Password)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		fmt.Println(err)
		return
	}
	user.Password = hashedPassword

	// Create new user
	user.ID = primitive.NewObjectID()
	fmt.Println(user)
	_, err = collection.InsertOne(context.Background(), user)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		fmt.Println(err)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(user)
	fmt.Println("User created successfully")
}

// Check if the entered email already exists

func (h *Handler) CheckUniqueEmail(w http.ResponseWriter, r *http.Request) {
	var request struct {
		Email string `json:"email"`
	}
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	exists, err := h.checkCredentialExists("email", request.Email)
	if err != nil {
		http.Error(w, "Error checking email", http.StatusInternalServerError)
		return
	}

	sendResponse(w, exists)
}

// Check if the entered mobile number already exists

func (h *Handler) CheckUniqueMobile(w http.ResponseWriter, r *http.Request) {
	var request struct {
		Mobile string `json:"mobile"`
	}
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	exists, err := h.checkCredentialExists("mobile", request.Mobile)
	if err != nil {
		http.Error(w, "Error checking mobile", http.StatusInternalServerError)
		return
	}

	sendResponse(w, exists)
}

// Check if the entered user handle already exists

func (h *Handler) CheckUniqueUserHandle(w http.ResponseWriter, r *http.Request) {
	var request struct {
		UserHandle string `json:"userHandle"`
	}
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	exists, err := h.checkCredentialExists("userHandle", request.UserHandle)
	if err != nil {
		http.Error(w, "Error checking user handle", http.StatusInternalServerError)
		return
	}

	sendResponse(w, exists)
}

// Check if selected credentials exist in database

func (h *Handler) checkCredentialExists(field, value string) (bool, error) {
	collection := h.DB.Database(config.Cfg.Database).Collection("user_data")
	count, err := collection.CountDocuments(context.Background(), bson.M{field: value})
	if err != nil {
		return false, err
	}
	return count > 0, nil
}

// Returns whether the credentials were unique or not

func sendResponse(w http.ResponseWriter, exists bool) {
	response := struct {
		Unique bool `json:"unique"`
	}{
		Unique: !exists,
	}

	w.Header().Set("Content-Type", "application/json")
	if exists {
		w.WriteHeader(http.StatusConflict)
	} else {
		w.WriteHeader(http.StatusOK)
	}
	json.NewEncoder(w).Encode(response)
}

// Login the user

func (h *Handler) Login(w http.ResponseWriter, r *http.Request) {
	var credentials struct {
		Email    string `json:"email" validate:"required,email"`
		Mobile   string `json:"mobile" validate:"omitempty,numeric,len=10"`
		Password string `json:"password" validate:"required"`
	}

	if err := json.NewDecoder(r.Body).Decode(&credentials); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	var user models.User
	collection := h.DB.Database(config.Cfg.Database).Collection("user_data")

	if credentials.Email != "" {
		err := collection.FindOne(context.Background(), bson.M{"email": credentials.Email}).Decode(&user)
		if err != nil {
			http.Error(w, "Invalid email or password", http.StatusUnauthorized)
			return
		}
	} else if credentials.Mobile != "" {
		err := collection.FindOne(context.Background(), bson.M{"mobile": credentials.Mobile}).Decode(&user)
		if err != nil {
			http.Error(w, "Invalid mobile number or password", http.StatusUnauthorized)
			return
		}
	} else {
		http.Error(w, "Email or mobile number is required", http.StatusBadRequest)
		return
	}

	if !utils.CheckPasswordHash(credentials.Password, user.Password) {
		http.Error(w, "Invalid email/mobile or password", http.StatusUnauthorized)
		return
	}

	jwtToken, err := utils.GenerateJWT(user.Email)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	response := map[string]string{
		"token": jwtToken,
	}
	json.NewEncoder(w).Encode(response)
	fmt.Println("Login successful")
}

// Identify user using email

func (h *Handler) ProtectedEndpoint(w http.ResponseWriter, r *http.Request) {
	claims, ok := r.Context().Value(utils.ClaimsKey).(*utils.Claims)
	if !ok {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	fmt.Fprintf(w, "Hello, %s", claims.Email)
}

// Get user details after login

func (h *Handler) GetUser(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Running getuser")
	claims, ok := r.Context().Value(utils.ClaimsKey).(*utils.Claims)
	if !ok {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		fmt.Println("Unauthorized")
		fmt.Println(claims)
		return
	} else {
	}

	email := claims.Email

	collection := h.DB.Database(config.Cfg.Database).Collection("user_data")
	var user models.User
	err := collection.FindOne(context.Background(), bson.M{"email": email}).Decode(&user)
	if err != nil {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	// Create a PublicUser instance to exclude the password field
	publicUser := models.PublicUser{
		ID:          user.ID,
		UserHandle:  user.UserHandle,
		BirthDate:   user.BirthDate,
		Location:    user.Location,
		FirstName:   user.FirstName,
		LastName:    user.LastName,
		Email:       user.Email,
		Mobile:      user.Mobile,
		Interests:   user.Interests,
		Description: user.Description,
	}

	json.NewEncoder(w).Encode(publicUser)
	fmt.Println("User data retrieved successfully")

}

func (h *Handler) Logout(w http.ResponseWriter, r *http.Request) {

	// Extract JWT token from the request (assumes it's in the Authorization header)
	tokenString := r.Header.Get("Authorization")
	if tokenString != "" {
		// Remove the "Bearer " prefix if it exists
		if len(tokenString) > 7 && tokenString[:7] == "Bearer " {
			tokenString = tokenString[7:]
		}

		// Add token to blacklist
		utils.AddToBlacklist(tokenString)
	}

	w.WriteHeader(http.StatusOK)
	fmt.Println("Logout successful")
}

// Returns the list of users satisfying the search term

func (h *Handler) SearchUsers(w http.ResponseWriter, r *http.Request) {

	var searchObject models.SearchUser

	if err := json.NewDecoder(r.Body).Decode(&searchObject); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	collection := h.DB.Database(config.Cfg.Database).Collection("user_data")
	searchCriteria := bson.M{
		"$or": []bson.M{
			{"firstName": bson.M{"$regex": searchObject.SearchTerm, "$options": "i"}},
			{"lastName": bson.M{"$regex": searchObject.SearchTerm, "$options": "i"}},
			{"userHandle": bson.M{"$regex": searchObject.SearchTerm, "$options": "i"}},
		},
	}

	cursor, err := collection.Find(context.Background(), searchCriteria)
	if err != nil {
		http.Error(w, "Error finding users", http.StatusInternalServerError)
		return
	}
	defer cursor.Close(context.Background())

	var users []models.ResultUser
	for cursor.Next(context.Background()) {
		var user models.User
		if err := cursor.Decode(&user); err != nil {
			http.Error(w, "Error decoding user data", http.StatusInternalServerError)
			return
		}
		// Convert to PublicUser to exclude the password field
		resultUser := models.ResultUser{
			UserHandle:  user.UserHandle,
			BirthDate:   user.BirthDate,
			Location:    user.Location,
			FirstName:   user.FirstName,
			LastName:    user.LastName,
			Interests:   user.Interests,
			Description: user.Description,
		}
		users = append(users, resultUser)
	}

	if err := cursor.Err(); err != nil {
		http.Error(w, "Error iterating over users", http.StatusInternalServerError)
		return
	}
	// Return the list of users as JSON
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(users); err != nil {
		http.Error(w, "Error encoding users to JSON", http.StatusInternalServerError)
		return
	}
	fmt.Println("User search completed successfully")
}
