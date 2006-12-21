use strict;
use warnings;
use Test::More;
use File::Spec;
use Cwd;
use File::Copy;
use File::Path;
use Config;
use FindBin;
use CPAN::DistnameInfo;
use CPAN::SQLite::Util qw(download);
use lib "$FindBin::Bin/lib";
use TestSQL qw($mods $auths $dists has_hash_data);
my $cwd = cwd;
my $path_sep = $Config{path_sep} || ':';
$ENV{PERL5LIB} = join $path_sep, 
  (File::Spec->catdir($cwd, qw(t dot-cpan)),
   map {File::Spec->catdir($cwd, 'blib', $_)} qw(arch lib) );
# so that a real $HOME/.cpan isn't used
$ENV{HOME} = File::Spec->catdir($cwd, qw(t));

my $from = File::Spec->catfile($cwd, qw(t dot-cpan CPAN TestConfig.pm));
my $to = File::Spec->catfile($cwd, qw(t dot-cpan CPAN MyConfig.pm));
unless (-f $to) {
  copy ($from, $to) or die qq{Cannot cp $from to $to: $!};
}

unshift @INC, File::Spec->catdir($cwd, qw(t dot-cpan));
eval { require CPAN::MyConfig;
       require CPAN;
       require CPAN::HandleConfig;
       require CPAN::Version; };

my $min_cpan_v = '1.88_64';
my $actual_cpan_v = $CPAN::VERSION;
if ($@ or CPAN::Version->vcmp($actual_cpan_v, $min_cpan_v) < 0) {
  plan skip_all => qq{Need CPAN.pm version $min_cpan_v or higher};
}
else {
  plan tests => 2535;
}

my $home = $CPAN::Config->{cpan_home};
my $sources = $CPAN::Config->{keep_source_where};
my @dirs = map{File::Spec->catdir($sources, $_)} qw(authors modules);
for (@dirs) {
  next if -d $_;
  mkpath($_) or die qq{Cannot mkpath $_: $!};
}

foreach my $cpanid (keys %$auths) {
  my $auth = CPAN::Shell->expand("Author", $cpanid);
  is($auth->id, $cpanid);
  foreach (qw(fullname email)) {
    next unless $auths->{$cpanid}->{$_};
    is($auth->$_, $auths->{$cpanid}->{$_});
  }
}

foreach my $mod_name (keys %$mods) {
  my $mod = CPAN::Shell->expand("Module", $mod_name);
  is($mod->id, $mod_name);
  like($mod->cpan_file, qr/$mods->{$mod_name}->{dist_name}/,
       $mods->{$mod_name}->{dist_name});
  next unless $mods->{$mod_name}->{mod_vers};
  is($mod->cpan_version, $mods->{$mod_name}->{mod_vers},
     "version $mods->{$mod_name}->{mod_vers}");
}

foreach my $mod_name (keys %$mods) {
  next unless ($mod_name =~ /^Bundle::/);
  my $bundle = CPAN::Shell->expand("Bundle", $mod_name);
  is($bundle->id, $mod_name);
  like($bundle->cpan_file, qr/$mods->{$mod_name}->{dist_name}/,
       $mods->{$mod_name}->{dist_name});
  next unless $mods->{$mod_name}->{mod_vers};
  is($bundle->cpan_version, $mods->{$mod_name}->{mod_vers},
     "version $mods->{$mod_name}->{mod_vers}");
}

for my $dist_name(keys %$dists) {
  my $dist_file = $dists->{$dist_name}->{dist_file};
  my $cpanid = $dists->{$dist_name}->{cpanid};
  my $query = "$cpanid/$dist_file";
  my $dist = CPAN::Shell->expand("Distribution", $query);
  my $dist_id = download($cpanid, $dists->{$dist_name}->{dist_file});
  is($dist->id, $dist_id);
  is($dist->author->id, $cpanid);
  my $mods = $dist->containsmods;
  foreach my $mod(keys %{$dists->{$dist_name}->{modules}}) {
    like($mod, qr/\b$mod\b/, $mod);
  }
}

for my $mod_search (qw(net ^uri::.*da)) {
  for my $mod (CPAN::Shell->expand("Module", "/$mod_search/")) {
    my $mod_name = $mod->id;
    is(defined $mods->{$mod_name}, 1, $mod_name);
    like($mod->cpan_file, qr/$mods->{$mod_name}->{dist_name}/,
         $mods->{$mod_name}->{dist_name});
    next unless $mods->{$mod_name}->{mod_vers};
    is($mod->cpan_version, $mods->{$mod_name}->{mod_vers},
       "version $mods->{$mod_name}->{mod_vers}");
  }
}

for my $mod_search (qw(CPAN MP)) {
  for my $bundle (CPAN::Shell->expand("Bundle", "/$mod_search/")) {
    my $mod_name = $bundle->id;
    is(defined $mods->{$mod_name}, 1, $mod_name);
    like($bundle->cpan_file, qr/$mods->{$mod_name}->{dist_name}/,
         $mods->{$mod_name}->{dist_name});
    next unless $mods->{$mod_name}->{mod_vers};
    is($bundle->cpan_version, $mods->{$mod_name}->{mod_vers},
       "version $mods->{$mod_name}->{mod_vers}");
  }
}

for my $dist_search(qw(apache test.*perl)) {
  for my $dist (CPAN::Shell->expand("Distribution", "/$dist_search/")) {
    my $id = $dist->id;
    my $pathname = "authors/id/$id";
    my $d = CPAN::DistnameInfo->new($pathname);
    my $dist_name = $d->dist;
    is(defined $dists->{$dist_name}, 1, $dist_name);
    my $cpanid = $dist->author->id;
    my $download = download($cpanid, $dists->{$dist_name}->{dist_file});
    is($id, $download, $download);
    is($cpanid, $dists->{$dist_name}->{cpanid},
       $dists->{$dist_name}->{cpanid});
    my $mods = $dist->containsmods;
    foreach my $mod(keys %{$dists->{$dist_name}->{modules}}) {
      like($mod, qr/\b$mod\b/, $mod);
    }
  }
}

for my $auth_search (qw(G G\w+A)) {
  for my $auth (CPAN::Shell->expand("Author", "/$auth_search/")) {
    my $id = $auth->id;
    is(defined $auths->{$id}, 1, $id);
    foreach (qw(fullname email)) {
      next unless $auths->{$id}->{$_};
      is($auth->$_, $auths->{$id}->{$_}, $auths->{$id}->{$_});
    }
  }
}

my $no_such = 'ZZZ';
foreach my $type(qw(Author Distribution Module)) {
  my $query = ($type eq 'Distribution') ? "/$no_such/" : $no_such;
  my $item = CPAN::Shell->expand($type, $query);
  is($item, undef, "no such $type");
  next if $type eq 'Distribution';
  $item = CPAN::Shell->expand($type, "/$no_such/");
  is($item, undef, "no such $type");

}

rmtree($sources) if -d $sources;

# Local Variables:
# mode: cperl
# cperl-indent-level: 2
# End:
