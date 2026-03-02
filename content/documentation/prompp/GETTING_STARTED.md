---
title: "Getting started"
weight: 8
---

This is a "Hello, World!"-style guide that demonstrates how to install, configure, and use a simple instance of Deckhouse Prom++. You will download and run Deckhouse Prom++ locally, configure it to collect metrics about itself and a test application, and then work with queries, rules, and graphs to work with the collected time series.

## Downloading and running Deckhouse Prom++

[Install](../installation/) the latest version of Deckhouse Prom++ for your platform.

Then, configure Deckhouse Prom++ before launching it.

### Configuring Deckhouse Prom++ to monitor itself

Deckhouse Prom++ collects metrics from target objects by sequentially scraping their HTTP endpoints with metrics. Since Deckhouse Prom++ exposes data about its own status, it can also monitor its own status.
Although a Deckhouse Prom++ server that only collects data about itself is not very useful, it can be a good starting example.

Save the following basic configuration to a file named `prometheus.yml`:

```yaml
global:
  scrape_interval: 15s # By default, target objects are scraped every 15 seconds. These labels will be attached to all time series and alerts when interacting with external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'
```

### Scrape configuration with a single endpoint

In this case, it is Deckhouse Prom++ itself.

```yaml
scrape_configs:
  # The job name is added to the `job=<job_name>` label for all time series from this job.
  - job_name: ‘promplusplus’
  
  # Override the global scrape interval — for this job, it will be 5 seconds.
    scrape_interval: 5s
    static_configs:
      - targets: [‘localhost:9090’]
```

### Starting Deckhouse Prom++

To start Deckhouse Prom++ with a new configuration file, navigate to the directory containing the Deckhouse Prom++ binary file and run:

```shell
# By default, the Prom++ database is stored in ./data (option --storage.tsdb.path).
./prompp --config.file=prometheus.yml
```

Deckhouse Prom++ should start successfully.

Open your browser and go to the Deckhouse Prom++ status page at <http://localhost:9090>. Give Prom++ a little time to collect data about itself via its own HTTP metrics endpoint.

To ensure Deckhouse Prom++ publishes its metrics, go to <http://localhost:9090/metrics>.

## Using the expression browser

To examine the data that Deckhouse Prom++ has collected about itself, go to the built-in expression browser at <http://localhost:9090/graph> → "Graph" tab → "Table" view.

As you can see on the page <http://localhost:9090/metrics>, one of the metrics that Deckhouse Prom++ exports about itself is `prometheus_target_interval_length_seconds` (the actual interval between target object scrapes). Enter the following expression in the query console and click "Execute":

```text
prometheus_target_interval_length_seconds
```

This will return several time series (with the latest stored values), each with the metric name `prometheus_target_interval_length_seconds`, but with different labels. These labels indicate different percentile delays and target grouping intervals.

If you are only interested in the 99th percentile latencies, use the following query:

```text
prometheus_target_interval_length_seconds{quantile="0.99"}
```

To count the number of returned time series, use the following query:

```text
count(prometheus_target_interval_length_seconds)
```

## Using the graph interface

To build a graph based on expressions, go to <http://localhost:9090/graph> → "Graph" tab.

For example, to build a graph of the rate of new chunks created in the self-scraped Deckhouse Prom++ instance, use the following query:

```text
rate(prometheus_tsdb_head_chunks_created_total[1m])
```

Try experimenting with range parameters and other settings.

## Reloading configuration without restarting

Deckhouse Prom++ lets you apply a new configuration without restarting by sending a `SIGHUP` signal to the process:

```shell
kill -s SIGHUP <PID>
```

## Correctly terminating Deckhouse Prom++

To correctly terminate Deckhouse Prom++, use the `SIGTERM` signal:

```shell
kill -s SIGTERM <PID>
```
