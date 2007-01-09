#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use DBD::SQLite;
BEGIN {plan tests => 7};
my $db_name = 'cpandb.sql';

unlink($db_name) if (-e $db_name);

my $dbh = DBI->connect("DBI:SQLite:$db_name",
                       {RaiseError => 1, AutoCommit => 0})
  or die "Cannot connect to $db_name";
ok($dbh);
isa_ok($dbh, 'DBI::db');
my @tables = qw(mods auths chaps dists chapters);
for my $table(@tables) {
  $dbh->do(qq{drop table if exists $table});
  pass("Drop $table");
}
$dbh->disconnect;
