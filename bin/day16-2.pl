#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Utils::Input qw(get_ints);

use Algorithm::Combinatorics qw(permutations);
use Data::Dumper;
use List::AllUtils qw(:all);
use List::PriorityQueue;

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

my $all = 1;
$i = 1;
for my $k (sort { $a cmp $b } keys %$valves) {
    $next_pows->{$i} = [ map { $valve_pows->{$_ } } @{$valves->{$k}} ];
    $all |= $i;
    $i *= 2;
}

my $max_mins = 26;
my $max_flow = $max_mins * $total_flow;
my $start = 'AA';

# Keep track of "least wasted" pressure in a state compared to the max pressure
# Dijkstra the least wasted pressure to find the minimum weight:
# - nodes are the state: (my loc, elephant loc, what's open, current flow, remaining time)
# - edges are the (total_flow - current_flow)
# Can't use my existing Dijkstra here because we need to compute
# neighbours on the fly

my $seen = {};
my $q = List::PriorityQueue->new();
my $start_state = [$valve_pows->{$start}, $valve_pows->{$start}, 0, 0, $max_mins];
$q->insert([$start_state, 0], 0);

while (my $c = $q->pop()) {
    my ($state, $dist) = @$c;
    
    if (done($state)) {
        my $least_wasted = $dist;
        say $max_flow - $least_wasted;
        exit;
    }

    next if ($seen->{state_key($state)});
    
    $seen->{state_key($state)} = 1;

    for my $n (neighbours($state)) {
        my ($ns, $nd) = @$n;
        next if $seen->{state_key($ns)};
        my $new_dist = $dist + $nd;
        $q->insert([$ns, $new_dist], $new_dist);
    }
}

# We're at an end node if the time remaining hits 0
sub done {
    my $state = shift;
    return $state->[-1] == 0;
}

# Get the neighbouring states for a given state and the edge costs
sub neighbours {
    my $s = shift;
    my ($me, $elephant, $open, $flow, $rem) = @$s;

    die "shouldn't be 0 remaining here" if $rem <= 0;

    if ($open == $all) {
        return ([[undef, undef, $open, $flow, $rem - 1], 0]);
    }

    my @moves = next_states($me, $open);
    my @emoves = next_states($elephant, $open);

    my @neighbour_states = ();
    for my $mm (@moves) {
        for my $em (@emoves) {
            my ($md, $mo, $mf) = @$mm;
            my ($ed, $eo, $ef) = @$em;
            my $new_opened = $open;

            $new_opened |= $mo if defined $mo;
            $new_opened |= $eo if defined $eo;

            my $new_flow = $flow + $mf + $ef;
            push @neighbour_states, [[
                $md, $ed, $new_opened, $new_flow, $rem - 1
            ], $total_flow - $flow]
        }
    }

    return @neighbour_states;
}

sub next_states {
    my ($pow, $open) = @_;

    my $flow_rate = $flow_pows->{$pow};
    my $tunnels = $next_pows->{$pow};

    my @states = ();
    if (($pow & $open) == 0 && $flow_rate > 0) {
        push @states, [$pow, $pow, $flow_rate]; 
    }

    for my $next (@$tunnels) {
        push @states, [$next, undef, 0];
    }

    return @states;
}

sub state_key {
    my $state = shift;
    return join $;, @$state;
}

