package main

import (
	"context"
	"log"

  "github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func handler(ctx context.Context, event events.CloudWatchEvent) error {
	log.Printf("%+v\n", event)
	return nil
}

func main() {
	lambda.Start(handler)
}
