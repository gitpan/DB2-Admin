#
# Test of the DB2::Admin::Constants module
#
# $Id: 02constants.t,v 17.1 2004/08/30 15:52:43 biersma Exp $
#

use strict;
use Test::More tests => 4;
BEGIN { use_ok('DB2::Admin'); }

my $constant = 'SQLM_PLATFORM_WINDOWS';

#
# Lookup information for a constant
#
my $info = DB2::Admin::Constants::->GetInfo($constant);
ok($info, "GetInfo");

#
# Get numerical value for a constant
#
my $num = DB2::Admin::Constants::->GetValue($constant);
ok($num, "GetValue");

#
# Get the name for a number
#
my $name = DB2::Admin::Constants::->Lookup('Platform', $num);
ok(defined $name && $name eq $constant, "Lookup");
