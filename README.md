# Prometheus File Service Discovery

A script that will read your containers in docker cloud, find nodes for prometheus, and write a json file for prometheus.

### Usage

This uses dockercloud's role authorization for API access.  Also, 2-3 environment variables need to provided, shown in the example.  Furthermore, this role will need to share a volume with prometheus.

CONTAINERS should be space delimited in the following format: stac2:service1:port1 stack2:service2:port2.

DIR should be the directory that prometheus is configured to read its file service discovery from.

An optional variable file prefix will prepend the string to the json files for prometheus.  If it is not provided, the default is "file-sd-"

```
prometheus-file-service-discovery:
  image: searchspring/prometheus-file-sd:latest
  environment:
    - CONTAINERS=Prometheus:cadvisor:8080 Prometheus:node-exporter:9100
    - DIR=/prometheus
    - FILE_PREFIX=file-sd-
  volumes_from:
    - prometheus
```

