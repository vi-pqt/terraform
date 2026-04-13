region         = "ap-southeast-1"
project_name   = "culishop"
stage          = "dev"
aws_account_id = "660880135138"

state_bucket_name = "culishop-tf-state-bucket-dev"

load_balancer_type = "application"

service_names = [
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

container_ports = {
  apiservice               = 8090
  adservice                = 9555
  cartservicev2            = 7070
  checkoutservice          = 5050
  currencyservice          = 7000
  emailservice             = 8080
  frontend                 = 8080
  paymentservice           = 50051
  productcatalogservice    = 3550
  reactfrontend            = 3001
  recommendationservice    = 8080
  shippingservice          = 50051
  shoppingassistantservice = 80
}
