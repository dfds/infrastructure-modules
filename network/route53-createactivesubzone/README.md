# Route 53 Create Active DNS sub zone
This module can be used to create and activate an DNS sub zone in route 53.
This module will authenicate to the account with the parent/root DNS zone and assume a role in the account where the sub zone should be hosted.
Based on the variable for the host zone and the name of the wanted sub zone, a zone will be generated in the sub account.
The newly created dns zone will then be actived in the root zone by adding the name servers of the sub zone.

This module requires a set of credentials for an account with DNS, the credentials should also have access to a role where the sub zone should be created. Additional requiremens the root domain name and the sub dns.