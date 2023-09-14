package main

import (
	"encoding/json"
	"os"
	"strconv"
	"time"

	"context"

	"github.com/dfds/infrastructure-modules/slack-alarm-notifier/pkg/format"
	"github.com/dfds/infrastructure-modules/slack-alarm-notifier/pkg/model"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/google/uuid"
	log "github.com/sirupsen/logrus"
	"github.com/slack-go/slack"
)

func init() {
	log.SetFormatter(&log.JSONFormatter{})
	log.SetOutput(os.Stdout)
	log.SetLevel(log.InfoLevel)
}

func handler(ctx context.Context, event model.Event) {
	slackWebhookURL := os.Getenv("SLACK_WEBHOOK_URL")
	correlationId := uuid.Must(uuid.NewRandom())

	var alertMessage model.AlertMessage
	err := json.Unmarshal([]byte(event.Records[0].SNS.AlertMessage), &alertMessage)
	if err != nil {
		log.WithFields(log.Fields{"correlationId": correlationId, "error": err}).Fatal("Couldn't unmarshal payload")
	}

	contextLogger := log.WithFields(log.Fields{"correlationId": correlationId, "alarmName": alertMessage.AlarmName, "alertDescription": alertMessage.AlarmDescription, "stateReason": alertMessage.NewStateReason, "stateValue": alertMessage.NewStateValue, "accountId": alertMessage.AWSAccountId, "region": alertMessage.Region})

	contextLogger.Info("Alert event received")

	attachment := slack.Attachment{
		Color:      format.AlertColor(alertMessage.NewStateValue),
		AuthorName: alertMessage.AlarmName,
		AuthorIcon: ":aws-ico:",
		Text:       alertMessage.NewStateReason + "\n" + alertMessage.AlarmDescription,
		Footer:     format.AlertFooter(alertMessage.NewStateValue, alertMessage.AWSAccountId, alertMessage.Region),
		Ts:         json.Number(strconv.FormatInt(time.Now().Unix(), 10)),
	}

	msg := slack.WebhookMessage{
		Attachments: []slack.Attachment{attachment},
	}

	err = slack.PostWebhook(slackWebhookURL, &msg)
	if err != nil {
		contextLogger.WithFields(log.Fields{"error": err}).Fatal("Fatal error while posting alert event to Slack")
	} else {
		contextLogger.Info("Alert successfully forwarded to Slack")
	}
}

func main() {
	lambda.Start(handler)
}
