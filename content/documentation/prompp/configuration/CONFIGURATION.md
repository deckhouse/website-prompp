---
title: "Configuration"
weight: 10

---

Deckhouse Prom++ is configured using command line parameters and a configuration file.
Command line parameters set immutable system characteristics (such as storage location, amount of data stored on disk and in memory, etc.), while the configuration file describes everything related to polling jobs and their instances, and also determines which [rule files to load](../ recording_rules/#configuring-rules).

To see a list of all available flags, run `./prompp -h`.

Deckhouse Prom++ can reload its configuration on the fly. If the new configuration is not formed correctly, the changes will not be applied.
A configuration reload is triggered by sending a `SIGHUP` signal to the Deckhouse Prom++ process or by sending an HTTP POST request to the `/-/reload` endpoint (when the `--web.enable-lifecycle` flag is enabled).
This will also reload all configured rule files.

## Configuration file

To explicitly specify which configuration file to load, use the `--config.file` flag.

The file is written in [YAML format](https://en.wikipedia.org/wiki/YAML) according to the schema described below.
Square brackets indicate optional parameters. For scalar parameters, the default value is used if omitted.

Generalized placeholders are defined as follows:

* `<boolean>`: logical value `true` or `false`
* `<duration>`: duration matching the regular expression `((([0-9]+)y)?(([0-9]+)w)?(([0-9]+)d)?(([0-9]+)h)?( ([0-9]+)m)?(([0-9]+)s)?(([0-9]+)ms)?|0)`, for example `1d`, `1h30m`, `5m`, `10s`
* `<filename>`: valid path in the current working directory
* `<float>`: floating point number
* `<host>`: valid string consisting of a hostname or IP address with an optional port number
* `<int>`: integer
* `<labelname>`: string matching the regular expression `[a-zA-Z_][a-zA-Z0-9_]*`. Any other unsupported characters in the original label must be converted to underscores. For example, the label `app.kubernetes.io/name` must be written as `app_kubernetes_io_name`
* * `<labelvalue>`: Unicode character string
* `<path>`: valid URL path
* `<scheme>`: string accepting values `http` or `https`
* `<secret>`: a regular string containing a secret, such as a password
* `<string>`: a regular string
* `<size>`: size in bytes, for example `512MB`. The unit of measurement is required. Supported units: B, KB, MB, GB, TB, PB, EB
* `<tmpl_string>`: a string that is templated before use.

The remaining placeholders are described separately.

View an [example of a correct file](https://github.com/deckhouse/prompp/blob/pp/config/testdata/conf.good.yml).

The global configuration sets parameters that apply to all other configuration contexts.
They also serve as default values for other configuration sections.

```yaml

global:
  # How often to poll targets by default.
  [ scrape_interval: <duration> | default = 1m ]

  # The time until the poll request times out.
  # It cannot exceed the poll interval.
  [ scrape_timeout: <duration> | default = 10s ]

  # Protocols to negotiate with the client during polling.
  # Supported values (case-sensitive): PrometheusProto, OpenMetricsText0.0.1,
  # OpenMetricsText1.0.0, PrometheusText0.0.4.
  # The default value is changed to [ PrometheusProto, OpenMetricsText1.0.0, OpenMetricsText0.0.1, PrometheusText0.0.4 ]
  # when the native_histogram function flag is set.
  [ scrape_protocols: [<string>, ...] | default = [ OpenMetricsText1.0.0, OpenMetricsText0.0.1, PrometheusText0.0.4 ] ]

  # How often to evaluate rules.
  [ evaluation_interval: <duration> | default = 1m ]

  # Offset the timestamp of the evaluation of rules for this particular group by
  # the specified duration into the past to ensure that
  # the source metrics have been received. Delays in metric availability
  # are more likely when Deckhouse Prom++ is running as a remote recording target,
  # but can also occur during polling anomalies.
  [ rule_query_offset: <duration> | default = 0s ]

  # Labels that are added to any time series or alerts when interacting with
  # external systems (federation, remote storage, Alertmanager).
  # References to environment variables `${var}` or `$var` are replaced according to
  # the values of the current environment variables.
  # References to undefined variables are replaced with an empty string.
  # The `$` symbol can be escaped using `$$`.
  external_labels:
    [ <labelname>: <labelvalue> ... ]

  # File where PromQL queries are written.
  # Reloading the configuration will cause the file to be reopened.
  [ query_log_file: <string> ]

  # File where polling errors are logged.
  # Restarting the configuration will cause the file to be reopened.
  [ scrape_failure_log_file: <string> ]

  # An uncompressed response body exceeding this number of bytes will cause
  # the query to fail. 0 means no limit. Example: 100MB.
  # This is an experimental feature, behavior may change or be removed in the future.
  [ body_size_limit: <size> | default = 0 ]

  # Limit on the number of samples accepted per poll.
  # If, after label changes, the number of samples exceeds this value,
  # the entire poll will be considered a failure. 0 means no limit.
  [ sample_limit: <int> | default = 0 ]

  # Limit on the number of labels accepted per sample. If, after changing the labels,
  # the number of labels exceeds this value, the entire survey will be considered unsuccessful. 0 means no limit.
  [ label_limit: <int> | default = 0 ]

  # Limit on the length (in bytes) of each individual label name. If any label name
  # in the query is longer than this value after changing the labels, the entire query will be considered unsuccessful.
  # Note that label names are encoded in UTF-8, and characters can take up to 4 bytes. 0 means no limit.
  [ label_name_length_limit: <int> | default = 0 ]

  # Limit on the length (in bytes) of each individual label value. If any label value
  # in the poll is longer than this value after the labels are changed, the entire poll will be considered a failure.
  # Note that label values are encoded in UTF-8, and characters can take up to 4 bytes. 0 means no limit.
  [ label_value_length_limit: <int> | default = 0 ]

  # Limit on the number of unique targets for each poll configuration
  # that will be accepted. If, after changing labels, the number of targets
  # exceeds this value, Deckhouse Prom++ will mark the targets as failed
  # without polling them. 0 means no limit. This is an experimental
  # feature, behavior may change in the future.
  [ target_limit: <int> | default = 0 ]

  # Limit on the number of targets discarded when changing labels
  # that will be kept in memory for each poll configuration.
  # 0 means no limit.
  [ keep_dropped_targets: <int> | default = 0 ]

  # Specifies the validation scheme for metric names and labels. Either empty,
  # or “utf8” for full UTF-8 support, or “legacy” for letters,
  # numbers, colons, and underscores.
  [ metric_name_validation_scheme <string> | default “utf8” ]

  # Specifies whether to convert all collected classic
  # histograms to native histograms with custom bins.
  [ convert_classic_histograms_to_nhcb <bool> | default = false]

runtime:
  # Set the GOGC parameter for the Go garbage collector.
  # See https://tip.golang.org/doc/gc-guide#GOGC.
  # Decreasing this number increases CPU usage.
  [ gogc: <int> | default = 75 ]

# Rule files specify a list of templates. Rules and alerts are read
# from all relevant files.
rule_files:
  [ - <filepath_glob> ... ]

# Survey configuration files specify a list of templates. Scrape configurations
# are read from all relevant files and added to the list of scrape configurations.
scrape_config_files:
  [ - <filepath_glob> ... ]

# List of scrape configurations.
scrape_configs:
  [ - <scrape_config> ... ]

# Alerts indicate settings related to Alertmanager.
alerting:
  alert_relabel_configs:
    [ - <relabel_config> ... ]
  alertmanagers:
    [ - <alertmanager_config> ... ]

# Settings related to the remote write feature.
remote_write:
  [ - <remote_write> ... ]

# Settings related to the OTLP receiver feature.
# See https://prometheus.io/docs/guides/opentelemetry/ for best practices.
otlp:
  [ promote_resource_attributes: [<string>, ...] | default = [ ] ]
  # Configures the translation of OTLP metrics when received via the OTLP metrics endpoint.
  # Available values:
  # - “UnderscoreEscapingWithSuffixes” refers to the common normalization
  #   used by OpenTelemetry in https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/pkg/translator/prometheus
  # - “NoUTF8EscapingWithSuffixes” is a mode that relies on UTF-8 support in Deckhouse Prom++.
  #   It preserves all special characters such as dots, but still adds the necessary suffixes
  #   for metric names for units and _total, as UnderscoreEscapingWithSuffixes does.
  # - (EXPERIMENTAL) “NoTranslation” is a mode that relies on UTF-8 support in Deckhouse Prom++.
  #   It preserves all special characters such as dots and will not add special suffixes
  #   for units and metric types.
  #
  #   WARNING: The “NoTranslation” setting has significant known risks and limitations
  #   (see https://prometheus.io/docs/practices/naming/ for details):
  #       * Degraded UX when using PromQL in plain YAML (e.g., alerts, rules, dashboards, autoscaling configuration).
  #       * Series collisions, which at best can lead to OOO errors, at worst to a silently corrupted
  #         time series. For example, you may find yourself in a situation where you load a series `foo.bar` with a unit of
  #         `seconds` and a separate series `foo.bar` with a unit of `milliseconds`.

  [ translation_strategy: <string> | default = “UnderscoreEscapingWithSuffixes” ]
  # Enables adding the “service.name”, “service.namespace”, and “service.instance.id” resource attributes
  # to the “target_info” metric, in addition to converting them to ‘instance’ and “job” labels.
  [ keep_identifying_resource_attributes: <boolean> | default = false]
  # Configures optional conversion of explicit histograms with OTLP bins to native histograms with custom bins.
  [ convert_histograms_to_nhcb: <boolean> | default = false]

# Settings related to the remote read feature.
remote_read:
  [ - <remote_read> ... ]

# Storage-related settings that can be reloaded during runtime.
storage:
  [ tsdb: <tsdb> ]
  [ exemplars: <exemplars> ]

# Tracing export configuration.
tracing:
  [ <tracing_config> ]

```

### scrape_config
