/* mysqlCreate.sql */

/* Initialise a simple SQL database for use by AuthBy SQL, AuthLog
   SQL, SessionDatabase SQL, StatsLog SQL and other SQL modules. In a
   real system, you may not need all tables and you will probably want
   much more than the minimum set of columns for some tables.
*/

/* For additional tables and test data, see:
   o sql-test-data.sql for a SUBSCRIBERS entry and other test data
   o sql-extra-tables.sql for tables required by additional configurations
   o *Create.sql for vendor specific files
*/

/* This file works with MySQL and MariaDB.
   You can create this database with these commands:
     mysql -uroot -prootpw
     create database radius;
     grant all privileges on radius.* to 'mikem'@'localhost' identified by 'fred';
     flush privileges;
     exit

   Then create and intialise the tables with this command:
     mysql -Dradius -umikem -pfred <goodies/mysqlCreate.sql
*/

/* $Id$ */

use radius;

/* Wipe any old versions */
drop table if exists SUBSCRIBERS;
drop table if exists ACCOUNTING;
drop table if exists RADONLINE;
drop table if exists RADLOG;
drop table if exists RADPOOL;
drop table if exists RADCLIENTLIST;
drop table if exists RADSQLRADIUS;
drop table if exists RADSQLRADIUSINDIRECT;
drop table if exists RADSTATSLOG;
drop table if exists RADAUTHLOG;

/* You must have at least a USERNAME column. The default Radiator
   AuthBy SQL configuration requires USERNAME and PASSWORD columns.
   The exact names of the columns and this table can be changed with
   Radiator config file, but the values given here match the defaults.
*/
create table SUBSCRIBERS (
	USERNAME	  varchar(253) NOT NULL PRIMARY KEY,
	PASSWORD	  varchar(253),	/* Cleartext password */
	ENCRYPTEDPASSWORD varchar(253),	/* Optional encrypted password */
	CHECKATTR	  varchar(200),	/* Optional check radius attributes */
	REPLYATTR	  varchar(200)	/* Optional reply radius attributes */
);
/* Index should be automatically created on USERNAME because of PRIMARY KEY */

/* A table for storing RADIUS Accounting-Request messages.
   The exact names of the columns and this table can be changed with
   Radiator config file, but the values given here match the defaults.
*/
create table ACCOUNTING (
	USERNAME	   varchar(253) NOT NULL,       /* From User-Name */
	TIME_STAMP	   bigint,                      /* Time this was received (since 1970) */
	ACCTSTATUSTYPE	   varchar(50),
	ACCTDELAYTIME	   bigint,
	ACCTINPUTOCTETS	   bigint,
	ACCTOUTPUTOCTETS   bigint,
	ACCTSESSIONID	   varchar(253),
	ACCTSESSIONTIME	   bigint,              /* Length of the session in secs */
	ACCTTERMINATECAUSE varchar(50),
	NASIDENTIFIER	   varchar(253),
	NASPORT		   bigint,
	FRAMEDIPADDRESS	   varchar(22),
	INDEX ACCOUNTING_I1 (USERNAME)
);

/* A table for storing an entry for each user currently on line. Used
   by SessionDatabase SQL.
   The exact names of the columns and this table can be changed with
   Radiator config file, but the values given here match the defaults.
*/
create table RADONLINE (
	USERNAME	varchar(253) NOT NULL,
	NASIDENTIFIER	varchar(253) NOT NULL,
	NASPORT		bigint NOT NULL,
	ACCTSESSIONID	varchar(253) NOT NULL,
	TIME_STAMP	bigint,
	FRAMEDIPADDRESS	varchar(22),
	NASPORTTYPE	varchar(40),
	SERVICETYPE	varchar(40),

	UNIQUE INDEX RADONLINE_I1 (NASIDENTIFIER, NASPORT),
	INDEX RADONLINE_I2 (USERNAME)
);
/* You may need to switch to non-unique index on NASIDENTIFIER, NASPORT if ports are not unique */

/* An entry for each allocatable address for AllocateAddress SQL.
   STATE: 0=free, 1=allocated
   TIME_STAMP: last time it changed state
   YIADDR: the IP address to be allocated
   NAS_ID: the NAS the allocation was done for
*/
create table RADPOOL (
	STATE		int NOT NULL,
	TIME_STAMP	bigint,
	EXPIRY		bigint,
	USERNAME	varchar(253),
	POOL		varchar(50) NOT NULL,
	YIADDR		varchar(50) NOT NULL,
	SUBNETMASK	varchar(50) NOT NULL,
	DNSSERVER	varchar(50),
	NAS_ID		varchar(253),

	UNIQUE INDEX RADPOOL_I1 (YIADDR),
	INDEX RADPOOL_I2 (POOL)
);

