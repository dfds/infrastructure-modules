
aws dynamodb create-table 
--global-secondary-indexes \
'IndexName=type-userid-index,KeySchema=[{AttributeName=type,KeyType=HASH},{AttributeName=userid,KeyType=RANGE}],Projection={ProjectionType=INCLUDE,NonKeyAttributes=[id,userid,type,locked]},ProvisionedThroughput={ReadCapacityUnits=5,WriteCapacityUnits=5}' \
--provisioned-throughput 
--region us-east-1 --table-name awssb
resource "aws_dynamodb_table" "service-broker-table" {
  name           = "${var.table_name}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"
  range_key      = "userid"

  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "userid"
    type = "S"
  }
  attribute {
    name = "type"
    type = "S"
  }

  global_secondary_index {
    name               = "type-userid-index"
    hash_key           = "GameTitle"
    range_key          = "TopScore"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }
}