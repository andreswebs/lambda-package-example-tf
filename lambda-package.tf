locals {
  lambda_dir         = "${path.module}/lambda"
  lambda_src_dir     = abspath("${local.lambda_dir}/src")
  lambda_bin_dir     = abspath("${local.lambda_dir}/bin")
  lambda_bin         = "${local.lambda_bin_dir}/main"
  lambda_archive_dir = abspath("${local.lambda_dir}/archive")
  lambda_archive     = "${local.lambda_archive_dir}/lambda.zip"
}

resource "random_uuid" "lambda_src_hash" {
  keepers = { for filename in setunion(
    fileset(local.lambda_src_dir, "*.go"),
    fileset(local.lambda_src_dir, "go.mod"),
    fileset(local.lambda_src_dir, "go.sum")
    ) : filename => filemd5("${local.lambda_src_dir}/${filename}")
  }
}

resource "null_resource" "lambda_bin" {
  provisioner "local-exec" {
    working_dir = local.lambda_src_dir
    interpreter = [
      "sh", "-c"
    ]
    environment = {
      CGO_ENABLED = "0"
      GOOS        = "linux"
      GOARCH      = "amd64"
    }
    command = "go build -o ${local.lambda_bin} ."
  }

  triggers = {
    uuid = random_uuid.lambda_src_hash.result
  }
}

data "archive_file" "lambda_package" {
  depends_on       = [null_resource.lambda_bin]
  type             = "zip"
  source_file      = local.lambda_bin
  output_path      = local.lambda_archive
  output_file_mode = "0644"
}
