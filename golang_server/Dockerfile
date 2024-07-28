# Use the official Golang image
FROM golang:1.22

# Set the working directory inside the container
WORKDIR /app

# Copy the go mod and sum files from the current directory (golang_server)

COPY go.mod go.sum ./

# Download the dependencies
RUN go mod download

# Copy the entire contents of the current directory (golang_server) to /app
COPY . .

# Create a new non-root user and set ownership
RUN useradd --create-home appuser && \
    chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

# Set the working directory for building the main.go
WORKDIR /app/cmd/app

# Build the Go app as the non-root user
RUN go build -o /app/main .

# Set the working directory back to the root of the project
WORKDIR /app

# Expose port 8080
EXPOSE 8080

# Start the Go app
CMD ["/app/main"]
