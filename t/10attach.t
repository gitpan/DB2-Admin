#
# Test the attach / detach functions
#
# $Id: 10attach.t,v 17.1 2004/08/30 15:52:51 biersma Exp $
#

use strict;
use Test::More tests => 5;
BEGIN { use_ok('DB2::Admin'); }

DB2::Admin->SetOptions('RaiseError' => 1);
ok(1, "SetOptions");

my $retval = DB2::Admin->Attach();
ok($retval, "Attach");

$retval = DB2::Admin->InquireAttach();
ok($retval, "InquireAttach");

$retval = DB2::Admin->Detach();
ok($retval, "Detach");
