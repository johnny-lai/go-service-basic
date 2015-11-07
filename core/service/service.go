package service

import (
	_ "github.com/go-sql-driver/mysql"
	"github.com/johnny-lai/bedrock"
	"go-service-basic/core/model"
)

type Config struct {
	SvcHost string
}

type TodoService struct {
	dbsvc  bedrock.GormService
	config Config
}

func (s *TodoService) Configure(app *bedrock.Application) error {
	err := s.dbsvc.Configure(app)
	if err != nil {
		return err
	}

	err = app.BindConfig(&s.config)
	if err != nil {
		return err
	}

	return nil
}

func (s *TodoService) Migrate(app *bedrock.Application) error {
	db, err := s.dbsvc.Db()
	if err != nil {
		return err
	}
	db.SingularTable(true)

	db.AutoMigrate(&model.Todo{})
	return nil
}

func (s *TodoService) Build(app *bedrock.Application) error {
	db, err := s.dbsvc.Db()
	if err != nil {
		return err
	}
	db.SingularTable(true)

	todoResource := &TodoResource{db: db}

	r := app.Engine
	r.GET("/todo", todoResource.GetAllTodos)
	r.GET("/todo/:id", todoResource.GetTodo)
	r.POST("/todo", todoResource.CreateTodo)
	r.PUT("/todo/:id", todoResource.UpdateTodo)
	r.PATCH("/todo/:id", todoResource.PatchTodo)
	r.DELETE("/todo/:id", todoResource.DeleteTodo)
	r.GET("/health", s.dbsvc.HealthHandler(app))

	return nil
}

func (s *TodoService) Run(app *bedrock.Application) error {
	app.Engine.Run(s.config.SvcHost)

	return nil
}
