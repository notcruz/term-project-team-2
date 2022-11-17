resource "aws_amplify_app" "front-end" {
  name       = "front-end"
  repository = "https://github.com/swen-514-614-fall2022/term-project-team-2"

  /* Attach Github Access Token Here - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_app#repository-with-tokens */
  /* Manually Run Build - https://us-east-1.console.aws.amazon.com/amplify/home */
  access_token = ""

  environment_variables = {
    AMPLIFY_DIFF_DEPLOY = "false"
    AMPLIFY_MONOREPO_APP_ROOT = "src/app"
    NEXT_PUBLIC_ENDPOINT = aws_apigatewayv2_stage.api_gw.invoke_url
  }
}
