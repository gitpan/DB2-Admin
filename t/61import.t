#
# Test the import functions
#
# $Id: 61import.t,v 145.1 2007/10/17 14:42:48 biersma Exp $
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
use Test::More tests => 18;
BEGIN { use_ok('DB2::Admin'); }

DB2::Admin->SetOptions('RaiseError' => 1);
ok(1, "SetOptions");

my $rc = DB2::Admin->Connect('Database' => $db_name);
ok($rc, "Connect - $db_name");

#
# Test import of IXF file without LOBs
#
my $results = DB2::Admin->Import('Database'      => $db_name,
			     'Schema'        => $schema_name,
			     'Table'         => $table_name,
			     #'TargetColumns' => [ qw(SALES_PERSON SALES_DATE) ],
			     #'InputFile'     => $data_file,
			     'InputFile'     => "$export_dir/export-test.ixf",
			     #'InputColumns'  => [ 2, 1 ],
			     #'InputColumns'  => [ qw(SALES_PERSON SALES_DATE) ],
			     'LogFile'       => "$export_dir/import-test.log",
			     'FileType'      => 'IXF',
			     'Operation'     => 'Replace',
			     #'ImportOptions' => { 'CommitCount'  => 10,
			     #			   'RowCount'     => 10,
			     #		           'SkipCount'    => 20,
			     #	                   'WarningCount' => 5,
			     #                     'TimeOut'      => 1,
			     #		           'AccessLevel'  => 'Write',
			     #                   },
			    );
ok(defined $results, "Import succeeded - IXF w/o LOBs");
#print STDERR Dumper($results);

#
# Test import of DEL file with LOBs
#
$table_name = $myconfig{TARGET_LOB_TABLE};
$results = DB2::Admin->Import('Database'      => $db_name,
			  'Schema'        => $schema_name,
			  'Table'         => $table_name,
			  'InputFile'     => "$export_dir/export-test-lob.del",
			  'LogFile'       => "$export_dir/import-test-lob.log",
			  'FileType'      => 'DEL',
			  'FileOptions'   => { 'LobsInFile' => 1, },
			  'Operation'     => 'Replace',
			  'LobPath'       => $myconfig{LOB_DIRECTORY},
			 );
ok(defined $results, "Import succeeded - DEL with LOBs");
#print STDERR Dumper($results);

#
# Test import of IXF file with XML
#
SKIP: {
    my $version = substr($ENV{DB2_VERSION}, 1); # Vx.y -> x.y
    skip("XML not available in DB2 version < 9.1", 12) if ($version < 9.1);

    $table_name = $myconfig{TARGET_XML_TABLE};
    foreach my $save (0, 1) {
	foreach my $sep (0, 1) {
	    foreach my $xml_parse (undef, 'Strip', 'Preserve') {
		my $import_options = {};
		if (defined $xml_parse) {
		    $import_options->{XmlParse} = $xml_parse;
		}
		
		$results = DB2::Admin->
		  Import('Database'      => $db_name,
			 'Schema'        => $schema_name,
			 'Table'         => $table_name,
			 'InputFile'     => "$export_dir/export-test-xml-$save-$sep.ixf",
			 'LogFile'       => "$export_dir/import-test-xml-$save-$sep.log",
			 'FileType'      => 'IXF',
			 'Operation'     => 'Replace',
			 'ImportOptions' => $import_options,
			 'XmlPath'       => $myconfig{XML_DIRECTORY},
			);
		ok(defined $results, "Import succeeded - IXF with XML (save=$save, sep=$sep)");
		#print STDERR Dumper($results);
	    }			# End foreach: XmlParse option
	}			# End foreach: sep
    }				# End foreach: save
}				# End: SKIP

$rc = DB2::Admin->Disconnect('Database' => $db_name);
ok($rc, "Disconnect - $db_name");
