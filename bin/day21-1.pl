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

say eval_rec('root');

sub eval_rec {
    my $token = shift;
    return $consts->{$token} if exists $consts->{$token};
    my $expr = $exprs->{$token};
    my $lhs = eval_rec($expr->[0]);
    my $rhs = eval_rec($expr->[2]);
    my $op = $expr->[1];
    return eval("$lhs $op $rhs");
}
