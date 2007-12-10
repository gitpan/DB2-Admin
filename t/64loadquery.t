#
# Test the load query functions (V8.2 only)
#
# $Id: 64loadquery.t,v 145.1 2007/10/17 14:41:09 biersma Exp $
#

#
# Get the database/schema/table names from the CONFIG file
#
our %myconfig;
require "util/parse_config";
my $db_name = $myconfig{DBNAME};
my $schema_name = uc(getpwuid ($<));
my $table_name = $myconfig{TARGET_TABLE};
my $export_dir = $myconfig{EXPORT_DIRECTORY};

use strict;
use Data::Dumper;
use Test::More tests => 5;
BEGIN { use_ok('DB2::Admin'); }

SKIP: {
    my $version = substr($ENV{DB2_VERSION}, 1); # Vx.y -> x.y
    skip("db2Load not available in DB2 version < 8.2", 4) if ($version < 8.2);

    DB2::Admin->SetOptions('RaiseError' => 1);
    ok(1, "SetOptions");

    my $rc = DB2::Admin->Connect('Database' => $db_name);
    ok($rc, "Connect - $db_name");

    my $logfile = "$export_dir/loadquery-test.log";
    unlink($logfile);
    my $results = DB2::Admin->LoadQuery('Database' => $db_name,
				    'Schema'   => $schema_name,
				    'Table'    => $table_name,
				    'LogFile'  => $logfile,
				    'Messages' => 'All',
				   );
    ok(defined $results, "LoadQuery succeeded");
    #print STDERR Dumper($results);

    $rc = DB2::Admin->Disconnect('Database' => $db_name);
    ok($rc, "Disconnect - $db_name");
}
