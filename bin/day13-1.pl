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
my $sum = 0;
for my $pair (@pairs) {
    my $f = $pair->[0];
    my $s = $pair->[1];

    my $left = eval $f;
    my $right = eval $s;

    $sum += $i if compare($left, $right);

    $i++;
}
say $sum;

sub compare {
    my ($l, $r) = @_;

    if ($l =~ /^\d+$/ && $r =~ /^\d+$/) {
        return 1 if $l < $r;
        return 0 if $l > $r;
        return undef if $l == $r;
    } elsif (ref($l) eq 'ARRAY' && ref($r) eq 'ARRAY') {
        for (my $i = 0; $i < scalar @$l && $i < scalar @$r; $i++) {
            my $result = compare($l->[$i], $r->[$i]);
            return $result if defined $result;
        }

        return 1 if scalar @$l < scalar @$r;
        return 0 if scalar @$l > scalar @$r;
        return undef;
    } else {
        if ($l =~ /^\d+$/) {
            return compare([$l], $r);
        } else {
            return compare($l, [$r]);
        }
    }
}
