# Hotel Booking Infrastructure Assignment

This repository contains the infrastructure, database setup, migration scripts, seed data, and utility scripts required for the Hotel Booking application.

---

# Project Structure

```text
.
├── terraform/
│   ├── dev/
│   └── prod/
├── docker-compose.yml
├── sql/
│   ├── V1__Create_hotel_bookings.sql
│   ├── V2__Create_booking_events.sql
│   ├── V3__Seed_Data.sql
│   └── V4__Indexes.sql
├── scripts/
│   ├── backup.sh
│   └── restore.sh
└── README.md
```

---

# Prerequisites

- Docker
- Docker Compose
- Terraform
- PostgreSQL Client (`psql`)

---

# 1. Terraform

The repository contains separate Terraform examples for different environments.

```text
terraform/
├── dev/
└── prod/
```

Each environment can be initialized independently.

```bash
cd terraform/dev
terraform init
terraform plan
terraform apply
```

For production:

```bash
cd terraform/prod
terraform init
terraform plan
terraform apply
```

---

# 2. Docker Compose

Start PostgreSQL.

```bash
docker compose up -d
```

Verify the container.

```bash
docker ps
```

Expected container:

```text
hotel-postgres
```

---

# 3. Connect to PostgreSQL

Open a shell inside the container.

```bash
docker exec -it hotel-postgres bash
```

Connect to the database.

```bash
psql -U admin -d hoteldb
```

---

# 4. SQL Migration Files

Migration scripts are located in:

```text
sql/
```

Files:

```text
V1__Create_hotel_bookings.sql
V2__Create_booking_events.sql
V3__Seed_Data.sql
V4__Indexes.sql
```

Execute them in order.

```sql
\i /sql/V1__Create_hotel_bookings.sql
```

```sql
\i /sql/V2__Create_booking_events.sql
```

```sql
\i /sql/V3__Seed_Data.sql
```

```sql
\i /sql/V4__Indexes.sql
```

---

# 5. Seed Data

The seed script inserts:

- 100 hotel bookings
- Multiple cities
- Multiple organizations
- Multiple booking statuses
- Booking events for sample bookings

Verify:

```sql
SELECT COUNT(*) FROM hotel_bookings;
```

---

# 6. Index

The following composite index is created to optimize the reporting query.

```sql
CREATE INDEX idx_city_created_at
ON hotel_bookings(city, created_at);
```

Reason:

The query filters records using `city` and `created_at`. A composite index on these columns reduces table scans and improves query performance.

---

# 7. Backup

Run the backup script.

```bash
./scripts/backup.sh
```

Backup files are stored in:

```text
/backup
```

---

# 8. Restore

Restore the latest available backup.

```bash
./scripts/restore.sh
```

> **Note:** The target database should be empty before running the restore script to avoid conflicts with existing tables or data.

---

# 9. Verification

List available tables.

```sql
\dt
```

Expected:

```text
booking_events
hotel_bookings
```

Check booking count.

```sql
SELECT COUNT(*) FROM hotel_bookings;
```

Run the aggregation query.

```sql
SELECT
    org_id,
    status,
    COUNT(*),
    SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

---

# Deliverables

- Terraform infrastructure code
- Terraform examples for dev and prod
- Docker Compose database setup
- SQL migration files
- Seed data script
- Database backup script
- Database restore script
- Setup and verification guide