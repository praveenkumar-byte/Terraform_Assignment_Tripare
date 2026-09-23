-- Supports: SELECT org_id, status, COUNT(*), SUM(amount) FROM hotel_bookings
--           WHERE city = ? AND created_at >= ? GROUP BY org_id, status;
--
-- city is an equality filter, created_at is a range filter -> composite
-- btree with the equality column first lets Postgres do a single index
-- range scan instead of a sequential scan. org_id/status/amount are added
-- via INCLUDE so the scan can be index-only (no heap fetch), since they're
-- only ever read, never used to filter or sort by themselves.
CREATE INDEX IF NOT EXISTS idx_hotel_bookings_city_created_at
    ON hotel_bookings (city, created_at)
    INCLUDE (org_id, status, amount);
