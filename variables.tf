/*
 *  ========================================
 *             Variables
 *  ========================================
 */


/* Fill these variable with your AWS Information */

variable "aws_access_key" {
  description = "AWS Access Key"
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS Secrey Key"
  default     = ""
}

variable "aws_token" {
  description = "AWS Token"
  default     = ""
}

variable "git_repo" {
  description = "Github Repo"
  default     = "https://github.com/swen-514-614-fall2022/term-project-team-2"
}

variable "lab_role_arn" {
  description = "ARN for your aws academy LabRole"
  type        = string
  default     = "arn:aws:iam::035280653541:role/LabRole"
}
