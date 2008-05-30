#
# Test the backup functions
#
# $Id: 70backup.t,v 160.1 2008/03/24 14:47:39 biersma Exp $
#

#
# Get the database/schema/table names from the CONFIG file
#
our %myconfig;
require "util/parse_config";
my $db_name = $myconfig{DBNAME};
$db_name = 'ADMIN';

use strict;
use Data::Dumper;
use Test::More tests => 7;
BEGIN { use_ok('DB2::Admin'); }

#DB2::Admin->SetOptions('RaiseError' => 1);
#ok(1, "SetOptions");

my $trackmod = 0;
{
    my @retval = DB2::Admin::->
      GetDatabaseConfig('Param'    => [ qw(trackmod) ],
			'Flag'     => 'Delayed',
			'Database' => $db_name);
    #print Dumper(\@retval);
    if ($retval[0]{Value}) {
	$trackmod = 1;
    }
    ok(1, "Get database config for trackmod");
}

#
# Do full, incremental and delta backup to /dev/null
# Only try incremental/delta if trackmod set
#
SKIP: {
    foreach my $type (qw(Full Incremental Delta)) {
	unless ($type eq 'Full' || $trackmod) {
	    skip("Skip $type backup as trackmod not set", 1);
	}

	my $rc = DB2::Admin->Backup('Database' => $db_name,
				    'Target'   => '/dev/null',
				    'Options'  => { 'Type'   => $type, 
						    'Online' => 1,
						  },
				   );
	ok(1, "Backup - whole database - $type");
	#print Dumper($rc);
    }
}

#
# Do a backup with a christmas tree of options
#
if (1) {
    my $options = { 'Type'           => 'Full',
		    'Action'         => 'ParamCheckOnly',
		    'Online'         => 1,
		    'Compress'       => 0,
		    'IncludeLogs'    => 1,
		    'ImpactPriority' => 75,
		    #'Parallelism'    => 8, # Conflicts with ParamCheckOnly
		    'NumBuffers'     => 64,
		    'BufferSize'     => 16,
		    #'Nodes'          => [ 2 ],
		  };
    my $rc = DB2::Admin->Backup('Database' => $db_name,
				'Target'   => '/dev/null',
				'Options'  => $options,
			       );
    ok(1, "Backup - parameter check only - many options");
    #print Dumper($rc);
}


#
# DPF test
#
if (1) {
    my $rc = DB2::Admin->Backup('Database' => $db_name,
				#'Target'   => [ '/tmp/bogus', '/tmp/b' ],
				'Target'   => '/dev/null',
				'Options'  =>  { Online   => 1,
						 #Action   => 'ParamCheckOnly',
						 Compress => 1,
						 Nodes    => 'All',
					       },
			       );
    ok(1, "Backup - DPF case");
    #print Dumper($rc);
}
