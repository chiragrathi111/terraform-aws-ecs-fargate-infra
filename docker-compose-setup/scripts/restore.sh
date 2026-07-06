#!/bin/bash

DATE=$(date '+%Y-%m-%d_%H-%M-%S')

DB_NAME="hoteldb"
DB_USERNAME="admin"
DB_PASSWORD="password"

BACKUP_FILE=$(ls -t /backup/*.sql | head -n 1)

export PGPASSWORD="$DB_PASSWORD"

psql \
  -h localhost \
  -p 5432 \
  -U "$DB_USERNAME" \
  -d "$DB_NAME" \
  -f "$BACKUP_FILE"

unset PGPASSWORD