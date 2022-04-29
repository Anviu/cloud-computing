variable "api_name" {
    description = "Name of the api gateway"
    type = string
}

variable "description" {
    description = "Description of api gateway"
    type = string
}

variable "apigateway" {
    description = "Map for api gateway routes and integrations"
    type = map(object({
        route_key = string
        integration_uri = string
        lambda_function_name = string
    }))
}