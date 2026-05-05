resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.vm_name}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Azure Monitor Agent
resource "azurerm_virtual_machine_extension" "ama" {
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = var.vm_id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.0"
}

# Data Collection Rule
resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "${var.vm_name}-dcr"
  location            = var.location
  resource_group_name = var.resource_group_name

  destinations {
    log_analytics {
      name                  = "law-destination"
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["law-destination"]
  }

  data_sources {
    performance_counter {
      name                          = "perf-counters"
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60

      counter_specifiers = [
        "\\Memory\\Available Bytes",
        "\\Memory\\% Committed Bytes In Use"
      ]
    }
  }
}

# Associate DCR with VM
resource "azurerm_monitor_data_collection_rule_association" "assoc" {
  name                    = "${var.vm_name}-dcr-assoc"
  target_resource_id      = var.vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
}

# Action Group (REQUIRED for alert)
resource "azurerm_monitor_action_group" "ag" {
  name                = "${var.vm_name}-ag"
  resource_group_name = var.resource_group_name
  short_name          = "vmalert"

  email_receiver {
    name          = "admin"
    email_address = "your-email@example.com"
  }
}

# Memory Alert (FIXED)
resource "azurerm_monitor_scheduled_query_rules_alert" "memory_alert" {
  name                = "${var.vm_name}-memory-alert"
  location            = var.location
  resource_group_name = var.resource_group_name

  data_source_id = azurerm_log_analytics_workspace.law.id
  severity       = 2
  frequency      = 5
  time_window    = 5

  query = <<-QUERY
InsightsMetrics
| where Namespace == "Memory"
| where Name == "AvailableMB"
| summarize avgVal = avg(Val) by bin(TimeGenerated, 5m)
| where avgVal < 500
QUERY

  trigger {
    operator  = "LessThan"
    threshold = 1
  }

  action {
    action_group = [azurerm_monitor_action_group.ag.id]
  }

  depends_on = [
    azurerm_monitor_data_collection_rule_association.assoc
  ]
}

# CPU Alert
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "${var.vm_name}-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  frequency   = "PT1M"
  window_size = "PT5M"
  severity    = 2
}

# Availability Alert
resource "azurerm_monitor_metric_alert" "availability_alert" {
  name                = "${var.vm_name}-availability-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "VmAvailabilityMetric"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }

  frequency   = "PT1M"
  window_size = "PT5M"
  severity    = 1
}