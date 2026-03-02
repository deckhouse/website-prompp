---
title: "Installation"
weight: 7
---

## WAL conversion before installation

Deckhouse Prom++ uses an alternative WAL (Write-Ahead Log) format, but remains fully compatible with historical blocks.  
Since WAL contains the **last 1.5 blocks of data** (usually about **3 hours**), if you plan to use Deckhouse Prom++ as a replacement for Prometheus, you should convert WAL to prevent data loss.

See the [migration guide](#migration-from-prometheus) for detailed conversion steps.

## Precompiled binary files

1. Download the latest binary file considering the required architecture:
   * [amd64](/products/prompp/documentation/downloads/latest/prompp-binaries-amd64.tar.gz)
   * [arm64](/products/prompp/documentation/downloads/latest/prompp-binaries-arm64.tar.gz)

1. Unpack it:

   ```bash
   tar zxf prompp-binaries-<amd64|arm64>.tar.gz
   ```

   This will create a `prompp` folder with the `prompp` binary file and the `prometheus.yml` configuration file.

1. Run it as a Prometheus replacement:

   ```bash
   cd prompp
   ./prompp --config.file=prometheus.yml --storage.tsdb.path=data/
   ```

## Docker

Deckhouse Prom++ is available as a Docker image in the following registries:

* `registry.deckhouse.io/prompp/prompp`
* `ghcr.io/deckhouse/prompp`

All available versions can be found on the [Releases](https://github.com/deckhouse/prompp/releases) page.

To quickly start the container, run the following command:

```bash
docker run --name prompp -d -p 127.0.0.1:9090:9090 registry.deckhouse.io/prompp/prompp:0.7.4
```

Alternatively, use GitHub Container Registry:

```bash
docker run --name prompp -d -p 127.0.0.1:9090:9090 ghcr.io/deckhouse/prompp:0.7.4
```  

After launching, Deckhouse Prom++ will be available at [http://localhost:9090/](http://localhost:9090/).

You can also add your own Prom++ configuration by passing the `--config.file` parameter:

```bash
docker run --name prompp -v /path/on/host/prometheus.yml:/etc/prometheus.yml -d -p 127.0.0.1:9090:9090 registry.deckhouse.io/prompp/prompp:0.7.4 --config.file=/etc/prometheus.yml
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
     image: registry.deckhouse.io/prompp/prompp:0.7.4  # Replace Prometheus with Deckhouse Prom++.
     securityContext:
       fsGroup: 64535
       runAsGroup: 64535
       runAsNonRoot: true
       runAsUser: 64535 
     # Additional parameters may be required based on your installation.
   ```

1. Apply the updated resource:

   ```bash
   kubectl apply -f prompp.yaml
   ```

## Migration from Prometheus

### Manual WAL conversion

If migration is performed manually, use the `prompptool` utility included in the release.

#### Converting Prometheus WAL to Deckhouse Prom++

To convert Prometheus WAL to the Deckhouse Prom++ format, run the following command:

```bash
prompptool walvanilla --working-dir <path to prometheus data dir>
```  

#### Converting Deckhouse Prom++ WAL back to Prometheus

To convert Deckhouse Prom++ WAL to the Prometheus format, run the following command:

```bash
prompptool walpp --working-dir <path to prometheus data dir>
```

### Automatic WAL conversion using Prometheus Operator

#### Converting Prometheus WAL to Deckhouse Prom++

1. Create a file named `prompp-migration.yaml` with the following configuration (additional parameters may depend on your installation):

   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: Prometheus
   metadata:
     name: example-prometheus
     namespace: monitoring
   spec:
     ...
     image: registry.deckhouse.io/prompp/prompp:0.7.4
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
     # Additional parameters may be required based on your installation.
   ```

1. Apply the updated resource:

   ```bash
   kubectl apply -f prompp-migration.yaml
   ```

#### Converting Deckhouse Prom++ WAL back to Prometheus

1. Edit `initContainer` in your `prompp-migration.yaml` file:

   ```yaml
   command:
     - /bin/prompptool
     - "--working-dir=/prometheus"
     - "--verbose"
     - "walpp"
   ```

1. Apply the changes:

   ```bash
   kubectl apply -f prompp-migration.yaml
   ```
