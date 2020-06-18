package format

import "testing"

func TestAlertColor(t *testing.T) {
	// Assign and asses
	okColor := AlertColor("OK")
	dangerColor := AlertColor("ALARM")

	// Assert
	if okColor != "good" {
		t.Error("AlertColor('OK') should return 'good'")
	}

	if dangerColor != "danger" {
		t.Error("AlertColor('ALARM') should return 'danger'")
	}
}
