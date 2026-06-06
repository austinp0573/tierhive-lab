# adguard-home on 128MB alpine

Build the dockerfile

```bash
docker build -t adguard-micro:latest .
```

Save the dockerfile

```bash
docker save adguard-micro:latest | xz -9e adguard-micro.tar.xz
```

Send it to the VPS

```bash
scp adguard-micro.tar.xz root@<VPS_IP>:/tmp/
```

## On the VPS

Load the image

```bash
podman load -i /tmp/adguard-micro.tar.xz
```

Make the appropriate directories

```sh
mkdir -p /opt/adguard-deploy/data/conf
mkdir -p /opt/adguard-deploy/data/work
```

## Not on the VPS

SCP over the appropriate files

```bash
scp AdGuardHome.yaml vps:/opt/adguard-deploy/data/conf/
scp run-adguard.sh vps:/root/
```

## Back on the VPS

Run the container

```sh
./run-adguard.sh
```