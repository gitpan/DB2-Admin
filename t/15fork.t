#
# Test the connect / disconnect functionality across a fork()
#
# $Id: 15fork.t,v 145.1 2007/10/17 14:44:12 biersma Exp $
#

use strict;
use Test::More tests => 5;
BEGIN { use_ok('DB2::Admin'); }

#
# Get the database/schema/table names from the CONFIG file
#
our %myconfig;
require "util/parse_config";
my $db_name = $myconfig{DBNAME};
my $schema_name = uc(getpwuid ($<));
my $table_name = $myconfig{SOURCE_TABLE};
my $export_dir = $myconfig{EXPORT_DIRECTORY};

mkdir($export_dir, 0755);

my $rc = DB2::Admin->Connect('Database' => $db_name);
ok($rc, "Connect $db_name (parent)");

do_something('parent');

my $pid = fork();
if ($pid > 0) {			# This is the parent
    wait();
} else {			# This is the child
    $rc = DB2::Admin->Connect('Database' => $db_name);
    ok($rc, "Connect $db_name (child)");

    do_something('child');

    $rc = DB2::Admin->Disconnect('Database' => $db_name);
    ok($rc, "Disconnect $db_name (child)");

    exit(0);
}

#
# Back to parent
#
do_something('parent');
$rc = DB2::Admin->Disconnect('Database' => $db_name);
ok($rc, "Disconnect $db_name (parent)");

# ------------------------------------------------------------------------

sub do_something {
    my ($label) = @_;

    $rc = DB2::Admin->Export('Database'   => $db_name,
			 'Schema'     => $schema_name,
			 'Table'      => $table_name,
			 'OutputFile' => "$export_dir/export-test.ixf",
			 'LogFile'    => "$export_dir/export-test.log",
			 'FileType'   => 'IXF',
			 #'FileOptions' => { 'CharDel' => "'",
			 #			'ColDel'  => '|',
			 #		      },
			);
    ok($rc > 0, "Export ($label)");
}
