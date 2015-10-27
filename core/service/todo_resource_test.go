package service

import (
	"github.com/gin-gonic/gin"
	"github.com/johnny-lai/bedrock"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"log"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
)

var _ = Describe("TodoService", func() {
	var (
		r   *gin.Engine
		svc TodoService
	)

	BeforeEach(func() {
		file := os.Getenv("TEST_CONFIG_YML")
		if file == "" {
			log.Fatal("Configuration file not specified. Please set TEST_CONFIG_YML variable")
		}

		cfg, err := bedrock.GetConfig(file)
		if err != nil {
			log.Fatal(err)
		}

		gin.SetMode(gin.TestMode)
		r = gin.New()

		svc = TodoService{}
		if err = svc.Build(cfg, r); err != nil {
			log.Fatal(err)
		}
	})

	Describe("#GetAllTodos", func() {
		It("should not raise an error", func() {
			request, _ := http.NewRequest("GET", "/todo", nil)
			response := httptest.NewRecorder()
			r.ServeHTTP(response, request)
			Expect(response.Code).To(Equal(http.StatusOK))
		})
	})
})

func TestTodoService(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "TodoService")
}
