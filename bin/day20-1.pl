#!/usr/bin/env perl
use Mojo::Base -strict;

use List::AllUtils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day20';
$file = "inputs/day20-$file" if $file =~ /test/;
open(my $fh, '<', $file) or die $!;

my @data;
my $length = 0;
while (<$fh>) {
    chomp;
    push @data, {
        num => int($_),
        idx => $length,
    };
    $length++;
}

mix($_) for 0..$length - 1;
    
my $first = first_index { $_->{num} == 0 } @data;
my $sum = 0;
for (1000, 2000, 3000) {
    $sum += $data[($first + $_) % $length]->{num};
}
say $sum;

sub mix {
    my $index = shift; 
    my $curr = first_index { $_->{idx} == $index } @data;
    my $entry = splice @data, $curr, 1;
    my $nidx = ($curr + $entry->{num}) % ($length - 1);
    splice @data, $nidx, 0, $entry;
}
