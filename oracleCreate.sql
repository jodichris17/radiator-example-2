/* oracleCreate.sql */

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

/* Oracle specific notes:
   o beware of comment hints: slash-star or double - (both start a
     comment) followed by a + sign starts a comment hint
   o Oracle may not like blank lines within statements or comments
   o should work like below if your $ORACLE_HOME/network/admin/tnsnames.ora
     is correct, use IP:port instead of XE if not, and you have created
     a database, user and password:
     sqlplus mikem/fred@XE @goodies/oracleCreate.sql
   o indexes are created for certain tables and columns
*/

/* $Id$ */

/* Wipe any old versions. Unfortunately can't use DROP TABLE IF EXISTS */
drop table SUBSCRIBERS;
drop table ACCOUNTING;
drop table RADONLINE;
drop table RADPOOL;
drop table RADLOG;
drop table RADCLIENTLIST;
drop table RADSQLRADIUS;
drop table RADSQLRADIUSINDIRECT;
drop table RADSTATSLOG;
drop table RADAUTHLOG;

/* You must have at least a USERNAME column. The default Radiator
   AuthBy SQL configuration requires USERNAME and PASSWORD columns.
   The exact names of the columns and this table can be changed with
   Radiator config file, but the values given here match the defaults.
*/
create table SUBSCRIBERS (
	USERNAME	  varchar2(253) NOT NULL PRIMARY KEY,
	PASSWORD	  varchar2(253),	/* Cleartext password */
	ENCRYPTEDPASSWORD varchar2(253),	/* Optional encrypted password */
	CHECKATTR	  varchar2(200),	/* Optional check radius attributes */
	REPLYATTR	  varchar2(200)	/* Optional reply radius attributes */
);
/* Index should be automatically created on USERNAME because of PRIMARY KEY */

/* A table for storing RADIUS Accounting-Request messages.
   The exact names of the columns and this table can be changed with
   Radiator config file, but the values given here match the defaults.
*/
create table ACCOUNTING (
	USERNAME	   varchar2(253) NOT NULL,	/* From User-Name */
	TIME_STAMP	   int,	     	 	/* Time this was received (since 1970) */
	ACCTSTATUSTYPE	   varchar2(50),
	ACCTDELAYTIME	   int,
	ACCTINPUTOCTETS	   int,
	ACCTOUTPUTOCTETS   int,
	ACCTSESSIONID	   varchar2(253),
	ACCTSESSIONTIME	   int,		/* Length of the session in secs */
	ACCTTERMINATECAUSE varchar2(50),
	NASIDENTIFIER	   varchar2(253),
	NASPORT		   int,
	FRAMEDIPADDRESS	   varchar2(22)
);
create index ACCOUNTING_I1 on ACCOUNTING (USERNAME);

/* A table for storing an entry for each user currently on line. Used
   by SessionDatabase SQL.
   The exact names of the columns and this table can be changed with
   Radiator config file, but the values given here match the defaults.
*/
create table RADONLINE (
	USERNAME	varchar2(253) NOT NULL,
	NASIDENTIFIER	varchar2(253) NOT NULL,
	NASPORT		int NOT NULL,
	ACCTSESSIONID	varchar2(253) NOT NULL,
	TIME_STAMP	int,
	FRAMEDIPADDRESS	varchar2(22),
	NASPORTTYPE	varchar2(40),
	SERVICETYPE	varchar2(40)
);
/* You may need to switch to non-unique index on NASIDENTIFIER, NASPORT if ports are not unique */
create unique index RADONLINE_I1 on RADONLINE (NASIDENTIFIER, NASPORT);
create index RADONLINE_I2 on RADONLINE (USERNAME);

/* An entry for each allocatable address for AllocateAddress SQL.
   STATE: 0=free, 1=allocated
   TIME_STAMP: last time it changed state
   YIADDR: the IP address to be allocated
   NAS_ID: the NAS the allocation was done for
*/
create table RADPOOL (
	STATE		int NOT NULL,
	TIME_STAMP	int,
	EXPIRY		int,
	USERNAME	varchar2(253),
	POOL		varchar2(50) NOT NULL,
	YIADDR		varchar2(50) NOT NULL,
	SUBNETMASK	varchar2(50) NOT NULL,
	DNSSERVER	varchar2(50),
	NAS_ID          varchar2(253)
);
create unique index RADPOOL_I1 on RADPOOL (YIADDR);
create index RADPOOL_I2 on RADPOOL (POOL);

