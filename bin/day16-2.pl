#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Utils::Input qw(get_ints);

use List::AllUtils qw(:all);
use List::PriorityQueue;
use Memoize;

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day16';
$file = "inputs/day16-$file" if $file =~ /test/;

my $valves = {};
my $flow_rates = {};
my $total_flow = 0;

open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    if ($_ =~ /Valve (\w+) has flow rate=\d+; tunnels? leads? to valves? (.*)$/) {
        my $v = $1;
        my @vs = split /, /, $2;
        push @{$valves->{$v}}, $_ for @vs;
        my ($flow_rate) = get_ints($_);
        $flow_rates->{$v} = $flow_rate;
        $total_flow += $flow_rate;
    }
}

my $best_flow = 0;

say get_best_flow(0, 26, {}, ['AA', 'AA'], 0);

memoize('paths');
    sub paths {
    my $start = shift;
    my $q = List::PriorityQueue->new();
    my $dists = {};

    $q->insert([$start, 0], 0);
    while (my $c = $q->pop()) {
        my ($v, $d) = @$c;

        for my $n (@{$valves->{$v}}) {
            next if exists $dists->{$n};

            $dists->{$n} = $d + 2;
            $q->insert([$n, $d + 1], $d + 1);
        }
    }

    my $pos_dists = {};
    for my $k (keys %$dists) {
        $pos_dists->{$k} = $dists->{$k} if $flow_rates->{$k} > 0;
    }

    return $pos_dists;
}

sub get_best_flow {
    my ($cur_flow, $rem_mins, $on, $valves, $other) = @_;
    my $flow = $cur_flow;

    my $paths = paths($valves->[0]);
    for my $d (keys %$paths) {
        my $t = $paths->{$d};

        if (!exists $on->{$d} && $t <= $rem_mins) {
            my $next_valves = [$valves->[1], $d];
            my $next_mins   = $rem_mins - $other;
            my $next_other  = $t - $other;

            my $new_flow = $cur_flow + ($rem_mins - $t) * $flow_rates->{$d};
            # Guess a likely average flow rate per minute to prune with
            my $prune_value = ($rem_mins * 2 - $t - $other) * 45;

            next if $new_flow + $prune_value < $best_flow;

            my $new_on = { %$on };
            $new_on->{$d} = 1;

            my $candidate_flow = get_best_flow(
                $new_flow, $next_mins, $new_on, $next_valves, $next_other
            );

            $flow = max($best_flow, $candidate_flow);
        }
    }

    $best_flow = max($best_flow, $flow);
    return $flow;
}

