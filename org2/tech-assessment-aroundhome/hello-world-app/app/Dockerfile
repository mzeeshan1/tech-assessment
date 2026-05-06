FROM golang:1.23-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o main .
RUN chown -R appuser:appgroup /app
USER appuser
EXPOSE 8080
CMD ["./main"]
