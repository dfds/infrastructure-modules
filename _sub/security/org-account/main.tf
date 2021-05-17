resource "aws_organizations_account" "org_account" {
  name                       = lower(var.name)
  email                      = var.email
  iam_user_access_to_billing = "ALLOW"
  role_name                  = var.org_role_name
  parent_id                  = var.parent_id

  provisioner "local-exec" {
    command = "sleep ${var.sleep_after}"
  }
}

resource "null_resource" "ubsubscribe_spam" {
  depends_on = [aws_organizations_account.org_account]

  provisioner "local-exec" {
    command = "curl -v 'https://pages.awscloud.com/index.php/leadCapture/save2' --data 'Email=${urlencode(var.email)}&preferenceCenterCategory=no&preferenceCenterGettingStarted=no&preferenceCenterOnlineInPersonEvents=no&preferenceCenterMonthlyAWSNewsletter=no&preferenceCenterTrainingandBestPracticeContent=no&preferenceCenterProductandServiceAnnoucements=no&preferenceCenterSurveys=no&PreferenceCenter_AWS_Partner_Events_Co__c=no&preferenceCenterOtherAWSCommunications=no&formVid=19260'"
  }
}
