package service

import (
	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	"github.com/jinzhu/gorm"
	"go-service-basic/core/model"
)

type Config struct {
	SvcHost    string
	DbUser     string
	DbPassword string
	DbHost     string
	DbName     string
}

type TodoService struct {
  config Config
}

func (s *TodoService) Config() interface{} {
  return &s.config
}

func (s *TodoService) getDb() (gorm.DB, error) {
	connectionString := s.config.DbUser + ":" + s.config.DbPassword + "@tcp(" + s.config.DbHost + ":3306)/" + s.config.DbName + "?charset=utf8&parseTime=True"

	return gorm.Open("mysql", connectionString)
}

func (s *TodoService) Migrate() error {
	db, err := s.getDb()
	if err != nil {
		return err
	}
	db.SingularTable(true)

	db.AutoMigrate(&model.Todo{})
	return nil
}

func (s *TodoService) Build(r *gin.Engine) error {
	db, err := s.getDb()
	if err != nil {
		return err
	}
	db.SingularTable(true)

	todoResource := &TodoResource{db: db}

	r.GET("/todo", todoResource.GetAllTodos)
	r.GET("/todo/:id", todoResource.GetTodo)
	r.POST("/todo", todoResource.CreateTodo)
	r.PUT("/todo/:id", todoResource.UpdateTodo)
	r.PATCH("/todo/:id", todoResource.PatchTodo)
	r.DELETE("/todo/:id", todoResource.DeleteTodo)

	return nil
}

func (s *TodoService) Run(r *gin.Engine) error {
  r.Run(s.config.SvcHost)

  return nil
}