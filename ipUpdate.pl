#!/usr/bin/perl

my $ipExternalCheck = "";
my $ipCurrent = "";
$ipExternalCheck = `wget http://ipecho.net/plain -O - -q`;
print "ip check: $ipExternalCheck\n";

open(DATA, "/home/wilbur/CodeProjects/txt/ipAddress.txt") or die "Couldn't open file file.txt, $!";

while(<DATA>) {
   $ipCurrent = $_;
}

print "ip current: $ipCurrent\n";

if ($ipCurrent ne $ipExternalCheck) {
    print `cp /home/wilbur/CodeProjects/txt/index.tmpl.txt /home/wilbur/CodeProjects/txt/index.txt`;
    print `sed -i 's/####/$ipExternalCheck/g' /home/wilbur/CodeProjects/txt/index.txt`;
}
