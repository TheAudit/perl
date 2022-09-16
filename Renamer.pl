#!/usr/bin/perl
use warnings;
use Cwd;

my $cwd = getcwd();
print `clear`;
print "Rename to\n<1> \{Track Number\} \{Track Title\}\n<2> \{Artist\}|\{Track Title\} \n:";
	my 	$UserInput = "";
	$UserInput = <>;

our $artist = "";
our $title = "";
our $track = "";

opendir my $dir, "$cwd" or die "Cannot open directory: $!";
my @files = readdir $dir;
closedir $dir;

my $file = "";

foreach $file (@files) {
    if (index($file,".mp3") == -1) {
        next;
    }
    my @tagTypes = ("artist", "title", "track");
    my $tagType = "";
    foreach $tagType (@tagTypes ) {
       # print "value of file: $file\n";
       # print "value of tag: $tagType\n";
        if ($tagType eq "artist") {
            $artist = `eyeD3 \"$file\" | grep $tagType | sed \'s\/$tagType: \/\/g\'`;
            chomp($artist);
           # print "$artist\n";
        }
        if ($tagType eq "title") {
            $title = `eyeD3 \"$file\" | grep $tagType | sed \'s\/$tagType: \/\/g\'`;
           # print "$title\n";
            chomp($title);
            $title =~ s/(.*?)\t/$1/g;
        }
        if ($tagType eq "track") {
            $track = `eyeD3 \"$file\" | grep $tagType | sed \'s\/$tagType: \/\/g\'`;
           # print "$track\n";
            chomp($track);
            $track =~ s/(.*?)\t/$1/g;
            if ($track < 10) {
                $track = "0$track";
            }
        }
    
    }

    if ($UserInput == 1) {
        print `mv \"$file\" \"$track $title.mp3\"`;
    }
    
    if ($UserInput == 2) {
        print `mv \"$file\" \"$artist|$title.mp3\"`;
    }

}
