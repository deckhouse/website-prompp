---
title: "Installation"
weight: 7
---

## WAL conversion before installation

Deckhouse Prom++ uses a different WAL (Write-Ahead Log) format, but remains fully compatible with historical blocks.  
Since WAL contains the **last 1.5 blocks of data** (usually about **3 hours**), if you plan to use Deckhouse Prom++ as a replacement for Prometheus, WAL conversion is necessary to prevent data loss.

See the [Migration Guide](#migration-from-prometheus) for detailed conversion steps.

## Precompiled binary files

1. Download the latest binary file:
   * [amd architecture](/products/prompp/documentation/downloads/latest/prompp-binaries-amd64.tar.gz)
   * [arm architecture](/products/prompp/documentation/downloads/latest/prompp-binaries-arm64.tar.gz)

1. Unpack it:

```yaml
   tar zxf prompp-binaries-<amd64|arm64>.tar.gz
   ```

   This will create a `prompp` folder with the `prompp` binary file and the `prometheus.yml` configuration file.

1. Run it as a replacement for Prometheus:

   ```bash
   cd prompp
   ./prompp --config.file=prometheus.yml --storage.tsdb.path=data/
   ```

## Docker

Deckhouse Prom++ is available as a Docker image in the following registries:
- `registry.deckhouse.ru/prompp/prompp`
- `ghcr.io/deckhouse/prompp`

All available versions can be found on the [releases page](https://github.com/deckhouse/prompp/releases).

To quickly start the container:

```bash
docker run --name prompp -d -p 127.0.0.1:9090:9090 registry.deckhouse.ru/prompp/prompp:0.7.4
```

or using GitHub Container Registry:

```bash
docker run --name prompp -d -p 127.0.0.1:9090:9090 ghcr.io/deckhouse/prompp:0.7.4
```  

After launching, Deckhouse Prom++ will be available at [http://localhost:9090/](http://localhost:9090/).

You can also add your own configuration for Prom++ by passing the config.file parameter:

```bash
docker run --name prompp -v /path/on/host/prometheus.yml:/etc/prometheus.yml -d -p 127.0.0.1:9090:9090 registry.deckhouse.ru/prompp/prompp:0.7.4 --config.file=/etc/prometheus.yml
```

## Prometheus Operator

1. Create a file named `prompp.yaml` with the following configuration (other settings may depend on your installation):

   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: Prometheus
   metadata:
     name: example-prometheus
     namespace: monitoring
   spec:
     image: registry.deckhouse.ru/prompp/prompp:0.7.4  # Replace Prometheus with Deckhouse Prom++
     securityContext:
       fsGroup: 64535
       runAsGroup: 64535
       runAsNonRoot: true
       runAsUser: 64535 
     # Additional parameters may be required based on your installation
   ```

1. Apply the updated resource:

   ```bash
   kubectl apply -f prompp.yaml
   ```

## Migration from Prometheus

### Manual WAL conversion

If migration is performed manually, use the `prompptool` utility included in the release.

#### Converting Prometheus WAL to Deckhouse Prom++ format

```bash
prompptool walpp --working-dir <path to prometheus data dir>
```

### Automatic WAL conversion using Prometheus Operator

#### Converting Prometheus WAL to Deckhouse Prom++ format

1. Create a file named `prompp-migration.yaml` with the following configuration (additional parameters may depend on your installation):

   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: Prometheus
   metadata:
     name: example-prometheus
     namespace: monitoring
   spec:
     ...
     image: registry.deckhouse.ru/prompp/prompp:0.7.4
     securityContext:
       fsGroup: 64535
       runAsGroup: 64535
       runAsNonRoot: true
       runAsUser: 64535 
     initContainers:
       - name: prompptool
         image: prompp/prompp:<tag>
         command:
           - /bin/prompptool
           - "--working-dir=/prometheus"
           - "walvanilla"
         volumeMounts:
           - name: prometheus-main-db
             mountPath: /prometheus
             subPath: prometheus-db
         resources:
           requests:
             cpu: "100m"
             memory: "128Mi"
     # Additional parameters may be required based on your installation
   ```

1. Apply the updated resource:

   ```bash
   kubectl apply -f prompp-migration.yaml
   ```
