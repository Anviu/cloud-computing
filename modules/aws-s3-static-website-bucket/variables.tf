variable "bucket_name"{
    description = "Unique s3 bucket name"
    type = string
}

variable "tags" {
    description = "Tags to set on the bucket"
    type = map(string)
    default = {}
}

variable "html_source" {
  description = "Source path to the html souce, e.g Dir/index.html"
  type = string
}

variable "misc_file_data" {
  description = "map for misc files in website bucket"
  type = map(object({
    key: string
    acl: string
    source: string
    content_type: string
  }))
}