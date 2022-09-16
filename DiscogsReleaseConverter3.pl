#!/usr/bin/perl
use strict;
use warnings;
my $file ="";
my $output ="";
our $variousArtist = 0;
our $releaseID = 0;
use Term::ANSIColor qw(:constants);

my $filename = '/home/old_man/Discogs/DiscogsReleaseConverter.txt';

open(FH, '>', $filename) or die $!;

print "Please make a selection\n";
print GREEN, "1 ", RESET;
print "- convert all Discogs entries from this directory.\n";
print GREEN, "2 ", RESET;
print "- convert a specific Discogs release from this directory..\n";

my $selection = <STDIN>;
chomp $selection;
if (($selection ne "2") && ($selection ne "1"))   {
        print RED, "selection must be 1 or 2\n", RESET;
        exit;
        }

my @files = ();

if ($selection == 1) {
        @files = `ls *.txt -I "*Release*"`;
}

if ($selection == 2) {
        print "Please provide the id of the Discogs release:\n";
        my $discogsID = <STDIN>;
        chomp($discogsID);
        `echo $discogsID > ReleaseID3.txt`;
        @files = `ls $discogsID.txt -I "*Release*"`;
}

foreach $file ( @files ) {
		$releaseID = $file;
		$releaseID =~ s/.txt//;
		chomp($releaseID);
		chomp($file);
		print FH "$releaseID:FILE: $file\n";
		$output = `less $file | jq .title`; 
		chomp($output);
		print FH "$releaseID:TITLE: $output\n";
		$output = `less $file | jq .year`;
		chomp($output);
		print FH "$releaseID:YEAR: $output\n";
		$output = `less $file  | jq .artists | grep name | sed s/\\"name\\"://g | sed -e 's/^[ \t]*//' | rev | sed 's/^.//' | rev | sed -z 's/\\n/|/g;s/,\$/\\n/' | rev | sed 's/^.//' | rev`;
		chomp($output);
			
		if ($output eq "\"Various\"") {
			$variousArtist = 1;
		} else {
			$variousArtist = 0;
		}

		print FH "$releaseID:ARTIST: $output\n";
		$output = `less $file | jq '.tracklist[] | {title,position,artists}' | grep \"title\\|position\" | sed -e 's/^[ \\t]*//' | sed s/\\\"position\\\"://g | sed s/\\\"title\\\"://g | sed -z 's/\\n/|/g;s/,\$/\\n/' | sed 's/,|/|/g' | sed 's/| /|/g'`;
		chomp($output);
		print FH "$releaseID:TRACKS|BANDS: $output\n";
		if ($variousArtist != 0) {
			$output = `less $file | jq '.tracklist[] | {title,position,artists}' | grep 'position\\|name' | sed -e 's/^[ \\t]*//' | sed 's/"position": //g' | sed 's/"name": //g' | tr '",\\n' '"|' | sed 's/||/|/g'`;
			chomp($output);
			print FH "$releaseID:BANDS|ARTISTS: $output\n";
		}
		$output = `less $file | jq '.labels[] | {name,id}' | sed -e 's/^[ \\t]*//' | sed 's/{//g' | sed 's/}//g' | tr '\\n' ' '`;
	    chomp($output);
		print FH "$releaseID:LABEL: $output\n";
		$output = `less $file | jq '.formats[] |{descriptions}' | sed ':a;N;\$!ba;s/\\n/ /g' | sed 's/ //g' | sed 's/{\\"descriptions\\"\\://g' | sed 's/,/ /g' | sed 's/[^a-zA-Z0-9 ]//g' | sed 's/tedE/ted E/g' | sed 's/7/7\\"/g' | sed 's/12/12\\"/g' | sed 's/10/10\\"/g'`;
        chomp($output);
		print FH "$releaseID:FORMAT: $output\n";
		$output = `less $file | jq .styles | sed ':a;N;\$!ba;s/\\n/ /g' | sed 's/[^a-zA-Z0-9 ,]//g' | sed -e 's/^[ \\t]*//' | sed 's/  / /g'`;
		chomp($output);
		$output = $output.", ".`less $file | jq .genres | sed ':a;N;\$!ba;s/\\n/ /g' | sed 's/[^a-zA-Z0-9 ,]//g' | sed -e 's/^[ \\t]*//' | sed 's/  / /g'`;
		chomp($output);
                $output =~ s/\h+/ /g;
		$output =~ s/ , /, /g;
                print FH "$releaseID:STYLE: $output\n";
		}
