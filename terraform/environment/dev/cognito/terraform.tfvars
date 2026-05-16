env          = "dev"
system_name  = "sbcs"
project_name = "spring-boot-cognito-sample"
aws_region   = "ap-northeast-1"

# TODO: 実値に差し替え (apply 前に必須)
custom_domain   = "auth.dev.example.com"
route53_zone_id = "ZXXXXXXXXXXXXX"

callback_urls = ["http://localhost:3000/callback/auth"]
logout_urls   = ["http://localhost:3000/"]

token_validity = {
  access  = { value = 60, unit = "minutes" }
  id      = { value = 60, unit = "minutes" }
  refresh = { value = 30, unit = "days" }
}

tags = {
  Owner = "platform"
}
