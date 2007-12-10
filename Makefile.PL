#
# MakeMaker file for the DB2 Administrative API
#
# $Id: Makefile.PL,v 145.1 2007/10/17 14:28:21 biersma Exp $
#

use Config;
use ExtUtils::MakeMaker;
use strict;

#
# DB2_VERSION will be 7.1, 7.2, 8.1, 8.2, 9.1, 9.5
#
my $db2_version = $ENV{DB2_VERSION} || do {
    #
    # Exit with zero status to avoid warnings from CPAN testers
    #
    warn "Environment variable 'DB2_VERSION' not set\n";
    exit(0);
};

my ($db2_path, $db2_version_enum, @defines, %extra_args);

#
# Determine path and version enum
#
if ($db2_version =~ /^V7\./) {
    $db2_path = "/opt/IBMdb2/V7.1";
    $db2_version_enum = 'db2Version710';
} elsif ($db2_version =~ /^V8\./) {
    $db2_path = "/opt/IBM/db2/V8.1";
    $db2_version_enum = 'db2Version810';
} elsif ($db2_version =~ /^V9\.1/) {
    if ($^O eq 'linux') {
	$db2_path = "/opt/ibm/db2/V9.1";
    } elsif ($^O eq 'solaris') {
	$db2_path = "/opt/IBM/db2/V9.1";
    } else {
	die "unexpected V9.1 platform '$^O'";
    }
    $db2_version_enum = 'db2Version900';
} elsif ($db2_version =~ /^V9\.5/) {
    if ($^O eq 'linux') {
	$db2_path = "/opt/ibm/db2/V9.5";
    } elsif ($^O eq 'solaris') {
	$db2_path = "/opt/IBM/db2/V9.5";
    } else {
	die "unexpected V9.5 platform '$^O'";
    }
    $db2_version_enum = 'db2Version950';
} else {
    die "Unsupported DB2 version '$db2_version'\n";
}
push @defines, "-DDB2_VERSION_ENUM=$db2_version_enum";

#
# This deals with a Morgan Stanley specific setup, where we install
# DB2 in a non-standard location and then make /opt/IBM/xxx link to
# it.  If $ENV{DB2_PREFIX} is set and resolves to a directory, use that
# as the db2path for compilation/installation.
#
# We also do some horrible link-time tricks.  Don't try this at home...
#
if ($ENV{DB2_PREFIX}) {
    $db2_path = $ENV{DB2_PREFIX};
    die "DB2_PREFIX path '$db2_path' invalid" unless (-d $db2_path);

    #
    # For DB2 V9.1, we have 'lib32' and 'lib64' but no 'lib'.
    #
    # FIXME: we may also need this for 32-bit, and we will
    # need to change this for 64-bit versions of perl.
    #
    # FIXME: We really should do this base don the DB2 release and the
    # bitness of perl.
    #
    my $lib_pf = 'lib';
    if ($ENV{ID_EXEC} eq 'ia32.linux.2.6.glibc.2.3' ||
	$ENV{ID_EXEC} eq 'x86_64.linux.2.6.glibc.2.3') {
	$extra_args{CCFLAGS} = '-m32';
	$lib_pf = 'lib32';
    } elsif ($ENV{ID_EXEC} eq 'sun4.sunos64.5.10') {
	$lib_pf = 'lib32';
    }

    my $sysliblist = "-L$db2_path/$lib_pf -ldb2";
    my @db2libs = qw(db2install db2g11n db2locale db2osse
		     db2genreg db2trcapi db2dascmn db2osse_db2);
    if ( $Config{osname} =~ /linux/i ) {
	$extra_args{LDDLFLAGS} = 
	  "-shared -Wl,--enable-new-dtags -Wl,-rpath $db2_path/$lib_pf";
	if ($ENV{ID_EXEC} eq 'ia32.linux.2.6.glibc.2.3' ||
	    $ENV{ID_EXEC} eq 'x86_64.linux.2.6.glibc.2.3') {
	    $extra_args{LDDLFLAGS} .= ' -m32';
	} else {
	    $sysliblist .= ' -L/tmp -lcxa';	# Setup in Makefile.inner
	}
    } elsif ( $Config{osname} =~ /solaris/i ) {
	#$sysliblist = "-R$db2_path/lib $sysliblist";
    }
    $sysliblist .= ' ' .join(' ', map {"-l$_"} @db2libs);
    $extra_args{LIBS} = [ $sysliblist ];
}

#
# In version V8.1 and above, we have the database / database
# manager configuration calls and db2Runstats.
#
if ($db2_version ge 'V8.1') {
    push @defines, "-DADMIN_API_HAVE_DB2CFG";
    push @defines, "-DADMIN_API_HAVE_DB2RUNSTATS";
}

#
# In version 8.2 (but not above), use the V8.2 version db2DbDirXXX
# functions to access the database directory.
#
if ($db2_version eq 'V8.2') {
    push @defines, "-DADMIN_API_HAVE_DB2DBDIR_V8";
}

#
# In version 8.2 and above, use the db2Import/db2Export/db2Load
# functions for data import/export/load.
#
if ($db2_version ge 'V8.2') {
    push @defines, "-DADMIN_API_HAVE_DB2DBDIR";
    push @defines, "-DADMIN_API_HAVE_DB2EXPORT";
    push @defines, "-DADMIN_API_HAVE_DB2IMPORT";
    push @defines, "-DADMIN_API_HAVE_DB2LOAD";
}

#
# In version 9.1 and above, use the V9 version of the db2DbDirInfo
# structure and support XML for import/export
#
if ($db2_version ge 'V9.1') {
    push @defines, "-DADMIN_API_HAVE_DB2DBDIR_V9";
    push @defines, "-DADMIN_API_HAVE_EXPORT_XML";
    push @defines, "-DADMIN_API_HAVE_IMPORT_XML";
}

#
# In version 9.5 and above, use the LOngActionString for import
# and load; support XML for load.
#
if ($db2_version ge 'V9.5') {
    push @defines, "-DADMIN_API_HAVE_IMPORT_LONG_ACTION";
    push @defines, "-DADMIN_API_HAVE_LOAD_LONG_ACTION";
    push @defines, "-DADMIN_API_HAVE_LOAD_XML";
}

WriteMakefile('NAME'         => 'DB2::Admin',
	      'VERSION_FROM' => 'lib/DB2/Admin.pm',
	      'PREREQ_PM'    => { 'Params::Validate' => '0.87',
				  'Test::Simple'     => '0.62',
				},
	      'INC'          => "-I$db2_path/include",
	      'LIBS'         => "-L$db2_path/lib -ldb2",
	      'DEFINE'       => "@defines",
	      %extra_args,
	     );
