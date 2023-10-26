# Etapa 1: Compilação
FROM golang:1.21 AS builder

WORKDIR /app

COPY ./app/go.mod ./app/go.sum ./


RUN go mod download

COPY ./app .

RUN go build -o main .

FROM scratch

COPY --from=builder /app/main /main

EXPOSE 8080

CMD ["/main"]
