locals {
  api_cfg = "const data = {\"api_root\": \"${module.rest_apigateway.url}\"}"
}

resource "local_file" "index_cfg" {
    filename = "${path.module}/Site/cfg.js"
    content = local.api_cfg
}

