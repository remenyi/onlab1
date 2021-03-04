# Kubernetes

## Gépek

- node1:
      - ip: 172.23.115.138/20
- Konfig:
      - statikus ip: `sudo nvim /etc/netplan/99_config.yaml` fájlba

    `network:
       version: 2
       renderer: networkd
       ethernets:
         eth0:
            addresses:
              - 172.23.115.13x/20
          gateway4: 172.23.112.1
        nameservers:
          addresses: [8.8.8.8, 192.168.0.1]`

      majd `sudo netplan apply`

- hosztnév beállítása a hoszton: Windowsos `/etc/hosts`, ami `C:/Windows/System32/drivers/etc/hosts`
- fájlok másolása: WSL-ből scp-vel pl.: scp . gergo@node1/home/gergo/onlab1

## Komponensek

### Control Plane komponensek

Az egész cluster működéséért felelősek, minden node-on jelen lehetnek

- kube-apiserver
- etcd: k-v tároló cluster konfigurációnak
- kube-scheduler: pod ütemező
- kube-controller-manager: ellenőrzi/irányítja a clustert (pl.: lehalt-e egy node, fel kell-e éleszteni podokat egy feladat elvégzéséhez, mely service-k és podok tartoznak össze) 
- cloud-controller-manager: kapcsolat a felhő API-val

### Node komponensek

Minden Node-on futnak

- kubelet: podok futásáért felel
- kube-proxy: hálózati proxy az os fölött, amellyel megvalósíthatóak a service-k
- Container runtime: konténereket futtat (pl.: docker, containerd)

### Kiegészítők

- DNS: Dns rekordok service-eknek
- Dashboard: webes felület
- Container Resource Monitoring: konténer monitorozás idősoros metrika alapján
- Cluster-level Logging: konténerek logjai központi adatbázisba

## Objektumok

A cluster állapotát reprezentálják

### Objektum konfiguráció

- Példa egy deploymentre

    `apiVersion: apps/v1 # API verzió
     kind: Deployment #objektum típusa
     metadata:
       name: nginx-deployment
     spec:
       selector:
         matchLabels:
           app: nginx
       replicas: 2 # tells deployment to run 2 pods matching the template
       template:
         metadata:
           labels:
             app: nginx
         spec:
           containers:
             - name: nginx
               image: nginx:1.14.2
               ports:
               - containerPort: 80`

- egyes objektumokhoz tartozó konfig [itt](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/)
- Labels: k-v értékek hozzácsatolása egy objektumhoz
- Selectors: objektumok kiválasztása labelek alapján