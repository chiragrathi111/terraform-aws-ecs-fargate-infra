#!/bin/bash

DATE=$(date '+%Y-%m-%d_%H-%M-%S')

DB_NAME="hoteldb"
DB_USERNAME="admin"
DB_PASSWORD="password"

BACKUP_DIR="/backup"
mkdir -p "$BACKUP_DIR"

BACKUP_FILE="${BACKUP_DIR}/database_backup_${DATE}.sql"

export PGPASSWORD="$DB_PASSWORD"

pg_dump \
  -h localhost \
  -p 5432 \
  -U "$DB_USERNAME" \
  -d "$DB_NAME" \
  --no-owner \
  > "$BACKUP_FILE"

unset PGPASSWORD