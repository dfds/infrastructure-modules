#Find the snapsnot ID based on the snapshot name
data "aws_db_snapshot" "db_snapshot" {
  db_snapshot_identifier = var.db_snapshot
}

