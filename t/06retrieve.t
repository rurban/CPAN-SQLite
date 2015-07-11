# $Id: 06retrieve.t 52 2015-07-12 00:49:18Z stro $

use strict;
use warnings;
use Test::More;
use Cwd;
use File::Spec::Functions;
use File::Path;
use CPAN::DistnameInfo;
use FindBin;
use lib "$FindBin::Bin/lib";
use CPAN::SQLite::Index;
use CPAN::Config;

plan tests => 5;

my $cwd = getcwd;
my $CPAN = catdir $cwd, 't', 'cpan-t-06';

mkdir $CPAN;

ok (-d $CPAN);

my $info = CPAN::SQLite::Index->new(
  'CPAN' => $CPAN,
  'db_dir' => $cwd,
  'urllist' => $CPAN::Config->{'urllist'},
);

isa_ok($info, 'CPAN::SQLite::Index');

SKIP: {
  skip 'Potential connection problems', 3 unless $info->fetch_cpan_indices();

  ok(-e catfile($CPAN, 'authors', '01mailrc.txt.gz'));
  ok(-e catfile($CPAN, 'modules', '02packages.details.txt.gz'));
  ok(-e catfile($CPAN, 'modules', '03modlist.data.gz'));

};
