#!/usr/bin/env bash
set -euo pipefail

DB_CONTAINER="hotel_bookings_db"
DB_USER="app"
SOURCE_DB="hotel_bookings"
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backups"

# Accept a specific backup file as $1, otherwise use the most recent one
if [[ $# -ge 1 ]]; then
    BACKUP_FILE="$1"
else
    if [[ ! -f "${BACKUP_DIR}/latest.txt" ]]; then
        echo "Error: no backup file given and no ${BACKUP_DIR}/latest.txt found. Run scripts/backup.sh first." >&2
        exit 1
    fi
    BACKUP_FILE="${BACKUP_DIR}/$(cat "${BACKUP_DIR}/latest.txt")"
fi

if [[ ! -f "${BACKUP_FILE}" ]]; then
    echo "Error: backup file not found: ${BACKUP_FILE}" >&2
    exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
    echo "Error: ${DB_CONTAINER} is not running. Start it with: docker compose up -d" >&2
    exit 1
fi

RESTORE_DB="hotel_bookings_restore_$(date +%Y%m%d_%H%M%S)"

echo "Restoring $(basename "${BACKUP_FILE}") into a fresh database: ${RESTORE_DB}"

docker exec "${DB_CONTAINER}" psql -U "${DB_USER}" -d postgres -c "CREATE DATABASE ${RESTORE_DB};"
docker cp "${BACKUP_FILE}" "${DB_CONTAINER}:/tmp/restore.dump"
docker exec "${DB_CONTAINER}" pg_restore -U "${DB_USER}" -d "${RESTORE_DB}" /tmp/restore.dump
docker exec "${DB_CONTAINER}" rm -f /tmp/restore.dump

echo ""
echo "Restore complete into database: ${RESTORE_DB}"
echo ""
echo "Row count comparison (source vs restored):"
SRC_COUNT=$(docker exec "${DB_CONTAINER}" psql -U "${DB_USER}" -d "${SOURCE_DB}" -tAc "SELECT COUNT(*) FROM hotel_bookings;")
RESTORED_COUNT=$(docker exec "${DB_CONTAINER}" psql -U "${DB_USER}" -d "${RESTORE_DB}" -tAc "SELECT COUNT(*) FROM hotel_bookings;")
echo "  ${SOURCE_DB}:   ${SRC_COUNT} rows in hotel_bookings"
echo "  ${RESTORE_DB}: ${RESTORED_COUNT} rows in hotel_bookings"

if [[ "${SRC_COUNT}" == "${RESTORED_COUNT}" ]]; then
    echo "Row counts match — restore verified."
else
    echo "Row counts differ — check the backup file and restore log above." >&2
    exit 1
fi
