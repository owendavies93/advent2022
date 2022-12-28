#!/usr/bin/env perl
use Mojo::Base -strict;

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day5';
$file = "inputs/day5-$file" if $file =~ /test/;

my $stacks = [[]];

open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;

    if (substr($_, 0, 1) ne 'm') {
        my $i = 1;
        my @line = split //, $_;
        while (my $c = $line[$i]) {
            if ($c =~ /[A-Z]/) {
                my $stack_idx = (($i - 1) / 4) + 1;
                unshift @{$stacks->[$stack_idx]}, $c;
            }
            $i++;
        }
    } else {
        my ($num, $from, $to) = $_ =~ /(\d+) from (\d) to (\d)/;
        next if !defined $num;
        my @removed = splice @{$stacks->[$from]}, $num * -1;
        push @{$stacks->[$to]}, @removed;
    }
}

say map { $_->[-1] // '' } @$stacks;
