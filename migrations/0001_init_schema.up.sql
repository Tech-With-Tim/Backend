-- Prepare everything we need for internal `Snowflake` objects.
CREATE SEQUENCE IF NOT EXISTS global_snowflake_id_seq;


CREATE FUNCTION create_snowflake(dt TIMESTAMP WITHOUT TIME ZONE DEFAULT now())
    RETURNS BIGINT
    LANGUAGE "plpgsql"
AS $BODY$
DECLARE
    our_epoch  bigint := 1539539800;    -- TWT Server Time of Creation
    seq_id     bigint;                  -- Incremented for every generated ID
    now_millis bigint;                  -- Current ms from unix time

    shard_id   smallint := 1;           -- Hard coded as we don't have several postgres shards.
    result     bigint;
BEGIN
    SELECT nextval('global_snowflake_id_seq') % 1024 INTO seq_id;
    SELECT floor(extract(EPOCH FROM dt) * 1000) INTO now_millis;
    result := (now_millis - our_epoch) << 22;
    result := result | (shard_id << 9);
    result := result | (seq_id);

    return result;
END;
$BODY$;


CREATE FUNCTION snowflake_to_timestamp(flake BIGINT)
    RETURNS TIMESTAMP WITHOUT TIME ZONE
    LANGUAGE "plpgsql"
AS $BODY$
BEGIN
    RETURN to_timestamp(((flake >> 22) + 1539539800) / 1000);
END;
$BODY$;
