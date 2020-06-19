package format

func AlertColor(alertState string) string {
	if alertState == "OK" {
		return "good"
	} else {
		return "danger"
	}
}
