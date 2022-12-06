#!/usr/bin/env perl
use Mojo::Base -strict;

use Const::Fast;
use List::AllUtils qw(:all);

const my $LENGTH => 14;

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day6';
$file = "inputs/day6-$file" if $file =~ /test/;
open(my $fh, '<', $file) or die $!;

my $input = scalar(<$fh>);
chomp($input);
my @letters = split //, $input;

for (my $i = 0; $i < scalar @letters - $LENGTH; $i++) {
    my @slice = @letters[$i..$i + ($LENGTH - 1)];
    if ((scalar uniq @slice) == $LENGTH) {
        say $i + $LENGTH;
        exit;
    }
}
