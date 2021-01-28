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



# Request URL: https://pages.awscloud.com/PreferenceCenterV4-Unsub-PreferenceCenter.html

# cookie: __cfduid=d13053f5277453bbf4d9654ea1cd7b68d1606837978; BIGipServersj23web-nginx-app_https=!HCHkMWrDqb1DgMLInuzRy4alk/3R/pfG/huz/MCrFb/Hw0l6TgSlJ9Z/wrTEz6rUN1iPas+us2ZmDDM=; __cf_bm=7fe8ac3161fd1d2df838453e0cc5d4ebec97c873-1606837979-1800-AX8CgSEkRJmN00SalmG0H/OukeAlP5QZYF7pxJ2eYvZpZYFnLg3Wz3vZxhiFtIrEPVnn7YZPc9+VUNV8Oo8eZVY=; formdata={"FirstName":"","LastName":"","Email":"raras@dfds.com","Company":"","Phone":"","Country":"DK","preferenceCenterCategory":"no","preferenceCenterGettingStarted":"no","preferenceCenterOnlineInPersonEvents":"no","preferenceCenterMonthlyAWSNewsletter":"no","preferenceCenterTrainingandBestPracticeContent":"no","preferenceCenterProductandServiceAnnoucements":"no","preferenceCenterSurveys":"no","PreferenceCenter_AWS_Partner_Events_Co__c":"no","preferenceCenterOtherAWSCommunications":"no","PreferenceCenter_Language_Preference__c":"","Title":"","Job_Role__c":"","Industry":"","Level_of_AWS_Usage__c":"","LDR_Solution_Area__c":"","Unsubscribed":"yes","UnsubscribedReason":["Too many emails","Email content isnâ€™t relevant to me","I don't recall signing up for this email list"],"unsubscribedReasonOther":"Stop it!","useCaseMultiSelect":"","zOPFormValidationBotVerification":"","Website_Referral_Code__c":"","zOPURLTrackingTRKCampaign":"","zOPEmailValidationHygiene":"validate","formid":"34006","lpId":"127906","subId":"6","munchkinId":"112-TZM-766","lpurl":"//pages.awscloud.com/communication-preferences.html?cr={creative}&kw={keyword}","cr":"","kw":"","q":""}
