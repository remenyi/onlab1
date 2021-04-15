# Skálázódás custom metrikák alapján

## Promethesus és Grafana telepítése

[Ennek](https://www.youtube.com/watch?v=QoDqxm7ybLc) a videónak az alapján.

- Prometheus Operator installálása Helmel:

  ```
  helm install prometheus stable/prometheus
  ```

- Prometheus UI elérése:

  ```
  kubectl port-forward service/prometheus-prometheus-oper-prometheus 9090
  ```

- Grafana elérése:

  ```
  kubectl port-forward deployment/prometheus-grafana 3000
  ```

Böngészőben: `localhost:3000`

felhasználónév: `admin`

jelszó: `prom-operator`

## Metrikák exportálása Prometheusba

- A NodeJS Express-hez létezik prometheus express middleware (__express-prometheus-middleware__ node package), amely a /metrics endpointra teszi i a metrikákat. Így a NodeJS server legyártható [ez](./container/server.js) lesz.

- Ezután a Prometheus-nak fel kell fedeznie az endpointot. Ezt egy ServiceMonitor objektummal lehet megcsinálni, amely labelek segítségével kiválasztja a monitorozandó alkalmazást és megadja a portjait. A prometheus a létrehozásakor beállított labelek segítségével találja meg a megfelelelő ServiceMonitor objektumokat. Nálam ez [így](./node-hpa-example/templates/service-monitor.yaml) néz ki.

- A prometheus webkliensen a Status fül alatt a Targets oldalon láthatóak, hogy sikeresen megtalálta-e az endpointokat (Valamiért nekem kétszer jelenik meg...).

## Metrikák megjelenítése Grafanán

- HTTP alapú metrikák:

  - Az összes http kérés: `http_requests_total{service="node-hpa-example"}`

  - http kérések száma egy másodpercre vetítve: `sum(rate(http_requests_total{service="node-hpa-example"}[5m]))`

  - Átlagos válaszidő másodpercben egy másodpercre vetítve: `sum(rate(http_request_duration_seconds_sum{service="node-hpa-example"}[5m])) by (instance) / sum(rate(http_request_duration_seconds_count{service="node-hpa-example"}[5m])) by (instance)`

- Resource metrikák:

  - CPU: `rate(process_cpu_system_seconds_total{service="node-hpa-example"}[5m]) + rate(process_cpu_user_seconds_total{service="node-hpa-example"}[5m])`

  - Memória:

    - Total: `nodejs_heap_size_total_bytes{service="node-hpa-example"}`

    - Used: `nodejs_heap_size_used_bytes{service="node-hpa-example"}`

- Futó podok száma: `sum(up{service="node-hpa-example"})`

- [Dashboard JSON-ban](./grafana_dashboard.json)

## Prometheus-adapter

- Telepítés:

  ```
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  helm install --name my-release prometheus-community/prometheus-adapter 
  ```

- Források:

  - [Egy példa](https://github.com/kubernetes-sigs/prometheus-adapter/blob/master/docs/walkthrough.md)

  - [Konfigurálás](https://github.com/kubernetes-sigs/prometheus-adapter/blob/master/docs/config.md)

  - [Egy videó a készítőktől](https://www.youtube.com/watch?v=paO2kwHWOLw)

- Konfigurálás verifikálása:

  - Ügyelni kell: prometheus metrics scrape interval < prometheus adapter metrics relist interval

  - configmap lekérése: `kubectl get configmap prometheus-adapter -o jsonpath='{.data.config\.yaml}'`

  - custom metrics api lekérése: `kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1`

  - http_requests metrika lekérése: `kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests_per_second?" | jq .`

## Terhelésgenerálás

Ez port-forwardinggal nem működik, mert mindig csak egy podot port-forwardingol, így nem működik a terheléseloszlás sem.

A k6-nak van kubernetes operátora, igaz, csak béta állapotban.

Viszont a k6 operátor használata újabb nehézségekkel jár.

  - Telepítés:

  ```
  kubectl config get-contexts
  make deploy
  ```

  - Terhelés teszt futtatása:

    1. teszt írása pl. test.js file-ba

    2. configmap generálása a tesztfájlból:

    ```
    kubectl create configmap crocodile-stress-test --from-file test.js
    ```

    3. custom resource írása, amivel az operátor megtalálja a tesztfájlt tartalmazó configmapot 

    ```
    apiVersion: k6.io/v1alpha1
    kind: K6
    metadata:
      name: k6-sample
    spec:
      parallelism: 4                  # mennyi jobot generáljon
      script: crocodile-stress-test   # mi a tesztfájlt tartalmazó configmap neve
      separate: false                 # futhatnak-e egy node-on a jobok
      arguments: ""                   # cli-nek megfelelő argumentumok
    ```

    4. custom resource deploymentje

    ```
    kubectl apply -f custom-resource.yml
    ```

    5. ellenőrzés:

    ```
    kubectl get k6
    kubectl get jobs
    kubectl get pods
    kubectl logs [az egyik pod, igazából tök mindegy melyik]
    ```

    6. Szemétszedés:

    ```
    kubectl delete -f custom-resource.yml
    ```