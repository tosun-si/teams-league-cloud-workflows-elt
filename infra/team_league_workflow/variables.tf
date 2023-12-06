variable "project_id" {
  description = "Project ID, used to enforce providing a project id."
  type        = string
}

variable "location" {
  description = "Location."
  type        = string
}

variable "workflow_name" {
  description = "Workflow name."
  type        = string
}

variable "workflow_source" {
  description = "Workflow source."
  type        = string
}

variable "workflow_uri" {
  description = "Workflow URI."
  type        = string
}

variable "workflow_sa" {
  description = "Workflow Service Account."
  type        = string
}

variable "workflow_scheduler_name" {
  description = "Workflow scheduler name."
  type        = string
}

variable "workflow_scheduler_interval" {
  description = "Workflow scheduler interval."
  type        = string
}

variable "workflow_scheduler_timezone" {
  description = "Workflow scheduler interval."
  type        = string
}

variable "workflow_scheduler_sa" {
  description = "Workflow scheduler Service Account."
  type        = string
}