# PostgreSQL Setup Using Docker

## Prerequisites

If Docker is not installed, run the following commands.

```bash
sudo apt update -y
sudo apt upgrade -y

sudo apt install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Start and enable the Docker service.

```bash
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker
```

Verify the installation.

```bash
docker --version
docker compose version
```

Allow the current user to run Docker commands without `sudo`.

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verify Docker is running.

```bash
docker ps
```

---

# Start PostgreSQL Container

Start the PostgreSQL container using Docker Compose.

```bash
docker compose -f docker-compose.yml up -d
```

Verify the container is running.

```bash
docker ps
```

Example output:

```text
CONTAINER ID   IMAGE         NAME
xxxxxxxxxxxx   postgres:16   hotel-postgres
```

---

# Connect to PostgreSQL

Open a shell inside the container.

```bash
docker exec -it hotel-postgres bash
```

```bash
cd /sql
ls

Output :-
V1__Create_hotel_bookings.sql
V2__Create_booking_events.sql
```

Login to PostgreSQL.

```bash
psql -U admin -d hoteldb
```
```Run 
\i /sql/V1__Create_hotel_bookings.sql

\i /sql/V2__Create_booking_events.sql
```
---

# Verify Tables

List all tables in the current database.

```sql
\dt
```

Expected output:

```text
              List of relations
 Schema |       Name        | Type  | Owner
--------+-------------------+-------+-------
 public | booking_events    | table | admin
 public | hotel_bookings    | table | admin
```

(Optional) View the schema of a table.

```sql
\d hotel_bookings
```

```sql
\d booking_events
```