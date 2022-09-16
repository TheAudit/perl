#!/usr/bin/perl
use Algorithm::Permute;
my @array = '1'..'9';
my $p_iterator = Algorithm::Permute->new ( \@array );
my $counter = 1;
while (my @perm = $p_iterator->next) {
   print "@perm\n";
}

