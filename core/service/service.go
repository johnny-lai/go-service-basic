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
}

func (s *TodoService) getDb(cfg map[interface{}]interface{}) (gorm.DB, error) {
	dbUser := cfg["dbuser"].(string)
	dbPassword := cfg["dbpassword"].(string)
	dbHost := cfg["dbhost"].(string)
	dbName := cfg["dbname"].(string)

	connectionString := dbUser + ":" + dbPassword + "@tcp(" + dbHost + ":3306)/" + dbName + "?charset=utf8&parseTime=True"

	return gorm.Open("mysql", connectionString)
}

func (s *TodoService) Migrate(cfg map[interface{}]interface{}) error {
	db, err := s.getDb(cfg)
	if err != nil {
		return err
	}
	db.SingularTable(true)

	db.AutoMigrate(&model.Todo{})
	return nil
}

func (s *TodoService) Build(cfg map[interface{}]interface{}, r *gin.Engine) error {
	db, err := s.getDb(cfg)
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
