locals {
  cors_cfg = jsonencode({
      cors: "http://${module.website_s3_bucket.bucket_domain_name}",

  })
}

resource "local_file" "cors_cfg" {
    filename = "${path.module}/build/cfg/cfg.json"
    content = local.cors_cfg
}