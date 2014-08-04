# $Id: Build.PL 42 2013-06-29 20:44:17Z stro $

use strict;
use warnings;
use Module::Build;

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
               'CPAN::Index' => 1.93, # No more false negatives because of CPAN-Index
               'parent' => 0,
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

