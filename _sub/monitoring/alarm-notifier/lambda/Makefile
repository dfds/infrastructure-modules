build:
	# Compile go code
	GOARCH=amd64 GOOS=linux go build -tags lambda.norpc -o bootstrap main.go

	# Create deployment packasge for Lambda
	zip slack-alarm-notifier.zip bootstrap

test:
	go test ./...
