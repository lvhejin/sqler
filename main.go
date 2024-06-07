// Copyright 2018 The SQLer Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0
// license that can be found in the LICENSE file.
package main

import (
	"fmt"
	"strconv"

	"github.com/alash3al/go-color"
)

func main() {
	fmt.Println(color.MagentaString(SQLtoAPIBrand))
	fmt.Printf("⇨ SQLtoAPI server version: %s \n", color.GreenString(SQLtoAPIVersion))
	fmt.Printf("⇨ SQLtoAPI used driver is %s \n", color.GreenString(*flagDBDriver))
	fmt.Printf("⇨ SQLtoAPI used dsn is %s \n", color.GreenString(*flagDBDSN))
	fmt.Printf("⇨ SQLtoAPI workers count: %s \n", color.GreenString(strconv.Itoa(*flagWorkers)))
	fmt.Printf("⇨ SQLtoAPI resp server available at: %s \n", color.GreenString(*flagRESPListenAddr))
	fmt.Printf("⇨ SQLtoAPI rest server available at: %s \n", color.GreenString(*flagRESTListenAddr))

	err := make(chan error)

	go (func() {
		err <- initRESPServer()
	})()

	go (func() {
		err <- initRESTServer()
	})()

	if err := <-err; err != nil {
		color.Red(err.Error())
	}
}
