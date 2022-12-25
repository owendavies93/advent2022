#!/usr/bin/env perl
use Mojo::Base -strict;

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day25';
$file = "inputs/day25-$file" if $file =~ /test/;

my $sum = 0;
open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    my $out;
    my $len = (length $_) - 1;
    for my $ch (split //, $_) {
        my $mul = 5 ** $len;
        if ($ch eq '=') {
            $out += (-2 * $mul);
        } elsif ($ch eq '-') {
            $out += (-1 * $mul);
        } else {
            $out += ($ch * $mul);
        }
        $len--;
    }
    $sum += $out;
}

my @out = ();
while ($sum) {
    my $mod = $sum % 5;
    unshift @out, (0, 1, 2, '=', '-')[$mod];
    $sum = int($sum / 5) + ($mod >= 3);
}
say join "", @out;
