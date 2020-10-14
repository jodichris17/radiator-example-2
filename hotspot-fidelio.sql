-- hotspot-fidelio.sql
--
-- SQL database schema for AuthBy HOTSPOTFIDELIO using
-- ServiceDatabase SQL and SessionDatabase SQL
--
-- Requires also schema from goodies/hotspot.sql
--
-- Author: Tuure Vartiainen (vartiait@radiatorsoftware.com)
-- Copyright (C) 2018 Radiator Software Oy
-- All Rights Reserved
-- $Id$

-- Tables

-- Drop existing tables

DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS postacks;

-- Table for Fidelio PMS posts

-- One record for each post sent to Fidelio
CREATE TABLE posts
(
    roomNumber  VARCHAR(60) NOT NULL,
    guestNumber VARCHAR(60) NOT NULL,
    macAddress  VARCHAR(60) NOT NULL,
    postNumber  INT NOT NULL,
    posted      TIMESTAMP,  -- Turn off autoupdate on MySQL
    cost        INT -- Cents
);

CREATE INDEX posts_room ON posts (roomNumber);

-- Table for Fidelio PMS post acknowledges

-- One record for each PA received back from Fidelio
-- postNumber is not unique
CREATE TABLE postacks
(
    roomNumber        VARCHAR(60) NOT NULL,
    postNumber        INT NOT NULL,
    transactionNumber INT,
    received          TIMESTAMP -- Turn off autoupdate on MySQL
);

CREATE INDEX postacks_room ON postacks (roomNumber);
