package model

type Event struct {
	Records []struct {
		SNS struct {
			Type         string `json:"Type"`
			Timestamp    string `json:"Timestamp"`
			AlertMessage string `json:"Message"`
		}
	}
}
