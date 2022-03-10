locals {
  lambda_dir         = abspath("${path.module}/lambda")
  lambda_src_dir     = "${local.lambda_dir}/src"
  lambda_bin_dir     = "${local.lambda_dir}/bin"
  lambda_bin         = "${local.lambda_bin_dir}/main"
  lambda_archive_dir = "${local.lambda_dir}/archive"
  lambda_archive     = "${local.lambda_archive_dir}/lambda.zip"
  scripts            = abspath("${path.module}/scripts")
}

resource "random_uuid" "lambda_src_hash" {
  keepers = { for filename in setunion(
    fileset(local.lambda_src_dir, "*.go"),
    fileset(local.lambda_src_dir, "go.mod"),
    fileset(local.lambda_src_dir, "go.sum")
    ) : filename => filemd5("${local.lambda_src_dir}/${filename}")
  }
}

data "external" "lambda_bin" {
  depends_on = [
    random_uuid.lambda_src_hash
  ]
  program = [
    "${local.scripts}/build.sh",
    local.lambda_src_dir,
    local.lambda_bin,
    random_uuid.lambda_src_hash.result
  ]
}

data "archive_file" "lambda_package" {
  depends_on       = [data.external.lambda_bin]
  type             = "zip"
  source_file      = local.lambda_bin
  output_path      = local.lambda_archive
  output_file_mode = "0644"
}

/*
Use in the lambda resource as:

resource "aws_lambda_function" "example" {
  <...>
  runtime          = "go1.x"
  package_type     = "Zip"
  filename         = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256  
}

*/
