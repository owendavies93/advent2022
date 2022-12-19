#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Utils::Input qw(get_ints);

use List::AllUtils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day19';
$file = "inputs/day19-$file" if $file =~ /test/;

my $blueprints = {};
open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    my ($id, $ore_cost, $clay_cost, $obs_cost_ore, $obs_cost_clay, $geo_cost_ore, $geo_cost_obs) = get_ints($_); 
    $blueprints->{$id} = {
        ore_cost => $ore_cost,
        clay_cost => $clay_cost,
        obs_cost_ore => $obs_cost_ore,
        obs_cost_clay => $obs_cost_clay,
        geo_cost_ore => $geo_cost_ore,
        geo_cost_obs => $geo_cost_obs,
    };
}

sub run {
    my ($rem_mins, $opts, $state) = @_;

    # Don't need to track the geode bots in the state because the return
    # value is the sum of the created geode bots at each minute
    my ($ore, $clay, $obs, $ore_bots, $clay_bots, $obs_bots) = @$state;

    return 0 if $rem_mins <= 0;

    my $next_min  = $rem_mins - 1;
    my $next_ore = $ore + $ore_bots;
    my $next_clay = $clay + $clay_bots;
    my $next_obs  = $obs  + $obs_bots;

    my $geodes = 0;

    # Build a geode bot if we can
    if ($ore >= $opts->{geo_cost_ore} && $obs >= $opts->{geo_cost_obs}) {
        $geodes = max($geodes, $next_min + run(
            $next_min, $opts, [$next_ore - $opts->{geo_cost_ore}, $next_clay,
            $next_obs - $opts->{geo_cost_obs}, $ore_bots, $clay_bots, $obs_bots]
        ));
    # Build a obs bot if we can't build a geode bot
    } elsif ($ore >= $opts->{obs_cost_ore} && $clay >= $opts->{obs_cost_clay}) {
        $geodes = max($geodes, run(
            $next_min, $opts, [$next_ore - $opts->{obs_cost_ore},
            $next_clay - $opts->{obs_cost_clay}, $next_obs, $ore_bots,
            $clay_bots, $obs_bots + 1]
        ));
    } else {
        if ($ore >= $opts->{clay_cost}) {
            $geodes = max($geodes, run(
                $next_min, $opts, [$next_ore - $opts->{clay_cost}, $next_clay,
                $next_obs, $ore_bots, $clay_bots + 1, $obs_bots]
            ));
        }
        if ($ore >= $opts->{ore_cost}) {
            $geodes = max($geodes, run(
                $next_min, $opts, [$next_ore - $opts->{ore_cost}, $next_clay,
                $next_obs, $ore_bots + 1, $clay_bots, $obs_bots]
            ));
        }
    }
    if ($ore < $opts->{geo_cost_ore} || $ore < $opts->{obs_cost_ore} ||
        $ore < $opts->{clay_cost} || $ore < $opts->{ore_cost}) {
        $geodes = max($geodes, run(
            $next_min, $opts, [$next_ore, $next_clay, $next_obs, $ore_bots,
            $clay_bots, $obs_bots]
        ));
    }

    return $geodes;
}

my $total = 0;
for my $b (sort { $a <=> $b } keys %$blueprints) {
    my $geodes = run(24, $blueprints->{$b}, [0, 0, 0, 1, 0, 0]);
    $total += $geodes * $b;
}

say $total;
