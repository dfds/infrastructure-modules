locals {
#   cf_dist_comment_lower = "${lower(var.cf_dist_comment)}"

  lambda_edge_prefix = "${replace(lower(var.cf_dist_comment), " ", "-")}"
}
