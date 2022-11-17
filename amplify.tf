resource "aws_amplify_app" "front-end" {
  name       = "front-end"
  repository = "https://github.com/swen-514-614-fall2022/term-project-team-2.git"

  # The default build_spec added by the Amplify Console for React.
  build_spec = yamldecode(file("amplify.yml"))

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  environment_variables = {
    ENV = "test"
  }
}
