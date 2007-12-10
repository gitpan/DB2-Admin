#
# Test the reset monitor function
#
# $Id: 21reset_monitor.t,v 17.1 2004/08/30 15:53:08 biersma Exp $
#

use strict;
use Test::More tests => 4;
BEGIN { use_ok('DB2::Admin'); }

DB2::Admin->SetOptions('RaiseError' => 1);
ok(1, "SetOptions");

my $retval = DB2::Admin->Attach();
ok($retval, "Attach");

$retval = DB2::Admin->ResetMonitor();
ok($retval, "ResetMonitor");
