package format

func AlertFooter(alarmState string, accountId string, region string) string {
	return "* Alarm state: " + alarmState + "\n" + "* Account ID: " + accountId + "\n" + "* Region: " + region
}
