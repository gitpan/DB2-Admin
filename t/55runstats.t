#
# Test the 'runstats' function
#
# $Id: 55runstats.t,v 145.1 2007/10/17 14:43:06 biersma Exp $
#

#
# Get the database name, table nme and schema name from the CONFIG file
#
our %myconfig;
require "util/parse_config";
my $db_name = $myconfig{DBNAME};
my $schema_name = uc(getpwuid ($<));
my $table_name = $myconfig{SOURCE_TABLE};

use strict;
use Test::More tests => 6;
BEGIN { use_ok('DB2::Admin'); }

$| = 1;

my $rc = DB2::Admin->SetOptions('RaiseError' => 1);
ok ($rc, "SetOptions");

SKIP: {
    my $version = substr($ENV{DB2_VERSION}, 1); # Vx.y -> x.y
    skip("db2Runstats not available in DB2 version < 8", 4) if ($version < 8);

    my $rc = DB2::Admin->Connect('Database' => $db_name);
    ok($rc, "Connect - $db_name");

    #
    # Most basic
    #
    $rc = DB2::Admin::->Runstats('Database' => $db_name,
			     'Schema'   => $schema_name,
			     'Table'    => $table_name,
			    );
    ok($rc, "Runstats - basic");

    #
    # Options
    #
    $rc = DB2::Admin::->Runstats('Database' => $db_name,
			     'Schema'   => $schema_name,
			     'Table'    => $table_name,
			     #'Columns'  => { 'SALES_person' => 1,
			#		     'SALES_DATE'   => 1,
			#		     'BoGus'        => 0,
			#		     'REGION'       => { 'LikeStatistics' => 1 },
			#		   },
			     'Options'  => { 'AllColumns'      => 1,
					     'AllIndexes'      => 1,
					     'DetailedIndexes' => 1,
					     'ReadAccess'      => 1,
					     'SetProfile'      => 1,
					   },
			    );
    ok($rc, "Runstats - with options");

    $rc = DB2::Admin->Disconnect('Database' => $db_name);
    ok($rc, "Disconnect - $db_name");
}
