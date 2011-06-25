# $Id: Build.PL 35 2011-06-17 01:34:42Z stro $

use strict;
use warnings;
use Module::Build;

if ($ENV{'PERL5LIB'} and (my $env5 = length $ENV{'PERL5LIB'}) > 65535) {
    print <<__OH_ANOTHER_BROKEN_SMOKER__;

******************************************************************************
* OH NO, ANOTHER BROKEN SMOKER!                                              *
*                                                                            *
* I appreciate that you are participating in CPAN Testing, but there's one   *
* problem. YOU'RE DOING IT WRONG.                                            *
*                                                                            *
* Groving PERL5LIB environment variable is bad, because it leads to wrong    *
* test reports. If you're using "build_dir_reuse" while smoking, make sure   *
* you change "clean_cache_after" to some small value, not default 100.       *
* Personally, I prefer 1.                                                    *
*                                                                            *
******************************************************************************

Your PERL5LIB is $env5 bytes long. Think about it!
Why don't you just run this instead:

 $^X -MCPAN::Reporter::Smoker -e "start('clean_cache_after', 1)" 

__OH_ANOTHER_BROKEN_SMOKER__
    
    exit(0);
}

my @exe_files = map {"bin/$_"} qw(cpandb);
my $goners = [qw(cpandb.sql
                 t/dot-cpan/cpandb.sql
                 t/dot-cpan/FTPstats.yml
                 t/dot-cpan/CPAN/MyConfig.pm
                 t/dot-cpan/cpan_sqlite_log.*
                 t/dot-cpan/sources/authors/01mailrc.txt.gz
                 t/dot-cpan/sources/modules/02packages.details.txt.gz
                 t/dot-cpan/sources/modules/03modlist.data.gz
                )];
my $prereqs = {'File::Spec' => 0,
               'Archive::Tar' => 1.08,
               'IO::Zlib' => 0,
               'Compress::Zlib' => 0,
               'CPAN::DistnameInfo' => 0.09,
               'DBD::SQLite' => 1.27,   # for REGEX implementation
               'File::HomeDir' => 0,
               'LWP::Simple' => 0,
              };

my $build = Module::Build->new(
  module_name => 'CPAN::SQLite',
  license => 'perl',
  add_to_cleanup => $goners,
  installdirs => 'site',
  requires => $prereqs,
  script_files => \@exe_files,
  dist_version_from => 'lib/CPAN/SQLite.pm',
  dist_author => ['Serguei Trouchelle <stro@cpan.org>'],
  dist_abstract_from => 'lib/CPAN/SQLite.pm',
    'meta_merge' => {
        'resources'  => {
            'repository' => 'http://svn.trouchelle.com/perlmodules/CPAN-SQLite/',
        },
        'no_index'   => {
             'file'      => ['t/dot-cpan/CPAN/TestConfig.pm', 't/lib/TestSQL.pm'],
        },
    },
);

$build->create_build_script;

