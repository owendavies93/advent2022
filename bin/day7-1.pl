#!/usr/bin/env perl
use Mojo::Base -strict;

use List::AllUtils qw(:all);

my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day7';
$file = "inputs/day7-$file" if $file =~ /test/;

my $tree = {};
my $current_dir;
open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    if (/\$ cd (.*)$/) {
        if ($1 eq '/') {
            $current_dir = '/';
        } elsif ($1 eq '..') {
            $current_dir =~ s/[^\/]+\/$//;
        } else {
            $current_dir .= "$1/";
        }
    } elsif (/\$ ls$/) {
        next;
    } elsif (/^(\d+)/){
        push @{$tree->{$current_dir}->{files}}, $1;
    } elsif (/^dir (.*)$/) {
        my $child_dir = $current_dir . "$1/";
        push @{$tree->{$current_dir}->{children}}, $child_dir;
    }
}

my $total = 0;
for my $dir (keys %$tree) {
    my $size = dir_size($dir);
    $total += $size if $size <= 100000; 
}

say $total;

sub dir_size {
    my $dir = shift;

    my $total = (sum @{$tree->{$dir}->{files}}) // 0;
    if (!defined $tree->{$dir}->{children}) {
        return $total;
    }

    return $total + sum map { dir_size($_) } @{$tree->{$dir}->{children}};
}
