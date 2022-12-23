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
# we can just use linear interpolation to find the answer since the
# equation for root is linear
#
$consts->{'humn'} = 0;
my $zero = eval_rec($lhs_root);
$consts->{'humn'} = 1;
my $diff = eval_rec($lhs_root) - $zero;

my $answer = ($rhs_val - $zero) / $diff;
say int($answer + 0.5);

sub eval_rec {
    my $token = shift;
    return $consts->{$token} if exists $consts->{$token};
    my $expr = $exprs->{$token};
    my $lhs = eval_rec($expr->[0]);
    my $rhs = eval_rec($expr->[2]);
    my $op = $expr->[1];
    return eval("$lhs $op $rhs");
}
