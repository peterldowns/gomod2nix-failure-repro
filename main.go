package main

import (
  "fmt"

  _ "go.opentelemetry.io/otel/exporters/otlp/otlptrace"
)

func main() {
  fmt.Println("hello world")
}
