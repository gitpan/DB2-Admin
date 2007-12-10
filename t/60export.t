#
# Test the export functions
#
# $Id: 60export.t,v 145.1 2007/10/17 14:42:55 biersma Exp $
#

#
# Get the database/schema/table names from the CONFIG file
#
our %myconfig;
require "util/parse_config";
my $db_name = $myconfig{DBNAME};
my $schema_name = uc(getpwuid ($<));
my $table_name = $myconfig{SOURCE_TABLE};
my $export_dir = $myconfig{EXPORT_DIRECTORY};

my $columns = undef;

use strict;
use Test::More tests => 11;
BEGIN { use_ok('DB2::Admin'); }

DB2::Admin->SetOptions('RaiseError' => 1);
ok(1, "SetOptions");

my $rc = DB2::Admin->Connect('Database' => $db_name);
ok($rc, "Connect - $db_name");

#
# Create the export, LOB and XML directories
#
mkdir($myconfig{EXPORT_DIRECTORY}, 0755);
mkdir($myconfig{LOB_DIRECTORY}, 0755);
mkdir($myconfig{XML_DIRECTORY}, 0755);

#
# Test export w/o LOBs for DEL and IXF.  We need DEL to load
# into a DPF instance.
#
foreach my $type (qw(DEL IXF)) {
    $rc = DB2::Admin->Export('Database'     => $db_name,
			 'Schema'       => $schema_name,
			 'Table'        => $table_name,
			 #'FinalClauses' => 'ORDER BY region',
			 'Columns'      => $columns,
			 'OutputFile'   => "$export_dir/export-test.\L$type",
			 'LogFile'      => "$export_dir/export-test-\L$type\E.log",
			 'FileType'     => $type,
			);
    ok($rc > 0, "Export of $type w/o LOBs - exported $rc rows");
}

#
# Export with LOBs using a DEL file
#
$table_name = $myconfig{SOURCE_LOB_TABLE};
$rc = DB2::Admin->Export('Database'    => $db_name,
		     'Schema'      => $schema_name,
		     'Table'       => $table_name,
		     'Columns'     => $columns,
		     'OutputFile'  => "$export_dir/export-test-lob.del",
		     'LogFile'     => "$export_dir/export-test-del-lob.log",
		     'FileType'    => 'DEL',
		     'FileOptions' => { 'LobsInFile' => 1, },
		     'LobPath'     => $myconfig{LOB_DIRECTORY},
		     'LobFile'     => 'prefix',
		    );
ok($rc > 0, "Export of DEL w LOBs - exported $rc rows");

#
# Export with XML using an IXF file
#
SKIP: {
    my $version = substr($ENV{DB2_VERSION}, 1); # Vx.y -> x.y
    skip("XML not available in DB2 version < 9.1", 4) if ($version < 9.1);

    $table_name = $myconfig{SOURCE_XML_TABLE};
    foreach my $save (0, 1) {
	foreach my $sep (0, 1) {
	    $rc = DB2::Admin->
	      Export('Database'      => $db_name,
		     'Schema'        => $schema_name,
		     'Table'         => $table_name,
		     'Columns'       => $columns,
		     'OutputFile'    => "$export_dir/export-test-xml-$save-$sep.ixf",
		     'LogFile'       => "$export_dir/export-test-ixf-xml-$save-$sep.log",
		     'FileType'      => 'IXF',
		     'FileOptions'   => { 'XmlInSepFiles' => $sep, },
		     'ExportOptions' => { 'XmlSaveSchema' => $save, },
		     'XmlPath'       => $myconfig{XML_DIRECTORY},
		     'XmlFile'       => "prefix-save=$save-sep=$sep",
		);
	    ok($rc > 0, "Export of IXF w XML (XmlSaveSchema=$save, XmlInSepFiles=$sep) - exported $rc rows");
	}
    }
}

$rc = DB2::Admin->Disconnect('Database' => $db_name);
ok($rc, "Disconnect - $db_name");
