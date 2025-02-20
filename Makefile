ifneq ("$(wildcard .env)", "")
    include .env
    export $(shell sed 's/=.*//' .env)
endif

postgres:
	docker run --name postgres12 -p 5432:5432 \
		-e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		-e POSTGRES_USER=$(POSTGRES_USER) \
		-d postgres:15-alpine

createdb:
	docker exec -it postgres12 createdb --username=$(POSTGRES_USER) --owner=$(POSTGRES_USER) simple_bank

dropdb:
	docker exec -it postgres12 dropdb simple_bank

migrateup:
	migrate -path db/migration -database "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@localhost:5432/$(POSTGRES_DB)?sslmode=disable" -verbose up

migratedown:
	migrate -path db/migration -database "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@localhost:5432/$(POSTGRES_DB)?sslmode=disable" -verbose down

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go bank-backend-project/db/sqlc Store

.PHONY: postgres createdb dropdb migrateup migratedown sqlc test server mock