/* A table for storing log messages with LogSQL
   These are the minimum requirements */
create table RADLOG (
	TIME_STAMP	int,
	PRIORITY	int,
	MESSAGE		varchar2(200)
);

/* A table for storing Client definitions. Used by ClientListSQL. */
create table RADCLIENTLIST (
	NASIDENTIFIER			varchar2(50) NOT NULL,
	SECRET				varchar2(50) NOT NULL,
	IGNOREACCTSIGNATURE		int,
	DUPINTERVAL			int,
	DEFAULTREALM			varchar2(80),
	NASTYPE				varchar2(20),
	SNMPCOMMUNITY			varchar2(20),
	LIVINGSTONOFFS			int,
	LIVINGSTONHOLE			int,
	FRAMEDGROUPBASEADDRESS		varchar2(50),
	FRAMEDGROUPMAXPORTSPERCLASSC	int,
	REWRITEUSERNAME			varchar2(50),
	NOIGNOREDUPLICATES		varchar2(50),
	PREHANDLERHOOK			varchar2(50)
);
create unique index RADCLIENTLIST_I1 on RADCLIENTLIST (NASIDENTIFIER);

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
       TARGETNAME			varchar2(80),
       HOST1				varchar2(50),
       HOST2				varchar2(50),
       SECRET				varchar2(50),
       AUTHPORT				varchar2(20),
       ACCTPORT				varchar2(20),
       RETRIES				int,
       RETRYTIMEOUT			int,
       USEOLDASCENDPASSWORDS		int,
       SERVERHASBROKENPORTNUMBERS	int,
       SERVERHASBROKENADDRESSES		int,
       IGNOREREPLYSIGNATURE		int,
       FAILUREPOLICY			int
);
create unique index RADSQLRADIUS_I1 on RADSQLRADIUS (TARGETNAME);

/* If you have many Called-Station-Ids or realms mapping to a single
   target radius server, you can have an indirect table like this one
   and set your HostSelect to be a join between tables
*/
create table RADSQLRADIUSINDIRECT (
       SOURCENAME			varchar2(80),
       TARGETNAME			varchar2(80)
);
create unique index RADSQLRADIUSINDIRECT_I1 on RADSQLRADIUSINDIRECT (SOURCENAME);

/* This table works with default StatsLog SQL */
create table RADSTATSLOG (
       TIME_STAMP			int,
       TYPE				varchar2(20),
       IDENTIFIER			varchar2(30),
       ACCESSACCEPTS			int,
       ACCESSCHALLENGES			int,
       ACCESSREJECTS			int,
       ACCESSREQUESTS			int,
       ACCOUNTINGREQUESTS		int,
       ACCOUNTINGRESPONSES		int,
       BADAUTHACCESSREQUESTS		int,
       BADAUTHACCOUNTINGREQUESTS	int,
       BADAUTHREQUESTS			int,
       DROPPEDACCESSREQUESTS		int,
       DROPPEDACCOUNTINGREQUESTS	int,
       DROPPEDREQUESTS			int,
       DUPACCESSREQUESTS		int,
       DUPACCOUNTINGREQUESTS		int,
       DUPLICATEREQUESTS		int,
       MALFORMEDACCESSREQUESTS		int,
       MALFORMEDACCOUNTINGREQUESTS	int,
       PROXIEDNOREPLY			int,
       PROXIEDREQUESTS			int,
       REQUESTS				int,
       RESPONSETIME			decimal(12,6)
);

/* AuthLog SQL table for recording successful and unsuccessful login attempts */
create table RADAUTHLOG (
	TIME_STAMP	int,
	USERNAME	varchar2(253),
	TYPE		int,
	REASON		varchar2(253)
);
create index RADAUTHLOG_I1 on RADAUTHLOG (USERNAME);
