---
title: "HTTP Service Discovery (HTTP SD)"
weight: 38
---

Deckhouse Prom++ provides a generic HTTP Service Discovery (HTTP SD) mechanism that enables it to discover targets over an HTTP endpoint.

HTTP SD is complementary to the supported service discovery mechanisms, and is an alternative to File-based SD.

## Comparison between File-based SD and HTTP SD

Below is a table comparing two generic Service Discovery implementations.

| Parameter             | File-based SD                          | HTTP SD                          |
|----------------------|----------------------------------|----------------------------------|
| Event-based | Yes, via inotify                | No                              |
| Update frequency   | Instant, thanks to inotify     | Following `refresh_interval`        |
| Format               | YAML or JSON                    | JSON                             |
| Transport            | Local file                   | HTTP/HTTPS                       |
| Безопасность         | File permissions           | TLS, Basic auth, Authorization header, OAuth2 |

## Requirements to HTTP SD endpoints

If you implement an HTTP SD endpoint, here are a few requirements you should be aware of.

The response is consumed as is, unmodified. On each refresh interval (default: 1 minute), Deckhouse Prom++ will perform a GET request to the HTTP SD endpoint. The GET request contains a `X-Deckhouse Prom++-Refresh-Interval-Seconds` HTTP header with the refresh interval.

The SD endpoint must answer with an HTTP 200 response, with the HTTP Header Content-Type: application/json. The answer must be UTF-8 formatted. If no targets should be transmitted, HTTP 200 must also be emitted, with an empty list `[]`. Target lists are unordered.

Deckhouse Prom++ caches target lists. If an error occurs while fetching an updated targets list, Deckhouse Prom++ keeps using the current targets list. The targets list is not saved across restart. The `prompp_sd_http_failures_total` counter metric tracks the number of refresh failures.

The whole list of targets must be returned on every scrape. There is no support for incremental updates. A Deckhouse Prom++ instance does not send its hostname and it is not possible for a SD endpoint to know if the SD request is the first one after a restart or not.

The URL to the HTTP SD is not considered secret. The authentication and any API keys should be passed with the appropriate authentication mechanisms. Deckhouse Prom++ supports TLS authentication, basic authentication, OAuth2, and authorization headers.

## HTTP SD format

```yml
[
  {
    "targets": [ "<host>", ... ],
    "labels": {
      "<labelname>": "<labelvalue>", ...
    }
  },
  ...
]
```

Examples:

```yml
[
    {
        "targets": ["10.0.10.2:9100", "10.0.10.3:9100", "10.0.10.4:9100", "10.0.10.5:9100"],
        "labels": {
            "__meta_datacenter": "london",
            "__meta_prompp_job": "node"
        }
    },
    {
        "targets": ["10.0.40.2:9100", "10.0.40.3:9100"],
        "labels": {
            "__meta_datacenter": "london",
            "__meta_prompp_job": "alertmanager"
        }
    },
    {
        "targets": ["10.0.40.2:9093", "10.0.40.3:9093"],
        "labels": {
            "__meta_datacenter": "newyork",
            "__meta_prompp_job": "alertmanager"
        }
    }
]
```
