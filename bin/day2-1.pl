#!/usr/bin/env perl
use Mojo::Base -strict;

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day2';
$file = "inputs/day2-$file" if $file =~ /test/;

my $scores = {
    'X' => 1,
    'Y' => 2,
    'Z' => 3,
};

my $wins = {
    'A' => 'Y',
    'B' => 'Z',
    'C' => 'X',
};

my $draws = {
    'A' => 'X',
    'B' => 'Y',
    'C' => 'Z',
};

open(my $fh, '<', $file) or die $!;
my $score = 0;
while (<$fh>) {
    chomp;
    my ($them, $us) = split / /;
    $score += $scores->{$us};
    $score += 6 if $wins->{$them} eq $us;
    $score += 3 if $draws->{$them} eq $us;
}

say $score;
