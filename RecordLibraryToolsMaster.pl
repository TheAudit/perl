#!/usr/bin/perl
use strict;
use warnings;
use POSIX;

my $working_dir = "/etc/music_player_load";
my $endfilename = "$working_dir/RecordLibraryToolsMaster.end";
my $runfilename = "$working_dir/RecordLibraryToolsMaster.running";
my $c           = 0;
my $sqlconn     = "-uold_man -precords";
my $db_name     = "tool";
my $ToolRunID   = 0;
my $stepCount   = 0;
my $OutputForDbInsert = "";
my $usage_dir   ="$working_dir/usage";
my $uid         ="RecordLibraryTM";
my $fc          ="";


#First check if there is a running instance if there is stop.
if ( -e $runfilename ) {
    exit;
}

#Only need to run this if Edit mode has been enabled
#This is set in the table ToolSwitchOn, 
    #if the value of field ToolSwitchOn is 1 => this script should continue to run
    #if the value of field ToolSwitchOn is 0 => exit

my $SQL = "SELECT ToolSwitchOn FROM ToolSwitchOn;";
&run_MySQL_Statement_Output($SQL);
my $isToolSwitchedOn = GetFileContents();
if ($isToolSwitchedOn==0) {
    exit;
} else {
    &run_MySQL_Statement(
    "UPDATE tool.ToolSwitchOn SET ToolSwitchOn = 2;");
}

#On start up delete any old stop file.
if ( -e $endfilename ) {
    print `rm $endfilename`;
}
#Create a running file to show that the process is up
print `touch $runfilename`;
print "hi \n";

#Continuously loop until the end file is present
while (42) {
    sleep(1);
    $c = $c + 1;
    &run_MySQL_Statement_Output_To_File(
        "CALL getToolMasterIDAndToolRunIDToRun\(\)\;:Check.txt");

    open my $info, "Check.txt" or die "Could not open Check.txt : $!";
    while ( my $line = <$info> ) {
        chomp($line);
        my @getToolIDs   = split( /\|/, $line );
        my $ToolMasterID = $getToolIDs[0];
           $ToolRunID    = $getToolIDs[1];
        if ( $ToolMasterID != 0 ) {
            ;
	    &run_MySQL_Statement(
                "TRUNCATE TABLE ActiveTool;INSERT INTO ActiveTool (ToolRunID) VALUES ($ToolRunID);");	
            print "\n###############\nTOOL  ACTIVATED\nRun: $ToolRunID\n###############\n";
			print "Checking\n...............\n";
			print "CALL getToolRunCode\($ToolRunID\)\n";
            &run_MySQL_Statement_Output_To_File(
                "CALL getToolRunCode\($ToolRunID\)\;:Steps.txt");
			&run_MySQL_Statement(
			#Need to add a condition here to prevent this from updating if there are subsequent tool runs in ToolCheck!	
				"UPDATE ToolCheck SET RunTS = NOW() WHERE ToolMasterID = 0 AND ToolRunID = 0;");
			print "...............\nChecked\n...............\n";
            open my $steps, "Steps.txt" or die "Could not open Steps.txt : $!";
            chomp( my @codesteps = <$steps> );
            close $steps;
            foreach (@codesteps) {
                $stepCount = $stepCount + 1;  
                my $step = substr( $_, 3 - length );
                my $lang = substr( $_, 0, 3 );
                
                if ($lang eq "SQL") { 
				print "SQL $step\n";
                &run_Shell_Statement("mysql  $sqlconn -e\"$step\" $db_name");
                }
                
                if ($lang eq "BSH") {
                print "SHELL: $step\n";
				&run_Shell_Statement($step);
                }

            }
            
        $stepCount = 0;
		print "WAIT: 1 Second\n";
		sleep(1);
		print "\n###############\nTOOL  COMPLETED\nRun: $ToolRunID\n###############\n";
                &run_MySQL_Statement(
                "DELETE FROM ActiveTool WHERE 1=1;"); 
                &run_MySQL_Statement(
                "UPDATE ToolRun SET Completed = 1 WHERE ToolRunID=$ToolRunID;"); 
        }

        if ( $c / 300 == floor( $c / 300 ) ) {
            &run_MySQL_Statement(
                "UPDATE ToolUp SET LastUpdated = NOW() WHERE ID = 1;");
                print ".";
        }
    }

    if ( -e $endfilename ) {
        print "bye\n";
        print `rm $endfilename`;
        print `rm $runfilename`;
	&run_MySQL_Statement(
		    "UPDATE tool.ToolSwitchOn SET ToolSwitchOn = 0;");
        exit;
    }
}

sub run_MySQL_Statement {
    my ($STATEMENT) = @_;
    my $cmd = "";

    $cmd = "$cmd mysql  $sqlconn -e\"$STATEMENT\" $db_name";

    my $result = print `$cmd`;
    my $logcmd = "";
    $cmd =~ s/(.)/sprintf("%x",ord($1))/eg;
    #"mysql  $sqlconn -e\"INSERT INTO ToolLog (ToolRunID, Log, SuccessStatus) VALUES ($ToolRunID , '$cmd', $result)\" $db_name";

}

sub run_MySQL_Statement_Output_To_File {
    my ($STATEMENT_FILE) = @_;
    my @STTMNT_FILE = split( /:/, $STATEMENT_FILE );
    my $STATEMENT = $STTMNT_FILE[0];
    my $FILE = $STTMNT_FILE[1];
    my $cmd = "";
    $cmd = "$cmd mysql $sqlconn -N -e\"$STATEMENT\" $db_name > $FILE";

    my $result = print `$cmd`;

}

sub run_Shell_Statement {
    my ($STATEMENT) = @_;
    my $cmd = "";

    $cmd = $STATEMENT;
    print `$cmd`;
    my $logcmd = "";
}

sub run_MySQL_Statement_Output {
    my $fileToDelete = "$usage_dir/rs.$uid.data";
    unlink($fileToDelete);
    my ($STATEMENT) = @_;
    my $cmd = "";
    my $result = "";
    #run statement and output to temp file
    $cmd = "$cmd mysql  $sqlconn -e\"$STATEMENT\" $db_name > $usage_dir/temp.rs";
    $result = print `$cmd`;
    #remove header create rs.data (record set data)
    $cmd = "";
    $cmd = "$cmd tail -n +2 $usage_dir/temp.rs > $usage_dir/rs.$uid.data";
    $result = print `$cmd`;
    #clean up temp file
    $cmd = "";
    $cmd = "$cmd rm $usage_dir/temp.rs";
    $result = print `$cmd`;
}

sub GetFileContents {
        $fc = "";
        open(FH, '<', "$usage_dir/rs.$uid.data") or die $!;

        while(<FH>){
        $fc .= $_;
        }

        close(FH);
        chomp($fc);     
        # Return Value     
        return($fc); 
}




