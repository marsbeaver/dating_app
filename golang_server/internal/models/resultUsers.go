package models

//	Stores data to be shown in search results

type ResultUser struct {
	UserHandle  string `bson:"userHandle"`
	BirthDate   string `bson:"birthDate"`
	Location    string `bson:"location"`
	FirstName   string `json:"firstName"`
	LastName    string `json:"lastName"`
	Interests   string `json:"interests"`
	Description string `json:"description"`
}
