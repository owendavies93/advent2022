#!/usr/bin/env perl
use Mojo::Base -strict;

use lib "../cheatsheet/lib";

use Advent::Grid::Dense::Square;
use Advent::Utils::Input qw(get_ints);

use List::AllUtils qw(:all);

my @DIRS = qw(N E S W);

my $rot = {
    R => sub {
        my $dir = shift;
        my $i = first_index { $_ eq $dir } @DIRS;
        return $DIRS[($i + 1) % @DIRS];
    },
    L => sub {
        my $dir = shift;
        my $i = first_index { $_ eq $dir } @DIRS;
        return $DIRS[($i - 1) % @DIRS];
    }
};

my $move = {
    N => [ 0, -1],
    E => [ 1,  0],
    S => [ 0,  1],
    W => [-1,  0],
};
    
my $file = defined $ARGV[0] ? $ARGV[0] : 'inputs/day22';
$file = "inputs/day22-$file" if $file =~ /test/;

my $temp_grid;
my $width = 0;
my $height = 0;
my $grid_done = 0;
my @insts;
open(my $fh, '<', $file) or die $!;
while (<$fh>) {
    chomp;
    
    if (!$_) {
        $grid_done = 1;
    }

    if ($grid_done) {
        my @numbers = get_ints($_);
        my @letters = $_ =~ /([RL])/g;
        @insts = zip @numbers, @letters;
    } else {
        $temp_grid .= ($_ . "\n");
        $width = length $_ if $width < length $_;
        $height++;
    }
}

my $move_index = {
    N => $width * -1,
    E => 1,
    S => $width,
    W => -1,
};

my @split = split /\n/, $temp_grid;
my @grid;
for my $line (@split) {
    if (length $line < $width) {
        $line .= ' ' x ($width - length $line);
    }
    push @grid, split //, $line;
}

my $g = Advent::Grid::Dense::Square->new({
    grid  => \@grid,
    width => $width,
});

my $dir = 'E';
my $x = first_index { $_ eq '.' } @grid;
my $y = 0;

for my $inst (@insts) {
    last if !defined $inst;
    
    if ($inst =~ /[RL]/) {
        # rotate
        $dir = $rot->{$inst}->($dir);
    } else {
        # move
        while ($inst > 0) {
            my ($nx, $ny) = next_pos($x, $y, $dir);
            last if $x == $nx && $y == $ny;
            $x = $nx;
            $y = $ny;
            $inst--;
        }
    }
}

my $facing_score = first_index { $_ eq $dir } @DIRS;
$facing_score = ($facing_score - 1) % @DIRS;
my $password = (1000 * ($y + 1)) + (4 * ($x + 1)) + $facing_score;
say $password;

sub next_pos {
    my ($x, $y, $dir) = @_;

    my $v = val_from_coord($x, $y, $dir);

    # wrap if we hit air
    return wrap($x, $y) if !defined $v;

    # return the same pos if we're at a wall
    return ($x, $y) if $v eq '#';
    
    if ($v eq '.') {
        my ($dx, $dy) = @{$move->{$dir}};
        # return the next pos if we're at a space
        return ($x + $dx, $y + $dy);
    }

    my $oldx = $x;
    my $oldy = $y;
    ($x, $y) = wrap($x, $y, $dir); 
    $v = val_from_coord($x, $y, $dir);

    # return the old pos if we're still at a wall
    return ($oldx, $oldy) if $v eq '#';

    # else return the wrapped pos
    return ($x, $y);
}

sub val_from_coord {
    my ($x, $y, $dir) = @_;
    my $i = $y * $width + $x;
    my @adj = ($i - $width, $i + 1, $i + $width, $i - 1);

    my $dir_idx = first_index { $_ eq $dir } @DIRS;
    my $idx = $adj[$dir_idx];
    return $g->get_at_index($idx);
}

sub wrap {
    my ($x, $y, $dir) = @_;

    # hard code the faces!
    # Also need to calculate the direction changes, but again perhaps we
    # simply hard code these
    # map from (x, y, dir) -> (x, y, dir) where one of x, y is always fixed
    # and there's only ever one valid dir because you can only leave in one
    # direction

    if ($x == 49 && $y >= 150 && $y <= 199 && $dir eq 'E') {
        $y = 149;
        $x = $y - 100;
        $dir = 'N'
    } elsif ($y == 149 && $x >= 50 && $x <= 99 && $dir eq 'S') {
        $x = 49;
        $y = $x + 100;
        $dir = 'W'
    }
    
    elsif ($x == 99 && $y >= 100 && $y <= 149 && $dir eq 'E') {
        $x = 149;
        $y = 149 - $y;
        $dir = 'W';
    } elsif ($x == 149 && $y <= 49 && $dir eq 'E') {
        $x = 99;
        $y = 149 - $y;
        $dir = 'W';
    }
    
    elsif ($x == 99 && $y >= 50 && $y <= 99 && $dir eq 'E') {
        $y = 49;
        $x = $y + 50;
        $dir = 'N';
    } elsif ($y == 49 && $x >= 100 && $dir eq 'S') {
        $x = 99;
        $y = $x - 50;
        $dir = 'W';
    }
    
    elsif ($y == 0 && $x >= 100 && $dir eq 'N') {
        $y = 199;
        $x -= 100;
        $dir = 'N';
    } elsif ($y == 199 && $x <= 49 && $dir eq 'S') {
        $y = 0;
        $x += 100;
        $dir = 'S';
    }
    
    elsif ($y == 0 && $x >= 50 && $x <= 99 && $dir eq 'N') {
        $x = 0;
        $y = $x + 100;
        $dir = 'E';
    } elsif ($x == 0 && $y >= 150 && $dir eq 'W') {
        $y = 0;
        $x = $y - 100;
        $dir = 'S';
    }
    
    elsif ($x == 50 && $y <= 49 && $dir eq 'W') {
        $x = 0;
        $y = 149 - $y;
        $dir = 'E';
    } elsif ($x == 0 && $y >= 100 && $y <= 149 && $dir eq 'W') {
        $x = 50;
        $y = 149 - $y;
        $dir = 'E';
    }
    
    elsif ($x == 50 && $y >= 50 && $y <= 99 && $dir eq 'W') {
        $y = 100;
        $x = $y - 50;
        $dir = 'S';
    } elsif ($y == 100 && $x <= 49 && $dir eq 'N') {
        $x = 50;
        $y = $x + 50;
        $dir = 'E';
    }

    return ($x, $y, $dir);
}

