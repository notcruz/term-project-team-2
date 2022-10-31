# Update with account-id or LabRole ARN
variable "lab_role_arn" {
    description = "ARN for your aws academy LabRole"
    type = string
    default = "arn:aws:iam::YOUR-ACCOUNT-ID:role/LabRole"
}
