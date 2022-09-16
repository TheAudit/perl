#!/usr/bin/perl
use Algorithm::Permute;
my @array = '1'..'9';
my $p_iterator = Algorithm::Permute->new ( \@array );
my $counter = 1;
my $counter2 = 1;
while (my @perm = $p_iterator->next) {
   my $out = join("",@perm);

   $counter2 = $counter2 +1;
   if (($perm[0] + $perm[1] + $perm[2]) != 15) {
        next;
   }
   if (($perm[3] + $perm[4] + $perm[5]) != 15) {
        next;
   }
   if (($perm[6] + $perm[7] + $perm[8]) != 15) {
        next;
   }
   if (($perm[0] + $perm[1] + $perm[2]) != 15) {
        next;
   }
   if (($perm[3] + $perm[4] + $perm[5]) != 15) {
        next;
   }
   if (($perm[0] + $perm[3] + $perm[6]) != 15) {
        next;
   }
   if (($perm[1] + $perm[4] + $perm[7]) != 15) {
        next;
   }
   if (($perm[2] + $perm[5] + $perm[8]) != 15) {
        next;
   }

   #print "$out\n";
   #print "next permutation: (@perm)\n";
   print "Solution $counter\n";
   print "------------\n";
   print "$perm[0] $perm[1] $perm[2]\n";
   print "$perm[3] $perm[4] $perm[5]\n";
   print "$perm[6] $perm[7] $perm[8]\n------------\n";
   $counter = $counter +1;
}

print "Total potential solutions: $counter2\n";
