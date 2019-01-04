aws dynamodb create-table --attribute-definitions \
AttributeName=id,AttributeType=S AttributeName=userid,AttributeType=S \
AttributeName=type,AttributeType=S --key-schema AttributeName=id,KeyType=HASH \
AttributeName=userid,KeyType=RANGE --global-secondary-indexes \
'IndexName=type-userid-index,KeySchema=[{AttributeName=type,KeyType=HASH},{AttributeName=userid,KeyType=RANGE}],Projection={ProjectionType=INCLUDE,NonKeyAttributes=[id,userid,type,locked]},ProvisionedThroughput={ReadCapacityUnits=5,WriteCapacityUnits=5}' \
--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
--region us-east-1 --table-name awssb

#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "table_name" {}
