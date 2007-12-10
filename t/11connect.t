#
# Test the connect / disconnect functions
#
# $Id: 11connect.t,v 140.1 2007/06/13 13:02:12 biersma Exp $
#

use strict;
use Test::More tests => 9;
BEGIN { use_ok('DB2::Admin'); }

#
# Get the database name from the CONFIG file
#
our %myconfig;
require "util/parse_config";
my $db_name = $myconfig{DBNAME};


DB2::Admin->SetOptions('PrintError' => 1);
ok(1, "SetOptions");

my $retval = DB2::Admin->Connect('Database' => $db_name);
ok($retval, "Connect - $db_name (no attributes set)");

$retval = DB2::Admin->Disconnect('Database' => $db_name);
ok($retval, "Disconnect - $db_name");

my %attr = DB2::Admin::->SetConnectAttributes('ProgramName' => 'test_set_attr');
ok(keys %attr, "SetConnectAttributes");

my $retval = DB2::Admin->Connect('Database' => $db_name);
ok($retval, "Connect - $db_name (after setting attributes)");

$retval = DB2::Admin->Disconnect('Database' => $db_name);
ok($retval, "Disconnect - $db_name");

my $retval = DB2::Admin->Connect('Database' => $db_name,
			     'ConnectAttr' => { 'ProgramName' => 'test_pass_attr', });
ok($retval, "Connect - $db_name (passing attributes)");

$retval = DB2::Admin->Disconnect('Database' => $db_name);
ok($retval, "Disconnect - $db_name");
