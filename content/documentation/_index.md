---
title: Documentation
weight: 1
cascade:
  params:
    simple_list: true
outputs:
  - HTML
  - markdown
  - search
  - llms
  - corpus
  - print
---

{{< downloads >}}

**Deckhouse Prom++** is an open-source monitoring system for high-load infrastructure, designed to collect metrics from various sources and analyze this data conveniently. It uses a combination of Golang and C++ programming languages at its core, which allows monitoring data to be stored in RAM in a highly compressed form, saving memory without compromising performance.

## Functional characteristics

### Metrics collection (pull model)

Deckhouse Prom++ works on a pull principle: it independently scrapes target sources via HTTP/HTTPS and receives metrics (monitoring data) from them in a format compatible with the Prometheus specification.
The metrics collected by Deckhouse Prom++ are time series with labels. Labels allow you to group and filter metrics for more detailed analysis.

### Data storage

Deckhouse Prom++ uses a special high-performance database on disk. This database can be described as a Time Series Database (TSDB).
Data is stored as time series divided into blocks, which allows for efficient processing of large volumes of metrics.
Deckhouse Prom++ does not have a traditional relational DBMS; storage and query optimization are tailored to work with time series.

### Query language (PromQL)

Deckhouse Prom++ implements PromQL (Prometheus Query Language), a query language that allows flexible operations with metrics over time (such as summing, averaging, or sampling by labels).
PromQL supports aggregation functions (`sum`, `avg`, `max`, `min`, `count`, etc.) and also allows you to create new time series based on existing ones.
The language allows you not only to extract raw data, but also to perform complex calculations, build graphs, and calculate various indicators (SLO/SLI), which simplifies analytics.

### Alerting rules and recording rules

**Recording Rules** allow you to pre-calculate the most frequently requested or resource-intensive metrics and save the results as new time series.
They are executed by Prometheus at a specified interval (for example, every 30 seconds or every minute). The result is written back to the TSDB database under a new metric name.
They speed up the creation of graphs and analytical queries, since aggregated data is used instead of "raw" metrics.

**Alerting Rules** define conditions (based on PromQL) for generating alerts if a metric exceeds specified limits or satisfies a certain expression. They support different levels of criticality, time intervals, ignoring certain labels, and other fine-grained settings.
When triggered, they send alert data to Alertmanager for further routing.

### Integration and collection of monitoring data from various sources

Deckhouse Prom++ can be easily integrated with numerous systems and services thanks to its standard metric export format. The Prometheus ecosystem already has a huge number of exporters that allow you to collect metrics from various systems, such as databases (MySQL, PostgreSQL, MongoDB), web servers (Nginx, Apache), infrastructure components (Docker, Kubernetes, etcd), etc.

The configuration of Deckhouse Prom++ is described in YAML files. They specify targets (endpoints for collecting metrics), jobs, polling frequency settings, alerting rules, etc.
When used in a Kubernetes environment, Deckhouse Prom++ can automatically discover new services and containers (service discovery), which greatly simplifies the monitoring of dynamic microservice environments.

### Visualization

The Deckhouse Prom++ web interface allows you to execute PromQL queries on the fly and view the results as a graph or list of data points. This is convenient for quick diagnostics and debugging.

### Federation

Deckhouse Prom++ is typically deployed separately in each cluster or subsystem, and then uses "federation" or other aggregation mechanisms to collect and analyze metrics at a higher level.
The Deckhouse Prom++ federation model allows a single Deckhouse Prom++ server to periodically request aggregated data from other Deckhouse Prom++ servers, which is especially useful in large distributed infrastructures.

### High performance

The data storage model and efficient catalog structure (tsdb) allow Deckhouse Prom++ to process thousands or even millions of metrics per second while maintaining high response speeds to queries.

**Supported operating systems:**

- MOS OS
- RED OS
- ROSA Server
- ALT Linux
- Astra Linux Special Edition
