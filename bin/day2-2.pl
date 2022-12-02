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

my $lose = {
    'A' => 'Z',
    'B' => 'X',
    'C' => 'Y',
};

open(my $fh, '<', $file) or die $!;
my $score = 0;
while (<$fh>) {
    chomp;
    my ($them, $res) = split / /;

    $score += $scores->{$lose->{$them}} if $res eq 'X'; 
    
    if ($res eq 'Y') {
        $score += $scores->{$draws->{$them}};
        $score += 3;
    }
    
    if ($res eq 'Z') {
        $score += $scores->{$wins->{$them}};
        $score += 6;
    }
}

say $score;
