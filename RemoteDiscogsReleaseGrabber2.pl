#!/usr/bin/perl
use strict;
use warnings;
use Term::ANSIColor qw(:constants);

my $file = "";
print "Please make a selection\n";
print GREEN, "1 ", RESET;
print "- load all Discogs entries.\n";
print GREEN, "2 ", RESET;
print "- load any previous failures due to timeout.\n";
print GREEN, "3 ", RESET;
print "- load a specific Discogs release.\n";

my $selection = <STDIN>;
chomp $selection;
if (($selection ne "2") && ($selection ne "1") && ($selection ne "3"))   {
        print RED, "selection must be 1 or 2 or 3\n", RESET;
        exit;
        }

if ($selection == 1) {
	$file = '/home/old_man/Discogs/ReleaseIDs.txt';
}

if ($selection == 2) {
	`grep "You are making requests too quickly" *.txt -l | sed 's/.txt//g' > ReleaseID2.txt`;
	$file = '/home/old_man/Discogs/ReleaseID2.txt';
}
if ($selection == 3) {
	print "Please provide the id of the Discogs release:\n";
	my $discogsID = <STDIN>;
	chomp($discogsID);
        `echo $discogsID > ReleaseID3.txt`;
	$file = '/home/old_man/Discogs/ReleaseID3.txt';	
}

open my $info, $file or die "Could not open $file: $!";

while( my $release_id = <$info>)  {   
        chomp($release_id);
	print "$release_id\n";
    	print `curl https://api.discogs.com/releases/$release_id --user-agent \"FooBarApp/3.0\" > $release_id.txt`;
    	sleep(10);
	}

    	close $info;
