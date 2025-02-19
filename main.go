package main

import (
	"bank-backend-project/api"
	db "bank-backend-project/db/sqlc"
	"bank-backend-project/utils"
	"context"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {

	config, err := utils.LoadConfig(".")

	if err != nil {
		log.Fatal("cannot load config: ", err)
	}

	connPool, err := pgxpool.New(context.Background(), config.DBSource)
	if err != nil {
		log.Fatal("cannot connect to db:", err)
	}

	store := db.NewStore(connPool)
	server, err := api.NewServer(config, store)
	if err != nil {
		log.Fatal("Could not set up new server and routing: ", err)
	}

	err = server.Start(config.HTTPServerAddress)
	if err != nil {
		log.Fatal("Cannot start server: ", err)
	}

}
