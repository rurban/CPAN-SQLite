use strict;
use warnings;
use Module::Build;

my @exe_files = map {"bin/$_"} qw(cpandb);
my $goners = [qw(cpandb.sql
		 t/dot-cpan/cpandb.sql
		 t/dot-cpan/FTPstats.yml
		 t/dot-cpan/CPAN/MyConfig.pm
		 t/dot-cpan/cpan_sqlite_log.*
		)];
my $prereqs = {'File::Spec' => 0,
               'Archive::Tar' => 1.08,
               'IO::Zlib' => 0,
               'CPAN::DistnameInfo' => 0,
               'DBD::SQLite' => 0,
	       'File::HomeDir' => 0,
	      };

my $build = Module::Build->new(
  module_name => 'CPAN::SQLite',
  license => 'perl',
  add_to_cleanup => $goners,
  installdirs => 'site',
  requires => $prereqs,
  script_files => \@exe_files,
  dist_version_from => 'lib/CPAN/SQLite.pm',
  dist_author => ['Randy Kobes <r.kobes@uwinnipeg.ca>'],
  dist_abstract_from => 'lib/CPAN/SQLite.pm',
);

$build->create_build_script;

