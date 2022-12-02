resource "aws_amplify_app" "front-end" {
  name       = "front-end"
  repository = var.git_repo

  access_token = var.git_access_token
  enable_auto_branch_creation = true
  enable_branch_auto_build = true
  enable_branch_auto_deletion = true
  platform = "WEB"

  custom_rule {
    source = "/<*>"
    status = "404-200"
    target = "/index.html"  
  }

  auto_branch_creation_config {
    enable_pull_request_preview = true
    environment_variables = {
      APP_ENVIRONMENT = "main"
    }
  }


  environment_variables = {
    ENV = "dev"
    AMPLIFY_DIFF_DEPLOY = "false"
    AMPLIFY_MONOREPO_APP_ROOT = "src/app"
    NEXT_PUBLIC_ENDPOINT = aws_apigatewayv2_stage.api_gw.invoke_url
  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.front-end.id
  branch_name = "main"

  enable_auto_build = true

  framework = "Next.js - SSR"
  stage     = "PRODUCTION"

  environment_variables = {
    APP_ENVIRONMENT = "main"
  }
}