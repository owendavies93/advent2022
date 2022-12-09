#!/usr/bin/env perl
use Mojo::Base -strict;

use Array::Utils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day9';
$file = "inputs/day9-$file" if $file =~ /test/;

my $dirs = {
     'U' => [0, 1],
     'L' => [-1, 0],
     'D' => [0, -1],
     'R' => [1, 0],
};
 
my @rope = map { [0, 0] } (0..2);
my $seen = {};
 
open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    my ($dir, $steps) = split / /;
 
    for (1..$steps) {
        $rope[0] = move($rope[0][0], $rope[0][1], $dirs->{$dir}); 

        for my $i (1..2) {
            if (too_far($rope[$i-1], $rope[$i])) {
                my $px = $rope[$i-1][0];
                my $py = $rope[$i-1][1];
                my $nx = $rope[$i][0];
                my $ny = $rope[$i][1];

                $nx += $px <=> $nx;
                $ny += $py <=> $ny;

                $rope[$i][0] = $nx;
                $rope[$i][1] = $ny;
            }
        }
 
        $seen->{$rope[1][0], $rope[1][1]} = 1;
    }
}
 
say scalar keys %$seen;

sub move {
    my ($x, $y, $dir) = @_;
    my ($dx, $dy) = @$dir;
    return [$x + $dx, $y + $dy];
}
 
sub too_far {
    my ($prev, $cur) = @_;
    return abs($prev->[0] - $cur->[0]) > 1 || abs($prev->[1] - $cur->[1]) > 1;
};
