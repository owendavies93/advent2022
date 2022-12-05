#!/usr/bin/env perl
use Mojo::Base -strict;

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day5';
$file = "inputs/day5-$file" if $file =~ /test/;

my $stacks = [
    [],
    ['Z','N'],
    ['M','C','D'],
    ['P'],
];

if ($file !~ /test/) {
    $stacks = [
        [],
        ['W','B','D','N','C','F','J'],
        ['P','Z','V','Q','L','S','T'],
        ['P','Z','B','G','J','T'],
        ['D','T','L','J','Z','B','H','C'],
        ['G','V','B','J','S'],
        ['P','S','Q'],
        ['B','V','D','F','L','M','P','N'],
        ['P','S','M','F','B','D','L','R'],
        ['V','D','T','R'],
    ];
}

open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    my ($num, $from, $to) = $_ =~ /(\d+) from (\d) to (\d)/;
    my @removed = splice @{$stacks->[$from]}, $num * -1;
    push @{$stacks->[$to]}, @removed;
}

say map { $_->[-1] // '' } @$stacks;
