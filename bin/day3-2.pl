#!/usr/bin/env perl
use Mojo::Base -strict;

use Array::Utils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day3';
$file = "inputs/day3-$file" if $file =~ /test/;
open(my $fh, '<', $file) or die $!;

my $total = 0;
my $count = 0;
my @p_chars = ();

while (<$fh>) {
    chomp;

    my @chars = split //, $_;
    @p_chars = scalar @p_chars == 0 ? @chars : intersect(@chars, @p_chars);

    $count++;

    if ($count > 2) {
        $count = 0;
        $total += pri($p_chars[0]);
        @p_chars = ();
    }
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

