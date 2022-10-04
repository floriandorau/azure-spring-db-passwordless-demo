variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "resource-group" {
  type        = string
  description = "Name of resource group where resources needs to be created"
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Azure location where to place resources"
}

variable "aad-sql-admins" {
  type        = list(string)
  description = "Object IDs of users which should be part of SQL DB admin group"
}

variable "creator" {
  type        = string
  description = "Name of user used as creator tag"
}



variable "environment" {
  type        = string
  default     = "poc"
  description = "Environment name used as a tag"
}