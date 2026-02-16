---
title: "Установка"
weight: 7
---

## Конвертация WAL перед установкой

Deckhouse Prom++ использует другой формат WAL (Write-Ahead Log), но остается полностью совместимым с историческими блоками.  
Поскольку WAL содержит **последние 1.5 блока данных** (обычно около **3 часов**), если вы планируете использовать Deckhouse Prom++ в качестве замены Prometheus, необходима конвертация WAL для предотвращения потери данных.

См. [Руководство по миграции](#миграция-из-prometheus) для подробных шагов по конвертации.

## Предварительно скомпилированные бинарные файлы

1. Скачайте последний бинарный файл:
   * [amd архитектура](/products/prompp/documentation/downloads/latest/prompp-binaries-amd64.tar.gz)
   * [arm архитектура](/products/prompp/documentation/downloads/latest/prompp-binaries-arm64.tar.gz)

1. Распакуйте его:

   ```yaml
   tar zxf prompp-binaries-<amd64|arm64>.tar.gz
   ```

   Это создаст папку `prompp` с бинарным файлом `prompp` и конфигурационным файлом `prometheus.yml`.

1. Запустите его как замену для Prometheus:

   ```bash
   cd prompp
   ./prompp --config.file=prometheus.yml --storage.tsdb.path=data/
   ```

## Docker

Deckhouse Prom++ доступен в виде Docker-образа в следующих реестрах:
- `registry.deckhouse.ru/prompp/prompp`
- `ghcr.io/deckhouse/prompp`

Все доступные версии можно найти на [странице релизов](https://github.com/deckhouse/prompp/releases).

Чтобы быстро запустить контейнер:

```bash
docker run --name prompp -d -p 127.0.0.1:9090:9090 registry.deckhouse.ru/prompp/prompp:0.7.4
```

или используя GitHub Container Registry:

```bash
docker run --name prompp -d -p 127.0.0.1:9090:9090 ghcr.io/deckhouse/prompp:0.7.4
```  

После запуска Deckhouse Prom++ будет доступен по [http://localhost:9090/](http://localhost:9090/).

Вы также можете добавить собственную конфигурацию для Prom++, передав параметр config.file:

```bash
docker run --name prompp -v /path/on/host/prometheus.yml:/etc/prometheus.yml -d -p 127.0.0.1:9090:9090 registry.deckhouse.ru/prompp/prompp:0.7.4 --config.file=/etc/prometheus.yml
```

## Prometheus Operator

1. Создайте файл `prompp.yaml` со следующей конфигурацией (другие настройки могут зависеть от вашей установки):

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

1. Примените обновленный ресурс:

   ```bash
   kubectl apply -f prompp.yaml
   ```

## Миграция из Prometheus

### Ручная конвертация WAL

Если миграция происходит вручную, используйте утилиту `prompptool`, включенную в релиз.

#### Конвертация WAL Prometheus в формат Deckhouse Prom++

```bash
prompptool walvanilla --working-dir <path to prometheus data dir>
```  

#### Конвертация WAL Deckhouse Prom++ обратно в формат Prometheus

```bash
prompptool walpp --working-dir <path to prometheus data dir>
```

### Автоматическая конвертация WAL с помощью Prometheus Operator

#### Конвертация WAL Prometheus в формат Deckhouse Prom++

1. Создайте файл `prompp-migration.yaml` с следующей конфигурацией (дополнительные параметры могут зависеть от вашей установки):

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
     # Дополнительные параметры могут зависеть от вашей установки
   ```  

1. Примените обновленный ресурс:

   ```bash
   kubectl apply -f prompp-migration.yaml
   ```

#### Конвертация WAL Deckhouse Prom++ обратно в формат Prometheus

1. Измените `initContainer` в вашем файле `prompp-migration.yaml`:

   ```yaml
   command:
     - /bin/prompptool
     - "--working-dir=/prometheus"
     - "--verbose"
     - "walpp"
   ```

1. Примените изменения снова:

   ```bash
   kubectl apply -f prompp-migration.yaml
   ```
