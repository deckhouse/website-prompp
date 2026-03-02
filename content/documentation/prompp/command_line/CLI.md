---
title: "Command line"
weight: 39
---

Below is the list of available Deckhouse Prom++ command line flags, along with descriptions.

| Flag | Description | Default value                                           |
|------|----------|-----------------------------------------------------------------|
| `-h`, `--help` | Show context-sensitive help (also via `--help-long` and `--help-man`) |                                                                 |
| `--version` | Show application version |                                                                 |
| `--config.file` | Deckhouse Prom++ configuration file path | `prometheus.yml`                                                |
| `--web.listen-address` | Address to listen on for UI, API, and telemetry. | `0.0.0.0:9090`                                                  |
| `--auto-gomemlimit.ratio` | Ratio of reserved GOMEMLIMIT memory to the maximum system memory | `0.9`                                                           |
| `--web.config.file` | (**Experimental**) Path to configuration file that can enable TLS or authentication |                                                                 |
| `--web.read-timeout` | Maximum duration before request reading times out | `5m`                                                            |
| `--web.max-connections` | Maximum number of simultaneous connections | `512`                                                           |
| `--web.external-url` | External URL for accessing Deckhouse Prom++ (via a reverse proxy) |                                                                 |
| `--web.route-prefix` | Prefix for the internal routes of the web interface |                                                                 |
| `--web.user-assets` | Path to static assets (`/user`) |                                                                 |
| `--web.enable-lifecycle` | Enable shutdown and reload via HTTP requests | `false`                                                         |
| `--web.enable-admin-api` | Enable API for admin control actions | `false`                                                         |
| `--web.enable-remote-write-receiver` | Enable API accepting remote write requests | `false`                                                         |
| `--web.console.templates` | Path to the console templates (`/consoles`) | `consoles`                                                      |
| `--web.console.libraries` | Path to the console libraries | `console_libraries`                                             |
| `--web.page-title` | Page title | `Deckhouse Prom++ Time Series Collection and Processing Server` |
| `--web.cors.origin` | Regex for CORS origin |                                                                 |
| `--storage.tsdb.path` | Path to metrics data (server mode). | `data/`                                                         |
| `--storage.tsdb.retention` | (**Deprecated**) Sample retention period |                                                                 |
| `--storage.tsdb.retention.time` | Sample retention period (overrides `retention`) |                                                                 |
| `--storage.tsdb.retention.size` | Maximum storage volume (for example, `512MB`) |                                                                 |
| `--storage.tsdb.no-lockfile` | Do not create lockfile | `false`                                                         |
| `--storage.tsdb.head-chunks-write-queue-size` | Size of the queue through which head chunks are written | `0`                                                             |
| `--storage.agent.path` | Path to data (agent mode) | `data-agent/`                                                   |
| `--storage.agent.wal-compression` | Compress the agent WAL | `true`                                                          |
| `--storage.agent.retention.min-time` | Minimum sample retention time (agent mode) |                                                                 |
| `--storage.agent.retention.max-time` | Maximum sample retention time (agent mode) |                                                                 |
| `--storage.agent.no-lockfile` | Do not create lockfile (agent mode) | `false`                                                         |
| `--storage.remote.flush-deadline` | Data flush timeout after shutdown | `1m`                                                            |
| `--storage.remote.read-sample-limit` | Sample limit for remote read | `5e7`                                                           |
| `--storage.remote.read-concurrent-limit` | Limit for concurrent remote read | `10`                                                            |
| `--storage.remote.read-max-bytes-in-frame` | Maximum frame size for  remote read | `1048576`                                                       |
| `--rules.alert.for-outage-tolerance` | Maximum outage period for restoring alerts | `1h`                                                            |
| `--rules.alert.for-grace-period` | Minimum alert interval | `10m`                                                           |
| `--rules.alert.resend-delay` | Delay before resending an alert | `1m`                                                            |
| `--rules.max-concurrent-evals` | Concurrency limit for rules | `4`                                                             |
| `--alertmanager.notification-queue-capacity` | Notification queue capacity | `10000`                                                         |
| `--query.lookback-delta` | Maximum lookback for queries  | `5m`                                                            |
| `--query.timeout` | Query execution timeout | `2m`                                                            |
| `--query.max-concurrency` | Maximum number of concurrent queries | `20`                                                            |
| `--query.max-samples` | Maximum number of samples per single query | `50000000`                                                      |
| `--enable-feature` | Enable experimental features |                                                                 |
| `--log.level` | Log verbosity (`debug`, `info`, `warn`, `error`) | `info`                                                          |
| `--log.format` | Log format (`logfmt`, `json`) | `logfmt`                                                        |
