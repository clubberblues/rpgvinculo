-- Disposable model of the observed campaign/effect lock inversion.
-- This is a concurrency-pattern regression, not an execution of production RPCs.
DROP SCHEMA IF EXISTS lock_fixture CASCADE;
CREATE SCHEMA lock_fixture;
CREATE TABLE lock_fixture.campaigns (
  id integer PRIMARY KEY,
  round_number integer NOT NULL
);
CREATE TABLE lock_fixture.effects (
  id integer PRIMARY KEY,
  campaign_id integer NOT NULL REFERENCES lock_fixture.campaigns(id),
  active boolean NOT NULL
);
INSERT INTO lock_fixture.campaigns VALUES (1, 1);
INSERT INTO lock_fixture.effects VALUES (1, 1, true);

CREATE TABLE lock_fixture.weapon_instances (
  id integer PRIMARY KEY,
  campaign_id integer NOT NULL REFERENCES lock_fixture.campaigns(id)
);
CREATE TABLE lock_fixture.characters (
  id integer PRIMARY KEY,
  campaign_id integer NOT NULL REFERENCES lock_fixture.campaigns(id)
);
INSERT INTO lock_fixture.weapon_instances VALUES (1, 1);
INSERT INTO lock_fixture.characters VALUES (1, 1);
