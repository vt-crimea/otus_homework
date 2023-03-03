package main

import (
	"fmt"
	"log"
	"math/rand"
	"os"
	"time"

	"github.com/jmoiron/sqlx"

	_ "github.com/lib/pq"
)

func main() {
	if len(os.Args) < 2 {
		log.Fatal("no connection string!")
	}
	connStr := os.Args[1]

	//connStr := "user=postgres dbname=test password=123456 host=127.0.0.1 port=5433 sslmode=disable"
	fmt.Println("Connecting to database...")
	db, err := sqlx.Connect("postgres", connStr)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer db.Close()
	fmt.Println("ok")

	rand.Seed(time.Now().UnixNano())

	for i := 0; i < 10; i++ {
		kind := rand.Intn(3) + 1
		fmt.Println(kind)

		sqlStr := "select * from test_func($1, $2)"
		_, err = db.Queryx(sqlStr, kind, "somevalue")

		if err != nil {
			fmt.Println(err)
			return
		}

	}
	fmt.Println("Done!")
	fmt.Scanln()
}
