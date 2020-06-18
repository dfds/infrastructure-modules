package model

type AlertMessage struct {
	AlarmName        string `json:"AlarmName"`
	AlarmDescription string `json:"AlarmDescription"`
	NewStateValue    string `json:"NewStateValue"`
	NewStateReason   string `json:"NewStateReason"`
	AWSAccountId     string `json:"AWSAccountId"`
	Region           string `json:"Region"`
}
