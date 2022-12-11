#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Utils::Input qw(get_ints);

use List::AllUtils qw(:all);

my $items = {};
my $divisors = {};
my $ops = {};
my $trues = {};
my $falses = {};

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day11';
$file = "inputs/day11-$file" if $file =~ /test/;

my $current = 0;

open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    if (!$_) {
       $current++; 
       next;
    }

    if (/Starting items/) {
        my @items = get_ints($_);
        $items->{$current} = \@items;
    } elsif (/Operation: new = old (.) (.*)$/) {
        my $op = $1;
        my $rhs = $2;
        $ops->{$current} = [ $op, $rhs ];
    } elsif (/Test/) {
        my ($div) = get_ints($_);
        $divisors->{$current} = $div;
    } elsif (/If true/) {
        my ($to) = get_ints($_);
        $trues->{$current} = $to;
    } elsif (/If false/) {
        my ($to) = get_ints($_);
        $falses->{$current} = $to;
    }
}

my $lcm = product values %$divisors;

my $max = $current;
my $rounds = 10000;
my $inspections = {};

for (1..$rounds) {
    for my $curr (0..$max) {
        while (scalar @{$items->{$curr}} > 0) {
            my $item = shift @{$items->{$curr}};
            my $new = op($ops->{$curr}->[0], $ops->{$curr}->[1], $item);
            $new = $new % $lcm;
            if ($new % $divisors->{$curr} == 0) {
                my $true = $trues->{$curr};
                push @{$items->{$true}}, $new;
            } else {
                my $false = $falses->{$curr};
                push @{$items->{$false}}, $new;
            }

            $inspections->{$curr}++;
        }
    }
}

my @sorted = sort { $b <=> $a } values %$inspections;
my @top2 = @sorted[0..1];
say product @top2;

sub op {
    my ($op, $rhs, $item) = @_;

    if ($op eq '*') {
        if ($rhs eq 'old') {
            return $item * $item;
        } else {
            return $item * int($rhs);
        }
    } else {
        if ($rhs eq 'old') {
            return $item + $item;
        } else {
            return $item + int($rhs);
        }
    }
}
