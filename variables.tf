# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/kms/variables.tf ---

variable "project_name" {
  type        = string
  description = "Project identifier."
  default     = "legacy"
}

variable "aws_region" {
  type        = string
  description = "AWS Region indicated in the variables - where the resources are created."
  default     = "eu-west-1"
}
