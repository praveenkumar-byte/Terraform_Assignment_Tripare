-- Seed data: 100+ hotel_bookings across multiple cities/orgs/statuses,
-- plus booking_events for a subset of bookings.

DO $$
DECLARE
    cities      TEXT[] := ARRAY['delhi', 'mumbai', 'bengaluru', 'chennai', 'hyderabad'];
    orgs        UUID[] := ARRAY[
        'a1111111-1111-1111-1111-111111111111'::uuid,
        'a2222222-2222-2222-2222-222222222222'::uuid,
        'a3333333-3333-3333-3333-333333333333'::uuid,
        'a4444444-4444-4444-4444-444444444444'::uuid
    ];
    statuses    TEXT[] := ARRAY['confirmed', 'cancelled', 'pending', 'completed'];
    event_types TEXT[] := ARRAY['created', 'payment_received', 'status_changed', 'cancelled'];

    v_id         UUID;
    v_city       TEXT;
    v_org        UUID;
    v_status     TEXT;
    v_checkin    DATE;
    v_created_at TIMESTAMP;
    v_event_count INT;
BEGIN
    FOR i IN 1..150 LOOP
        v_id         := gen_random_uuid();
        v_city       := cities[1 + floor(random() * array_length(cities, 1))::int];
        v_org        := orgs[1 + floor(random() * array_length(orgs, 1))::int];
        v_status     := statuses[1 + floor(random() * array_length(statuses, 1))::int];
        v_checkin    := (CURRENT_DATE - (floor(random() * 60))::int);
        -- spread created_at across the last 90 days so the "last 30 days"
        -- filter in the target query actually excludes some rows
        v_created_at := now() - (floor(random() * 90) || ' days')::interval;

        INSERT INTO hotel_bookings
            (id, org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at)
        VALUES (
            v_id,
            v_org,
            'HOTEL-' || (1 + floor(random() * 20))::int,
            v_city,
            v_checkin,
            v_checkin + (1 + floor(random() * 5))::int,
            round((cast(random() as numeric) * 20000 + 1500), 2),
            v_status,
            v_created_at
        );

        -- roughly 60% of bookings get 1-3 events
        IF random() < 0.6 THEN
            v_event_count := 1 + floor(random() * 3)::int;
            FOR j IN 1..v_event_count LOOP
                INSERT INTO booking_events (booking_id, event_type, payload, created_at)
                VALUES (
                    v_id,
                    event_types[1 + floor(random() * array_length(event_types, 1))::int],
                    jsonb_build_object('note', 'seed event ' || j, 'booking_status_at_event', v_status),
                    v_created_at + (j || ' hours')::interval
                );
            END LOOP;
        END IF;
    END LOOP;
END $$;
