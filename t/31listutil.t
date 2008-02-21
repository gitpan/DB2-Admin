#
# Test 'list utilities' function (which uses the snapshot API)
#
# $Id: 31listutil.t,v 150.1 2007/12/12 19:29:21 biersma Exp $
#

use strict;
use Test::More tests => 5;
BEGIN { use_ok('DB2::Admin'); }

DB2::Admin->SetOptions('RaiseError' => 1);
ok(1, "SetOptions");

my $retval = DB2::Admin->Attach();
ok($retval, "Attach");

SKIP: {
    my $version = substr($ENV{DB2_VERSION}, 1); # Vx.y -> x.y
    skip("db2Load not available in DB2 version < 8.1", 1) if ($version < 8);

    my @utils = DB2::Admin->ListUtilities();
    ok(1, "List Utilities");
}

$retval = DB2::Admin->Detach();
ok($retval, "Detach");
