variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resource deployment"
  type        = string
}

output "workspace_name" {
  value = google_monitoring_workspace.workspace.name
}

output "alert_policy_name" {
  value = google_monitoring_alert_policy.alert_policy.name
}

output "notification_channel_id" {
  value = google_monitoring_notification_channel.email.name
}
