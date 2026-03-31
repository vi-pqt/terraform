region         = "ap-southeast-1"
project_name   = "culishop"
stage          = "dev"
aws_account_id = "660880135138"

state_bucket_name = "culishop-tf-state-bucket-dev"
# VPC
vpc_cidr_block     = "10.0.0.0/16"
public_subnets     = ["10.0.0.0/24", "10.0.16.0/24", "10.0.32.0/24"]
private_subnets    = ["10.0.48.0/24", "10.0.64.0/24", "10.0.80.0/24"]
data_subnets       = ["10.0.96.0/24", "10.0.112.0/24", "10.0.128.0/24"]
availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

service_name = [
  "apiservice",
  "adservice",
  "cartservicev2",
  "checkoutservice",
  "currencyservice",
  "emailservice",
  "frontend",
  "paymentservice",
  "productcatalogservice",
  "reactfrontend",
  "recommendationservice",
  "shippingservice",
  "shoppingassistantservice"
]

short_names = [
  "apisvc",
  "adsvc",
  "cartsvcv2",
  "checkoutsvc",
  "currencysvc",
  "emailsvc",
  "frontend",
  "redis",
  "paymentsvc",
  "productcatalogsvc",
  "reactfrontend",
  "recommendationsvc",
  "shippingsvc",
  "shoppingassistantsvc"
]

container_port = {
  "apiservice"               = 8090
  "adservice"                = 9555
  "cartservicev2"            = 7070
  "checkoutservice"          = 5050
  "currencyservice"          = 7000
  "emailservice"             = 8080
  "frontend"                 = 8080
  "paymentservice"           = 50051
  "productcatalogservice"    = 3550
  "reactfrontend"            = 3001
  "recommendationservice"    = 8080
  "shippingservice"          = 50051
  "shoppingassistantservice" = 80
}
