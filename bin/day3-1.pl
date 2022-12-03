#!/usr/bin/env perl
use Mojo::Base -strict;

use Array::Utils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day3';
$file = "inputs/day3-$file" if $file =~ /test/;
open(my $fh, '<', $file) or die $!;

my $total = 0;

while (<$fh>) {
    chomp;
    my $l = length;
    my @f = split //, (substr $_, 0, $l / 2);
    my @s = split //, (substr $_, $l / 2);

    my @pri_chars = intersect(@f, @s);
    $total += pri($pri_chars[0]);
}

say $total;

sub pri {
    my $char = shift;
    if ($char le 'Z') {
        return 1 + ord($char) - ord('A') + 26;
    } else {
        return 1 + ord($char) - ord('a');
    }
}

