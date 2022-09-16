#!/usr/bin/perl
use strict;
use warnings;
my $file = "";
print "Please make a selection 1 or 2: ";
my $selection = <STDIN>;
chomp $selection;
if ($selection ne "1" | $selection ne "2") {
        print "selection must be 1 or 2";
        exit;
        }

if ($selection == 1) {
	$file = '/home/old_man/Discogs/ReleaseIDs.txt';
}

if ($selection == 2) {
	`grep "You are making requests too quickly" *.txt -l | sed 's/.txt//g' > reload.txt`;
	$file = '/home/old_man/Discogs/reload.txt';
}


open my $info, $file or die "Could not open $file: $!";

while( my $release_id = <$info>)  {   
        chomp($release_id);
	print "$release_id\n";
    	print `curl https://api.discogs.com/releases/$release_id --user-agent \"FooBarApp/3.0\" > $release_id.txt`;
    	sleep(10);
	}

    	close $info;
