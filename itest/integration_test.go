package test

import (
  "os"
  "go-service-basic/core/model"
	"testing"
)

func host() string {
  return os.Getenv("TEST_HOST")
}

func TestGetTodos(t *testing.T) {
  url := host() + "/todo"

  r, err := makeRequest("GET", url, nil)
  if err != nil {
    t.Fail()
    return
  }

  var respTodos []model.Todo
  err = processResponseEntity(r, &respTodos, 200)
  if err != nil {
    t.Fail()
    return
  }
}

func BenchmarkGetTodos(b *testing.B) {
  url := host() + "/todo"

  for n := 0; n < b.N; n++ {
    r, err := makeRequest("GET", url, nil)
    if err != nil {
      b.Fail()
      return
    }

    var respTodos []model.Todo
    err = processResponseEntity(r, &respTodos, 200)
    if err != nil {
      b.Fail()
      return
    }
  }
}
