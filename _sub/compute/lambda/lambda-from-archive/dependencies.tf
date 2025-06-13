data "archive_file" "this" {
  type        = "zip"
  output_path = var.filename_out

  source {
    content = templatefile(var.path_to_index_file, var.templatefile_vars)
    filename = "index.mjs"
  }
}
