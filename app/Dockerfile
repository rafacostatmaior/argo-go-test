# Etapa 1: Compilação
FROM golang:1.21.3-alpine3.17 AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN GOARCH=amd64 GOOS=linux go build -o main

FROM golang:1.21.3-alpine3.17

COPY --from=builder /app/main /main

EXPOSE 8080

CMD ["/main"]
