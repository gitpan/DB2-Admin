#
# Test the rebind function
#
# $Id: 13rebind.t,v 48.1 2005/03/23 20:20:00 biersma Exp $
#

use strict;
use Test::More tests => 5;
BEGIN { use_ok('DB2::Admin'); }

#
# Get the database/schema/package names from the CONFIG file
#
our %myconfig;
require "util/parse_config";
my $db_name = $myconfig{DBNAME};
my $schema = $myconfig{REBIND_SCHEMA};
my $package = $myconfig{REBIND_PACKAGE};

DB2::Admin->SetOptions('PrintError' => 1);
ok(1, "SetOptions");

my $retval = DB2::Admin->Connect('Database' => $db_name);
ok($retval, "Connect - $db_name");

$retval = DB2::Admin->Rebind('Database' => $db_name,
			 'Schema'   => $schema,
			 'Package'  => $package,
			);
ok($retval, "Rebind - $schema.$package");

$retval = DB2::Admin->Disconnect('Database' => $db_name);
ok($retval, "Disconnect - $db_name");
