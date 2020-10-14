-- fidelio-hotspot.sql
--
-- Sample MySQL database Schema to support Micros-Fidelio Opera Hotspot
-- Suitable also for SQLite and PostgreSQL
--
-- You can create this database with these commands:
-- mysql -uroot -prootpw
--   create database hotspot;
--   grant all privileges on hotspot.* to 'mikem'@'localhost' identified by 'fred';
--   flush privileges;
--   exit
-- mysql -Dhotspot -umikem -pfred <goodies/fidelio-hotspot.sql
--

drop table if exists sessions;
drop table if exists services;
drop table if exists posts;
drop table if exists postacks;

-- One record for each prepaid session per room/gn/mac
create table sessions
(
    roomNumber              varchar(60) not null,
    guestNumber             varchar(60) not null,
    macAddress              varchar(60) not null,
    serviceclass            varchar(60),
    confirmation_requested  int default 0 not null,
    expiry                  timestamp NULL, -- Turn off autoupdate on MySQL

    primary key (roomNumber, guestNumber, macAddress)
);

create index sessions_guest on sessions (roomNumber, macAddress);
create index sessions_service on sessions (serviceclass);

-- One record for each prepaid service that is defined.
-- See below for an example for a MikroTik based environment.
create table services
(
    serviceclass        varchar(60) not null,
    price               int default 0,
    duration            int default 0, -- Seconds, 0 means not time limited
    replyattributes     text,

    primary key (serviceclass)
);

-- One record for each post sent to Fidelio
create table posts
(
    roomNumber          varchar(60) not null,
    guestNumber         varchar(60) not null,
    macAddress          varchar(60) not null,
    postNumber          integer not null,
    posted              timestamp,  -- Turn off autoupdate on MySQL
    cost                integer -- Cents
);

create index posts_room on posts (roomNumber);

-- One record for each PA received back from Fidelio
-- postNumber is not unique
create table postacks
(
    roomNumber          varchar(60) not null,
    postNumber          integer not null,
    transactionNumber   integer,
    received            timestamp -- Turn off autoupdate on MySQL
);

create index postacks_room on posts (roomNumber);

-- Example for defining a service with MikroTik specific reply attributes
insert into services (serviceclass, price, replyattributes) values ('free', 0, 'Mikrotik-Rate-Limit=256k/256k');
insert into services (serviceclass, price, replyattributes) values ('premium', 500, 'Mikrotik-Rate-Limit=5M/5M');
