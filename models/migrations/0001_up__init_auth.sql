-- Prepare everything we need for internal `Snowflake` objects.
CREATE SEQUENCE global_snowflake_id_seq;


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


-- Create initial tables

CREATE TABLE users (
    id BIGINT,
    username VARCHAR(32) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE challenge_languages (
    id BIGINT DEFAULT (create_snowflake()),
    name VARCHAR(64) UNIQUE NOT NULL,
    download_url TEXT,
    enabled BOOLEAN DEFAULT TRUE NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE challenges (
    id BIGINT DEFAULT (create_snowflake()),
    number INT,  -- Number is assigned when challenge is released.
    author_id BIGINT REFERENCES users(id) NOT NULL,
    title varchar(32) UNIQUE NOT NULL,
    slug varchar(32) UNIQUE NOT NULL,
    difficulty INT,
    labels VARCHAR(64) ARRAY NOT NULL,
    description TEXT NOT NULL,
    task TEXT NOT NULL,
    example_input TEXT NOT NULL,
    example_output TEXT NOT NULL,
    notes TEXT NOT NULL,
    released_at BIGINT,
    deleted BOOLEAN DEFAULT FALSE NOT NULL,
    PRIMARY KEY (id)
);

CREATE INDEX challenges_slug ON challenges USING hash (slug);


CREATE TABLE challenge_submissions (
    id BIGINT DEFAULT (create_snowflake()),
    solution VARCHAR(4096) NOT NULL,
    author_id BIGINT REFERENCES users(id) NOT NULL,
    challenge_id BIGINT REFERENCES challenges(id) NOT NULL,
    language_id BIGINT REFERENCES challenge_languages(id) NOT NULL,
    PRIMARY KEY (id)
);
