#!/usr/bin/env bash
set -euo pipefail

DB_CONTAINER="hotel_bookings_db"
DB_USER="app"
DB_NAME="hotel_bookings"
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.dump"

mkdir -p "${BACKUP_DIR}"

if ! docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
    echo "Error: ${DB_CONTAINER} is not running. Start it with: docker compose up -d" >&2
    exit 1
fi

echo "Backing up ${DB_NAME} to ${BACKUP_FILE}..."
docker exec "${DB_CONTAINER}" pg_dump -U "${DB_USER}" -d "${DB_NAME}" -F c -f "/tmp/backup.dump"
docker cp "${DB_CONTAINER}:/tmp/backup.dump" "${BACKUP_FILE}"
docker exec "${DB_CONTAINER}" rm -f /tmp/backup.dump

echo "Backup complete: ${BACKUP_FILE}"
echo "$(basename "${BACKUP_FILE}")" > "${BACKUP_DIR}/latest.txt"
