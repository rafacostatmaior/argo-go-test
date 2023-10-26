FROM golang:1.21

WORKDIR /app

COPY ./app/go.mod ./app/go.sum ./

RUN go mod download

COPY . .

RUN go build -o main .

EXPOSE 8080

CMD ["./main"]