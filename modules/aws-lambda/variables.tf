variable zip_output_root{
    description = "Root dir for all created .zip s"
    type = string
    default = "build/zip"
}


variable "lambda_data" {
    description = "Map for lambda data"
    type = map(object({
        source_filename = string
        output_filename = string
        function_name = string
        handler = string
        timeout = number
    }))
}