/* A table for storing log messages with LogSQL
   These are the minimum requirements */
create table RADLOG (
	TIME_STAMP	bigint,
	PRIORITY	int,
	MESSAGE		varchar(200)
);

/* A table for storing Client definitions. Used by ClientListSQL. */
create table RADCLIENTLIST (
	NASIDENTIFIER			varchar(50) NOT NULL,
	SECRET				varchar(50) NOT NULL,
	IGNOREACCTSIGNATURE		int,
	DUPINTERVAL			int,
	DEFAULTREALM			varchar(80),
	NASTYPE				varchar(20),
	SNMPCOMMUNITY			varchar(20),
	LIVINGSTONOFFS			int,
	LIVINGSTONHOLE			int,
	FRAMEDGROUPBASEADDRESS		varchar(50),
	FRAMEDGROUPMAXPORTSPERCLASSC	int,
	REWRITEUSERNAME			varchar(50),
	NOIGNOREDUPLICATES		varchar(50),
	PREHANDLERHOOK			varchar(50),
	UNIQUE INDEX			RADCLIENTLIST_I1 (NASIDENTIFIER)
);

/* An example table for AuthBy SQLRADIUS
   Contains an entry for each realm to be proxied, along with target
   server information. For a simple system, set the TARGETNAME to be
   the realm to be proxied, and use the default HostSelect in AuthBy
   SQLRADIUS. For more complicated systems, see RADSQLINDIRECT
   below. FAILUREPOLICY determines what to do if the request can't be
   forwarded. It can be one of the return codes documented in the
   reference manual. NULL will default to IGNORE
*/
create table RADSQLRADIUS (
       TARGETNAME			varchar(80),
       HOST1				varchar(50),
       HOST2				varchar(50),
       SECRET				varchar(50),
       AUTHPORT				varchar(20),
       ACCTPORT				varchar(20),
       RETRIES				int,
       RETRYTIMEOUT			int,
       USEOLDASCENDPASSWORDS		int,
       SERVERHASBROKENPORTNUMBERS	int,
       SERVERHASBROKENADDRESSES		int,
       IGNOREREPLYSIGNATURE		int,
       FAILUREPOLICY			int,
       FAILUREBACKOFFTIME		int,
       MAXFAILEDREQUESTS		int,
       MAXFAILEDGRACETIME		int,
       UNIQUE INDEX			RADSQLRADIUS_I1 (TARGETNAME)
);

/* If you have many Called-Station-Ids or realms mapping to a single
   target radius server, you can have an indirect table like this one
   and set your HostSelect to be a join between tables
*/
create table RADSQLRADIUSINDIRECT (
       SOURCENAME			varchar(80),
       TARGETNAME			varchar(80),
       UNIQUE 				RADSQLRADIUSINDIRECT_I1 (SOURCENAME)
);

/* This table works with default StatsLog SQL */
create table RADSTATSLOG (
       TIME_STAMP			bigint,
       TYPE				varchar(20),
       IDENTIFIER			varchar(30),
       ACCESSACCEPTS			bigint,
       ACCESSCHALLENGES			bigint,
       ACCESSREJECTS			bigint,
       ACCESSREQUESTS			bigint,
       ACCOUNTINGREQUESTS		bigint,
       ACCOUNTINGRESPONSES		bigint,
       BADAUTHACCESSREQUESTS		bigint,
       BADAUTHACCOUNTINGREQUESTS	bigint,
       BADAUTHREQUESTS			bigint,
       DROPPEDACCESSREQUESTS		bigint,
       DROPPEDACCOUNTINGREQUESTS	bigint,
       DROPPEDREQUESTS			bigint,
       DUPACCESSREQUESTS		bigint,
       DUPACCOUNTINGREQUESTS		bigint,
       DUPLICATEREQUESTS		bigint,
       MALFORMEDACCESSREQUESTS		bigint,
       MALFORMEDACCOUNTINGREQUESTS	bigint,
       PROXIEDNOREPLY			bigint,
       PROXIEDREQUESTS			bigint,
       REQUESTS				bigint,
       RESPONSETIME			decimal(12,6)
);

/* AuthLog SQL table for recording successful and unsuccessful login attempts */
create table RADAUTHLOG (
	TIME_STAMP	bigint,
	USERNAME	varchar(253),
	TYPE		int,
	REASON		varchar(253),
	INDEX RADAUTHLOG_I1 (USERNAME)
);
