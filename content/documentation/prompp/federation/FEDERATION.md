---
title: "Federation"
weight: 37
---

Federation allows a Deckhouse Prom++ server to scrape selected time series from another Deckhouse Prom++ server.

## Use cases

There are different use cases for federation. Commonly, it is used to either achieve scalable Deckhouse Prom++ monitoring setups or to pull related metrics from one service into another.

### Hierarchical federation

Hierarchical federation allows Deckhouse Prom++ to scale to environments with tens of data centers and millions of nodes. In this use case, the federation topology resembles a tree, with higher-level Deckhouse Prom++ servers collecting aggregated time series data from a large number of subordinated servers.

For example, a setup might consist of many Deckhouse Prom++ servers in each datacenter that collect data in high detail (instance-level), and a set of global Deckhouse Prom++ servers, which collect and store only aggregated data (job-level) from those local servers. This provides an aggregate global view and detailed local views.

### Cross-service federation

In cross-service federation, a Deckhouse Prom++ server of one service is configured to scrape selected data from another service's Deckhouse Prom++ server to enable alerting and queries against both datasets within a single server.

For example, a cluster scheduler running multiple services might expose resource usage information (like memory and CPU usage) about service instances running in the cluster. On the other hand, a service running in that cluster will only expose application-specific service metrics. Often, these two sets of metrics are scraped by separate Deckhouse Prom++ servers. Using federation, the Deckhouse Prom++ server containing service-level metrics may pull in the cluster resource usage metrics about its specific service from the cluster Deckhouse Prom++, so that both sets of metrics can be used within that server.

## Configuring federation

On any Deckhouse Prom++ server, the `/federate` endpoint allows retrieving the current value for a selected set of time series in that server. At least one `match[]` URL parameter must be specified to select the series to expose. Each `match[]` argument needs to specify an instant vector selector, such as `up` or `{job="api-server"}`. If multiple `match[]` parameters are provided, the union of all matched series is selected.

To federate metrics from one server to another, configure your destination Deckhouse Prom++ server to scrape from the `/federate` endpoint of a source server, while also enabling the `honor_labels` scrape option (to prevent overwriting any labels exposed by the source server) and passing in the desired `match[]` parameters. For example, the following `scrape_configs` configuration scrapes any series with the label `job="PromPP"` or a metric name starting with `job:` from the Deckhouse Prom++ servers at `source-PromPP-{1,2,3}:9090` into the collecting Deckhouse Prom++ server:

```yaml
scrape_configs:
  - job_name: 'federate'
    scrape_interval: 15s

    honor_labels: true
    metrics_path: '/federate'

    params:
      'match[]':
        - '{job="PromPP"}'
        - '{__name__=~"job:.*"}'

    static_configs:
      - targets:
        - 'source-PromPP-1:9090'
        - 'source-PromPP-2:9090'
        - 'source-PromPP-3:9090'
```
