#!/usr/bin/perl
use strict;
use warnings;
my $file ="";
my $output ="";
use Term::ANSIColor qw(:constants);

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
		chomp($file);
		print "FILE2 : $file\n";
		$output = `less $file | jq .title`; 
		chomp($output);
		print "TITLE: $output\n";
		$output = `less $file | jq .year`;
		chomp($output);
		print "YEAR: $output\n";
		$output = `less $file  | jq .artists | grep name | sed s/\\"name\\"://g | sed -e 's/^[ \t]*//' | rev | sed 's/^.//' | rev | sed -z 's/\\n/|/g;s/,\$/\\n/' | rev | sed 's/^.//' | rev`;
		chomp($output);
		print "ARTIST: $output\n";
		$output = `less $file | jq '.tracklist[] | {title,position,artists}' | grep \"title\\|position\" | sed -e 's/^[ \\t]*//' | sed s/\\\"position\\\"://g | sed s/\\\"title\\\"://g | sed -z 's/\\n/|/g;s/,\$/\\n/' | sed 's/,|/|/g' | sed 's/| /|/g'`;
		chomp($output);
		print "TRACKS|BANDS: $output\n";
	        $output = `less $file | jq '.formats[] |{descriptions}' | sed ':a;N;\$!ba;s/\\n/ /g' | sed 's/ //g' | sed 's/{\\"descriptions\\"\\://g' | sed 's/,/ /g' | sed 's/[^a-zA-Z0-9 ]//g' | sed 's/tedE/ted E/g' | sed 's/7/7\\"/g' | sed 's/12/12\\"/g' | sed 's/10/10\\"/g'`;
                chomp($output);
		print "FORMAT: $output\n";
		$output = `less $file | jq .styles | sed ':a;N;\$!ba;s/\\n/ /g' | sed 's/[^a-zA-Z0-9 ,]//g' | sed -e 's/^[ \\t]*//' | sed 's/  / /g'`;
		chomp($output);
		$output = $output.", ".`less $file | jq .genres | sed ':a;N;\$!ba;s/\\n/ /g' | sed 's/[^a-zA-Z0-9 ,]//g' | sed -e 's/^[ \\t]*//' | sed 's/  / /g'`;
		chomp($output);
                $output =~ s/\h+/ /g;
		$output =~ s/ , /, /g;
                print "STYLE: $output\n";
		}
