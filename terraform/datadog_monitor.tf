resource "datadog_monitor" "Application_is_reaching_scaling" {
  include_tags        = false
  require_full_window = false
  monitor_thresholds {
    critical          = 9
    critical_recovery = 8
    warning           = 8
    warning_recovery  = 7
  }
  name    = "Application is reaching scaling threshold"
  type    = "query alert"
  query   = <<EOT
max(last_5m):avg:kubernetes_state.deployment.replicas{kube_namespace:app, kube_app_name:app} > 9
EOT
  message = <<EOT
{{#is_alert}}
To fix, adjust the limit on HPA for application
{{/is_alert}}

{{#is_alert_recovery}}
If HPA limit is adjusted, update the monitor with new limits
{{/is_alert_recovery}}
EOT
}

resource "datadog_monitor" "Datadog_Cluster_Agent_API_or_APP_Invalid" {
  enable_logs_sample  = true
  new_group_delay     = 60
  require_full_window = false
  monitor_thresholds {
    critical          = 10
    critical_recovery = 0
    warning           = 5
    warning_recovery  = 0
  }
  name    = "Datadog Cluster Agent API or APP KEY Invalid"
  type    = "log alert"
  query   = <<EOT
logs("source:cluster-agent @message:\"Invalid API key or Application key\"").index("*").rollup("count").by("host").last("1h") > 10
EOT
  message = <<EOT
{{#is_alert}}
To fix, check the api or app key for Datadog agent
{{/is_alert}}

{{#is_recovery}}
api or app key is valid
{{/is_recovery}}
EOT
}



resource "datadog_dashboard_json" "dashboard_json" {
  dashboard = <<EOF
  {
      "title": "tech-assessment",
      "description": "[[suggested_dashboards]]",
      "widgets": [
          {
              "id": 4802367303955950,
              "definition": {
                  "title": "app memory utilization",
                  "title_size": "16",
                  "title_align": "left",
                  "show_legend": true,
                  "legend_layout": "auto",
                  "legend_columns": [
                      "avg",
                      "min",
                      "max",
                      "value",
                      "sum"
                  ],
                  "time": {},
                  "type": "timeseries",
                  "requests": [
                      {
                          "formulas": [
                              {
                                  "formula": "query1"
                              }
                          ],
                          "queries": [
                              {
                                  "data_source": "metrics",
                                  "name": "query1",
                                  "query": "sum:app.memoryUtilization{kube_namespace:app} by {kube_container_name}"
                              }
                          ],
                          "response_format": "timeseries",
                          "style": {
                              "palette": "dog_classic",
                              "order_by": "values",
                              "line_type": "solid",
                              "line_width": "normal"
                          },
                          "display_type": "line"
                      }
                  ],
                  "markers": [
                      {
                          "value": "y = 0",
                          "display_type": "error dashed"
                      }
                  ]
              }
          },
          {
              "id": 616678286997604,
              "definition": {
                  "title": "Alert: Application is reaching scaling limit",
                  "title_size": "16",
                  "title_align": "left",
                  "time": {},
                  "type": "alert_graph",
                  "alert_id": "20516571",
                  "viz_type": "timeseries"
              }
          },
          {
              "id": 2752269476185506,
              "definition": {
                  "title": "",
                  "title_size": "16",
                  "title_align": "left",
                  "show_legend": true,
                  "legend_layout": "auto",
                  "legend_columns": [
                      "avg",
                      "min",
                      "max",
                      "value",
                      "sum"
                  ],
                  "time": {},
                  "type": "timeseries",
                  "requests": [
                      {
                          "formulas": [
                              {
                                  "formula": "query1"
                              }
                          ],
                          "queries": [
                              {
                                  "data_source": "metrics",
                                  "name": "query1",
                                  "query": "avg:app.nim_gc_mem_bytes{kube_namespace:app} by {kube_container_name}"
                              }
                          ],
                          "response_format": "timeseries",
                          "style": {
                              "palette": "dog_classic",
                              "order_by": "values",
                              "line_type": "solid",
                              "line_width": "normal"
                          },
                          "display_type": "line"
                      }
                  ]
              }
          },
          {
              "id": 7862711191884676,
              "definition": {
                  "title": "",
                  "title_size": "16",
                  "title_align": "left",
                  "show_legend": true,
                  "legend_layout": "auto",
                  "legend_columns": [
                      "avg",
                      "min",
                      "max",
                      "value",
                      "sum"
                  ],
                  "time": {},
                  "type": "timeseries",
                  "requests": [
                      {
                          "formulas": [
                              {
                                  "formula": "query1"
                              }
                          ],
                          "queries": [
                              {
                                  "name": "query1",
                                  "data_source": "logs",
                                  "search": {
                                      "query": "source:sosafe-dummy-app kube_namespace:app @message:(error OR exception OR failed)"
                                  },
                                  "indexes": [
                                      "*"
                                  ],
                                  "group_by": [],
                                  "compute": {
                                      "aggregation": "count"
                                  },
                                  "storage": "hot"
                              }
                          ],
                          "response_format": "timeseries",
                          "style": {
                              "palette": "dog_classic",
                              "order_by": "values",
                              "line_type": "solid",
                              "line_width": "normal"
                          },
                          "display_type": "line"
                      }
                  ]
              }
          }
      ],
      "template_variables": [],
      "layout_type": "ordered",
      "notify_list": [],
      "reflow_type": "auto"
  }
  EOF
}

