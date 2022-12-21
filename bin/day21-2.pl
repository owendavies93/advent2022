#!/usr/bin/env perl
use Mojo::Base -strict;

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day21';
$file = "inputs/day21-$file" if $file =~ /test/;
open(my $fh, '<', $file) or die $!;

my $consts = {};
my $exprs = {};

while (<$fh>) {
    chomp;
    if ($_ =~ /^(\w+): (\d+)$/) {
        $consts->{$1} = $2;
    } elsif ($_ =~ /^(\w+): (\w+) ([+\/\-*]) (\w+)$/) {
        $exprs->{$1} = [$2, $3, $4];
    }
}

my $lhs_root = $exprs->{'root'}->[0];
my $rhs_root = $exprs->{'root'}->[2];
my $rhs_val = eval_rec($rhs_root); # invariant in humn

#
# found by manual inspection:
# every 4000 that we increase hum_val, lhs decreases by 56415
# TODO this might not be quite right because the starting number is too low
# it's close though, found a better number with some manual fiddling
#
$consts->{'humn'} = 0;
my $lhs_val = eval_rec($lhs_root);
my $diff = $lhs_val - $rhs_val;
my $per4k = $diff / 56415;
$consts->{'humn'} = int(($per4k + 3085) * 4000);

while ($lhs_val != $rhs_val) {
    $consts->{'humn'}++;
    $lhs_val = eval_rec($lhs_root); 
}

say $consts->{'humn'};

sub eval_rec {
    my $token = shift;
    return $consts->{$token} if exists $consts->{$token};
    my $expr = $exprs->{$token};
    my $lhs = eval_rec($expr->[0]);
    my $rhs = eval_rec($expr->[2]);
    my $op = $expr->[1];
    return eval("$lhs $op $rhs");
}
