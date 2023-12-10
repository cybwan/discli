package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"

	"github.com/hudl/fargo"
	"github.com/spf13/pflag"
)

var (
	flags        = pflag.NewFlagSet(`fsm-controller`, pflag.ExitOnError)
	serverSchema string
	serverAddr   string
	serverPort   uint16
	serverConext string
	usage        bool
)

func init() {
	flags.StringVar(&serverSchema, "schema", "http", "Eureka server api schema")
	flags.StringVar(&serverAddr, "addr", "127.0.0.1", "Eureka server api addr")
	flags.Uint16Var(&serverPort, "port", 8761, "Eureka server api port")
	flags.StringVar(&serverConext, "context-path", "eureka", "Eureka server api context path")
	flags.BoolVar(&usage, "u", false, "usage")
}

func main() {
	if err := flags.Parse(os.Args[1:]); err != nil {
		fmt.Println(err.Error())
		os.Exit(-1)
	}
	_ = flag.CommandLine.Parse([]string{})

	if usage {
		flags.PrintDefaults()
		return
	}

	httpAddr := fmt.Sprintf("%s://%s:%d/%s", serverSchema, serverAddr, serverPort, serverConext)
	eurekaClient := fargo.NewConn(httpAddr)
	apps, err := eurekaClient.GetApps()
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(-1)
	}

	bytes, _ := json.Marshal(apps)
	fmt.Println(string(bytes))
}
