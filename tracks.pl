#!/usr/bin/perl
use Digest::MD5 qw(md5_hex);
use Getopt::Std;
     getopts('u:'); 
our($opt_u);
our $artistLocation1 = "";
our $nameLocation1 = "";
our $sqlconn     = "-uold_man -precords";
my $db_name     = "tool";

my $var = $opt_u;

our $md5_hash = md5_hex($var);
$md5_hash= "$opt_u|$md5_hash";

     #print "$opt_u\n";
     print `curl $opt_u  -o DTRCKL.txt ; sed -i \'s\/table\/\\ntable\/g\' DTRCKL.txt \; tail -2 DTRCKL\.txt | head -1 > tracks\.txt; sed -i 's\/\<tr\\>\/\\n\<tr\\>\/g' tracks\.txt;`;
     #print "wget $opt_u  -O DTRCKL.txt ; sed -i \'s\/table\/\\ntable\/g\' DTRCKL.txt \; tail -2 DTRCKL\.txt | head -1 > tracks\.txt; sed -i 's\/\<tr\\>\/\\n\<tr\\>\/g' tracks\.txt;";
    my $filename = 'DTRCKL.txt';
    open(my $fh,, $filename)
      or die "Could not open file '$filename' $!";
     my $i = 1;
    while (my $row = <$fh>) {
      chomp $row;
      if ($i==1) {
           $nameLocation1 = substr ($row, index($row, "\"name\"")+8, 250);
           $nameLocation1 = substr ($nameLocation1, 0, index($nameLocation1, "\""));
          print "$md5_hash|0|Title|$nameLocation1|-|-\n";

          $artistLocation1 = substr ($row, index($row, "\/artist\/")+8, 250);
          $artistLocation1 = substr ($artistLocation1, 0, index($artistLocation1, "\"}"));
          $artistLocation1 = substr($artistLocation1, rindex($artistLocation1,"\"")+1 ,length($artistLocation1)-rindex($artistLocation1,"\"")-1);
          print "$md5_hash|-1|Artist|$artistLocation1|-|-\n";
          #print "\n$row\n";
      }
      $i++;
    }

    close $fh;
    
    $filename = 'tracks.txt';
    open($fh,, $filename)
      or die "Could not open file '$filename' $!";
     $i = 1;
    while (my $row = <$fh>) {
      chomp $row;
      my $loc = index($row, "position");
      if ($loc != -1) {
      print "$md5_hash|$i|";
      #Get the band - A1, A2, ... , An, B1, B2, ... Bn
      my $leftSubstringOfBand = substr ($row, index($row, "position"), 23);
      my $rightSubstringOfBand = substr ($leftSubstringOfBand, index($leftSubstringOfBand, "\"")+1, 23);
      my $locationOfSpeechMark = index($rightSubstringOfBand,"\"");
      my $band = substr($rightSubstringOfBand,0,$locationOfSpeechMark);
      print $band; 
      print "|";
      #Get the track title
      my $containsTitle  = substr ($row,index($row, "trackTitle"),230);
      $containsTitle = substr($containsTitle, 0,-1+index($containsTitle,"/span"));
      $containsTitle = substr($containsTitle, rindex($containsTitle,">")+1 ,length($containsTitle)-rindex($containsTitle,">")-1);
      $containsTitle =~ s/&#x27;/'/g;
       $containsTitle =~ s/&quot;/"/g;
      print $containsTitle;
      if ($artistLocation1 ne "Various") {
              print "|$artistLocation1";
      } else {
          my $artistName  = substr ($row,0,rindex($row, "trackTitle"));
          $artistName = substr($artistName, 0,-5+index($artistName,"/span"));
          $artistName = substr($artistName, rindex($artistName,">")+1,length($artistName)-rindex($artistName,">"));
          $artistName =~ s/<//g;
          print "|$artistName";
      }
      print "|$nameLocation1\n";
      
      $i++;
      }    
#print "\n******$loc\n";
    } 