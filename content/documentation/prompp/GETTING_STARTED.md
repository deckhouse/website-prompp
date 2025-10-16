---
title: "Getting started"
weight: 8
---

This is a "Hello, World!" style guide that demonstrates how to install, configure, and use a simple instance of Deckhouse Prom++. You will download and run Deckhouse Prom++ locally, configure it to collect metrics about itself and a test application, and then work with queries, rules, and graphs to work with the collected time series.

## Downloading and Running Deckhouse Prom++

[Install](../installation/) the latest version of Deckhouse Prom++ for your platform.

Before launching Deckhouse Prom++, let's configure it.

### Configuring Deckhouse Prom++ to monitor itself

Deckhouse Prom++ collects metrics from target objects by sequentially querying their HTTP endpoints with metrics. Since Deckhouse Prom++ provides data about its own status, it can also monitor its own status.
Although a Deckhouse Prom++ server that only collects data about itself is not very useful, it is a good starting example. Save the following basic configuration file under the name prometheus.yml:

```yaml
global:
  scrape_interval: 15s # By default, target objects are polled every 15 seconds. These tags will be attached to all time series and alerts when interacting with external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'
```

### Configuration of a survey with a single endpoint

In this case, it is Deckhouse Prom++ itself.

```yaml
scrape_configs:
  #The job name is added to the `job=<job_name>` tag for all time series from this job.
  - job_name: ‘promplusplus’
  
  #Override the global polling interval — for this job, it will be every 5 seconds.
    scrape_interval: 5s
    static_configs:
      - targets: [‘localhost:9090’]
```

### Starting Deckhouse Prom++

To start Deckhouse Prom++ with a new configuration file, navigate to the directory containing the Deckhouse Prom++ binary file and run:
By default, the database is stored in ./data (option --storage.tsdb.path).

```yaml
./prompp --config.file=prometheus.yml
```

Deckhouse Prom++ should start successfully. Open your browser and go to the Deckhouse Prom++ status page at:
http://localhost:9090. Give it a few seconds to collect data about itself via its own HTTP metrics endpoint.
You can also check if Deckhouse Prom++ is publishing its metrics by going to:
http://localhost:9090/metrics.

### Using the expression browser

Let's examine the data that Deckhouse Prom++ has collected about itself. Go to the built-in expression browser of Deckhouse Prom++ at http://localhost:9090/graph and select the "Table" view on the "Graph" tab.
As you can see on the page http://localhost:9090/metrics, one of the metrics that Deckhouse Prom++ exports about itself is prometheus_target_interval_length_seconds (the actual interval between polls of target objects). Enter the following expression in the query console and click "Execute":
prometheus_target_interval_length_seconds

This will return several time series (with the latest stored values), all with the metric name prometheus_target_interval_length_seconds, but with different labels indicating different percentile delays and target grouping intervals.
If we are only interested in the 99th percentile of delays, we can use the following query:
prometheus_target_interval_length_seconds{quantile="0.99"}.

To count the number of returned time series, use:
count(prometheus_target_interval_length_seconds)

### Using the graph interface

To build a graph based on expressions, go to http://localhost:9090/graph and select the "Graph" tab.
For example, to build a graph of the rate of new chunks created in a self-scanning instance of Deckhouse Prom++, use:
rate(prometheus_tsdb_head_chunks_created_total[1m])

Try experimenting with range parameters and other settings.

### Reloading configuration without restarting

Deckhouse Prom++ allows you to apply a new configuration without restarting by sending a SIGHUP signal to the process:

```yaml
kill -s SIGHUP <PID>
```

### Correctly terminating Deckhouse Prom++

To correctly terminate Deckhouse Prom++, use the SIGTERM signal:

```yaml
kill -s SIGTERM <PID>
```
