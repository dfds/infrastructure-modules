build:
	# Compile go code
	GOOS=linux go build -ldflags="-s -w" main.go

	# Create deployment packasge for Lambda
	zip slack-alarm-notifier.zip main