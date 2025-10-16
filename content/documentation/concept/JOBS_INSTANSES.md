---
title: "Service labels and metrics"
weight: 5
---

In Deckhouse Prom++ terms, the endpoint from which metrics can be collected is called an instance—usually a single worker process.  
A set of instances with the same purpose—for example, replicas of the same process used for scaling or fault tolerance—is called a job.

For example, an API server job with four replicas instances:

- job: `api-server`
  - instance 1: `1.2.3.4:5670`
  - instance 2: `1.2.3.4:5671`
  - instance 3: `5.6.7.8:5670`
  - instance 4: `5.6.7.8:5671`

## Automatically generated labels and time series

When Deckhouse Prom++ polls the target endpoint (target), it automatically adds several service labels to the collected time series to help identify the data source:

- `job`: The name of the job to which the target system belongs, according to the configuration.
- `instance`: Part of the target service URL in the format `<host>:<port>` from which the data was collected.

If any of these labels (`job` or `instance`) are already present in the source data, the behavior is determined by the `honor_labels` setting.
For more details, see the documentation on configuring [data collection (scraping)](../../prompp/configuration/configuration/#scrape_config).

Each time data is collected (scraping), the Deckhouse Prom++ instance creates several additional time series:

- `up{job="<job-name>", instance="<instance-id>"}`: Equal to `1` if the instance is available (scrape was successful) and `0` if the poll failed.
- `scrape_duration_seconds{job="<job-name>", instance="<instance-id>"}`: Polling duration in seconds.
- `scrape_samples_post_metric_relabeling{job="<job-name>", instance="<instance-id>"}`: The number of metrics after applying metric relabeling rules.
- `scrape_samples_scraped{job="<job-name>", instance="<instance-id>"}`: The total number of metrics received from the target system for the poll.
- `scrape_series_added{job="<job-name>", instance="<instance-id>"}`: Approximate number of new time series added per poll.

The `up` time series is widely used to monitor instance availability.

If the `extra-scrape-metrics` flag is enabled, the following metrics are additionally available:

- `scrape_timeout_seconds{job="<job-name>", instance="<instance-id>"}`: The configured `scrape_timeout` value for the target system.
- `scrape_sample_limit{job="<job-name>", instance="<instance-id>"}`: The configured limit on the number of metrics (`sample_limit`) to poll. If no limit is specified, a value of 0 will be returned.
- `scrape_body_size_bytes{job="<job-name>", instance="<instance-id>"}`: The size of the last poll response (in bytes) if the poll was successful. If an error occurs due to exceeding the `body_size_limit`, `-1` will be returned; in other cases of unsuccessful polling, `0` will be returned.
