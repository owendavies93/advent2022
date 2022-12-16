#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Utils::Input qw(get_ints);

use List::AllUtils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day16';
$file = "inputs/day16-$file" if $file =~ /test/;

my $valves = {};
my $flow_rates = {};

open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    if ($_ =~ /Valve (\w+) has flow rate=\d+; tunnels? leads? to valves? (.*)$/) {
        my $v = $1;
        my @vs = split /, /, $2;
        push @{$valves->{$v}}, $_ for @vs;
        my ($flow_rate) = get_ints($_);
        $flow_rates->{$v} = $flow_rate;
    }
}

# Convert valves to powers of 2 to simplify state storage
# (found this trick on reddit)
my $valve_pows = {};
my $flow_pows = {};
my $next_pows = {};
my $i = 1;
for my $k (sort { $a cmp $b } keys %$valves) {
    $valve_pows->{$k} = $i;
    $flow_pows->{$i} = $flow_rates->{$k};
    $i *= 2;
}

$i = 1;
for my $k (sort { $a cmp $b } keys %$valves) {
    $next_pows->{$i} = [ map { $valve_pows->{$_ } } @{$valves->{$k}} ];
    $i *= 2;
}

my $max_mins = 30;
my $start = 'AA';
my @states = ([$valve_pows->{$start}, 0, 0]);

my $best_at_state = {};

for my $m (1..$max_mins) {
    say "$m, " . scalar @states;
    my @next = ();
    for my $s (@states) {
        my $pow = $s->[0];
        my $open = $s->[1];
        my $pressure = $s->[2];

        # prune any worse states before continuing
        next if exists $best_at_state->{$pow, $open} &&
                $pressure <= $best_at_state->{$pow, $open};
        $best_at_state->{$pow, $open} = $pressure;

        my $flow_rate = $flow_pows->{$pow};
        my $tunnels = $next_pows->{$pow};

        # and compares set membership
        # or adds to set
        if (($pow & $open) == 0 && $flow_rate > 0) {
            # open the valve and record the remaining pressure
            push @next, [
                $pow, ($pow | $open), $pressure + $flow_rate * ($max_mins - $m)
            ];
        }

        # add all steps to the set of next states
        for my $next (@$tunnels) {
            push @next, [$next, $open, $pressure]
        }
    }
    @states = @next;
}

my $best_pressure = 0;
for my $s (@states) {
    if ($s->[2] > $best_pressure) {
        $best_pressure = $s->[2];   
    }
}

say $best_pressure;

