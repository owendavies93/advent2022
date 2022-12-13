#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Utils::Input qw(get_nonempty_groups);

use List::AllUtils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day13';
$file = "inputs/day13-$file" if $file =~ /test/;
open(my $fh, '<', $file) or die $!;
my @pairs = get_nonempty_groups($fh);

my $i = 1;
my $packets = [
    [[2]],
    [[6]],
];

for my $pair (@pairs) {
    my $f = $pair->[0];
    my $s = $pair->[1];

    my $left = eval $f;
    my $right = eval $s;

    push @$packets, $left;
    push @$packets, $right;
}

my @sorted = sort { compare($a, $b) } @$packets;

my $x = 1 + first_index {
    ref($_) eq 'ARRAY' && ref($_->[0]) eq 'ARRAY' &&
    defined $_->[0]->[0] && $_->[0]->[0] == 2
} @sorted;

my $y = 1 + first_index {
    ref($_) eq 'ARRAY' && ref($_->[0]) eq 'ARRAY' &&
    defined $_->[0]->[0] && $_->[0]->[0] == 6
} @sorted;

say $x * $y;

sub compare {
    my ($l, $r) = @_;

    if ($l =~ /^\d+$/ && $r =~ /^\d+$/) {
        return -1 if $l < $r;
        return 1 if $l > $r;
        return 0 if $l == $r;
    } elsif (ref($l) eq 'ARRAY' && ref($r) eq 'ARRAY') {
        for (my $i = 0; $i < scalar @$l && $i < scalar @$r; $i++) {
            my $result = compare($l->[$i], $r->[$i]);
            return $result if $result != 0;
        }

        return -1 if scalar @$l < scalar @$r;
        return 1 if scalar @$l > scalar @$r;
        return 0;
    } else {
        if ($l =~ /^\d+$/) {
            return compare([$l], $r);
        } else {
            return compare($l, [$r]);
        }
    }
}
