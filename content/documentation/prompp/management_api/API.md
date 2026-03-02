---
title: "Management API"
weight: 40
---

Deckhouse Prom++ provides a set of management APIs to facilitate automation and integration.

## Health check

```yml
GET /-/healthy
HEAD /-/healthy
```

This endpoint always returns the `200`status and should be used to check Deckhouse Prom++ health.

## Readiness check

```yml
GET /-/ready
HEAD /-/ready
```

This endpoint returns the `200` status when Deckhouse Prom++ is ready to serve traffic (meaning, respond to queries).

## Reload

```yml
PUT  /-/reload
POST /-/reload
```

This endpoint triggers a reload of the Deckhouse Prom++ configuration and rule files. It's disabled by default and can be enabled via the `--web.enable-lifecycle` flag.

Alternatively, a configuration reload can be triggered by sending a `SIGHUP` to the Deckhouse Prom++ process.

## Quit

```yml
PUT  /-/quit
POST /-/quit
```

This endpoint triggers a graceful shutdown of Deckhouse Prom++. It's disabled by default and can be enabled via the `--web.enable-lifecycle` flag.

Alternatively, a graceful shutdown can be triggered by sending a `SIGTERM` to the Deckhouse Prom++ process.
