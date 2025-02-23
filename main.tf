terraform {
  required_version = ">= 1.0.0"
}

# Monitoring workspace
resource "google_monitoring_workspace" "workspace" {
  display_name = "${var.project_id}-workspace"
}

# Uptime checks for critical services
resource "google_monitoring_uptime_check_config" "https" {
  display_name = "https-uptime-check"
  timeout      = "10s"
  period       = "300s"

  http_check {
    path         = "/"
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = google_compute_global_address.default.address
    }
  }
}

# Alert policies
resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "High Error Rate Alert"
  combiner     = "OR"
  conditions {
    display_name = "error-rate-condition"
    condition_threshold {
      filter          = "metric.type=\"kubernetes.io/container/restart_count\" AND resource.type=\"k8s_container\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 5
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]
}

# Notification channel
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification Channel"
  type         = "email"
  labels = {
    email_address = "alerts@example.com"
  }
}

# Log metric for error tracking
resource "google_logging_metric" "error_rate" {
  name   = "error_rate"
  filter = "resource.type=\"k8s_container\" severity>=ERROR"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}
