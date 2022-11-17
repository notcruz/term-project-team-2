resource "aws_amplify_app" "front-end" {
  name       = "front-end"
  repository = "https://github.com/notcruz/term-project-team-2"

  /* Attach Github Access Token Here - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_app#repository-with-tokens */
  /* Manually Run Build - https://us-east-1.console.aws.amazon.com/amplify/home */
  access_token = ""

  # The default build_spec added by the Amplify Console for React.
  build_spec = <<-EOT
    version: 1
    applications:
      - frontend:
          phases:
            preBuild:
              commands:
                - yarn install
            build:
              commands:
                - ENDPOINT=${ENDPOINT}
                - yarn run build
          artifacts:
            baseDirectory: .next
            files:
              - '**/*'
          cache:
            paths:
              - node_modules/**/*
        appRoot: src/app
  EOT

  enable_auto_branch_creation = true
  enable_branch_auto_build = true
  enable_branch_auto_deletion = true
  platform = "WEB"

  auto_branch_creation_config {
    enable_pull_request_preview = true
    environment_variables = {
      APP_ENVIRONMENT = "main"
    }
  }

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  environment_variables = {
    AMPLIFY_DIFF_DEPLOY = "false"
    AMPLIFY_MONOREPO_APP_ROOT = "src/app"
    ENDPOINT = aws_apigatewayv2_stage.api_gw.invoke_url
  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.front-end.id
  branch_name = "main"

  enable_auto_build = true

  framework = "Next.js - SSR"
  stage     = "DEVELOPMENT"

  environment_variables = {
    APP_ENVIRONMENT = "main"
  }
}
