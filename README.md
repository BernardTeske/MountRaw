
# Docker Compose Setup for Mounting a .raw File

After the provider DomainFactory discontinued its JiffYBox products, I had the problem of how to make backups of the VMs accessible on my Mac. I solved it with Docker and it works.

## Installation

### 1. Install Docker and Docker Compose
Make sure Docker and Docker Compose are installed on your Mac.

- Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop) and install it.
- Docker Compose is usually included in Docker Desktop.

### 2. Create the Docker Compose File
Create a directory for your project and add a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  ext4mount:
    image: ubuntu:latest
    container_name: ext4mount
    privileged: true
    volumes:
      - ./file.raw:/file.raw
      - ./mnt:/mnt
    command: tail -f /dev/null
```

### 3. Start the Container with Docker Compose
Navigate to the directory where your `docker-compose.yml` file is located and start the container:

```bash
docker-compose up -d
```

### 4. Connect to the Container and Install Required Tools
Connect to the running container:

```bash
docker exec -it ext4mount bash
```

In the container, install the required tools:

```bash
apt update
apt install -y losetup mount
```

### 5. Mount the `.raw` File
Run the following commands in the container to mount the `.raw` file:

1. **Set up the loopback device**:
   ```bash
   losetup -fP /file.raw
   ```

2. **Display partition information**:
   ```bash
   lsblk
   ```

3. **Mount the partition**:
   Assuming the partition is `/dev/loop0p1`, mount it:
   ```bash
   mount /dev/loop0p1 /mnt
   ```

You should now be able to access the data in the `.raw` file in the `/mnt` directory.

### 6. Automate the Steps (Optional)
You can also automate these steps by integrating them into your Docker Compose setup. Create a shell script that executes these commands and include it in your `docker-compose.yml` file:

#### Shell Script (`mount-raw.sh`):
```bash
#!/bin/bash
apt update
apt install -y losetup mount
losetup -fP /file.raw
mount /dev/loop0p1 /mnt
tail -f /dev/null
```

#### Update `docker-compose.yml`:
```yaml
version: '3.8'

services:
  ext4mount:
    image: ubuntu:latest
    container_name: ext4mount
    privileged: true
    volumes:
      - ./file.raw:/file.raw
      - ./mnt:/mnt
      - ./mount-raw.sh:/mount-raw.sh
    entrypoint: /mount-raw.sh
```

Make sure the script is executable:

```bash
chmod +x mount-raw.sh
```

Restart the container:

```bash
docker-compose up -d
```
