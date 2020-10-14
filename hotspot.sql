-- hotspot.sql
--
-- SQL database schema for AuthBy HOTSPOT using
-- ServiceDatabase SQL and SessionDatabase SQL
--
-- Author: Tuure Vartiainen (vartiait@radiatorsoftware.com)
-- Copyright (C) 2018 Radiator Software Oy
-- All Rights Reserved
-- $Id$

-- Tables

-- Drop existing tables

DROP TABLE IF EXISTS SESSIONS;
DROP TABLE IF EXISTS SUBSCRIPTIONS;
DROP TABLE IF EXISTS SERVICES;

-- Table for services

CREATE TABLE SERVICES
(
    tenant_id             VARCHAR(253) DEFAULT 'default' NOT NULL,
    id                    VARCHAR(253) NOT NULL,
    name                  VARCHAR(253) NOT NULL,

    price                 INT DEFAULT 0 NOT NULL,
    confirm               TINYINT DEFAULT 1 NOT NULL,
    check_attrs           VARCHAR(253),
    pool_v4               VARCHAR(253),
    pool_v6               VARCHAR(253),
    reply_attrs           VARCHAR(253),
    expiry                VARCHAR(10),
    quota_time_pre        VARCHAR(10),
    quota_time_post       VARCHAR(10),
    quota_octets_pre      VARCHAR(20),
    quota_octets_post     VARCHAR(20),
    allow_to_exceed       TINYINT DEFAULT 0 NOT NULL,
    disallow_resubscribe  TINYINT DEFAULT 0 NOT NULL,
    rate_ul_throt         VARCHAR(253),
    rate_ul               VARCHAR(253),
    rate_ul_max           VARCHAR(253),
    rate_dl_throt         VARCHAR(253),
    rate_dl               VARCHAR(253),
    rate_dl_max           VARCHAR(253),

    CONSTRAINT SERVICES_PK PRIMARY KEY (tenant_id, id),
    CONSTRAINT SERVICES_UI_1 UNIQUE (tenant_id, name)
);

-- Table for subscriptions

CREATE TABLE SUBSCRIPTIONS
(
    tenant_id              VARCHAR(253) DEFAULT 'default' NOT NULL,
    id                     VARCHAR(253) NOT NULL,
    name                   VARCHAR(253) NOT NULL,

    parent_id              VARCHAR(253) NOT NULL,
    parent_name            VARCHAR(253) NOT NULL,

    check_attrs            VARCHAR(253),
    pool_v4                VARCHAR(253),
    pool_v6                VARCHAR(253),
    reply_attrs            VARCHAR(253),
    expiry                 VARCHAR(10),
    allow_to_exceed        TINYINT DEFAULT 0 NOT NULL,
    disallow_resubscribe   TINYINT DEFAULT 0 NOT NULL,

    quota_time_pre_left    INT,
    quota_time_post_left   INT,
    quota_octets_pre_left  BIGINT,
    quota_octets_post_left BIGINT,
    refill_number          INT,
    refilled_at            TIMESTAMP NULL,
    user_name              VARCHAR(253),
    user_ref               VARCHAR(1000),
    charged_price          INT,
    charge_ref             VARCHAR(1000),
    charged_at             TIMESTAMP NULL,
    created_at             TIMESTAMP,
    confirmed_at           TIMESTAMP NULL,
    deleted_at             TIMESTAMP NULL,
    updated_at             TIMESTAMP,
    saved_at               TIMESTAMP,

    CONSTRAINT SUBSCRIPTIONS_PK PRIMARY KEY (tenant_id, id),
    CONSTRAINT SUBSCRIPTIONS_UI_1 UNIQUE (tenant_id, name)
);

-- Table for sessions

CREATE TABLE SESSIONS
(
    tenant_id              VARCHAR(253) DEFAULT 'default' NOT NULL,
    id                     VARCHAR(253) NOT NULL,
    name                   VARCHAR(253) NOT NULL,

    parent_id              VARCHAR(253) NOT NULL,
    parent_name            VARCHAR(253) NOT NULL,

    quota_time_pre_left    INT,
    quota_time_post_left   INT,
    quota_octets_pre_left  BIGINT,
    quota_octets_post_left BIGINT,
    refill_number          INT,
    refilled_at            TIMESTAMP NULL,
    user_name              VARCHAR(253),
    created_at             TIMESTAMP,
    deleted_at             TIMESTAMP NULL,
    updated_at             TIMESTAMP,
    saved_at               TIMESTAMP,

    recv_from_addr         VARCHAR(45),
    nas_id                 VARCHAR(253),
    nas_ipv4               VARCHAR(31),
    nas_ipv6               VARCHAR(45),
    nas_port               INT,
    called_station         VARCHAR(253),
    calling_station        VARCHAR(253),
    ssid                   VARCHAR(253),
    class                  VARCHAR(253),
    ipv4                   VARCHAR(31),
    ipv6                   VARCHAR(45),
    duration               INT,
    data_used              BIGINT,
    status                 VARCHAR(253),
    end_reason             VARCHAR(253),
    ended_at               TIMESTAMP NULL,
    state                  TINYINT,

    -- Add extra_attr columns below

    CONSTRAINT SESSIONS_PK PRIMARY KEY (tenant_id, id),
    CONSTRAINT SESSIONS_UI_1 UNIQUE (tenant_id, name)
);

-- Example services

-- Free service: 0 cents, 1 hour
INSERT INTO SERVICES (id, name, price, quota_time_pre) VALUES ('free', 'free', 0, '1h');
-- Premium service: 900 cents, 24 hours
INSERT INTO SERVICES (id, name, price, quota_time_pre) VALUES ('premium', 'premium', 900, '24h');
-- Premium2 service: 1200 cents, 24 hours, 500 MB of data
INSERT INTO SERVICES (id, name, price, quota_time_pre, quota_octets_pre) VALUES ('premium2', 'premium2', 1200, '24h', '500M');
-- Gold service: 1900 cents, 1 GB of data
INSERT INTO SERVICES (id, name, price, quota_octets_pre) VALUES ('gold', 'gold', 1900, '1G');
