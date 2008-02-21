#
# Test the snapshot functions
#
# $Id: 30snapshot.t,v 150.1 2007/12/12 19:29:29 biersma Exp $
#

use strict;
use Test::More tests => 9;
BEGIN { use_ok('DB2::Admin'); }

DB2::Admin->SetOptions('RaiseError' => 1);
ok(1, "SetOptions");

my $retval = DB2::Admin->Attach();
ok($retval, "Attach");

$retval = DB2::Admin->GetSnapshot('Subject' => 'SQLMA_DBASE_ALL');
ok($retval, "Get database snapshot");

my $formatted = $retval->Format();
ok($formatted, "Format");

my ($node) = $retval->findNodes('DBASE/MEMORY_POOL');
ok($node, "findNodes");

$node = $retval->findNode('DBASE/MEMORY_POOL');
ok($node, "findNode");

my $rc = $node->findValue('POOL_ID');
ok (defined $rc, "findValue");

$rc = $node->getValues();
ok($rc, "getValues");
