#!/usr/bin/perl -w
#
# display_comics : display comics for the given host.
#
# if given no options, this script will rsh to the default hosts in the @hosts
# list, giving itself as the option, the display.  Make sure you have .rhosts
# files setup right for the user you setup this script as a cronjob for.

use POSIX;

my $progname = "display_comics";
my $dir = "/var/spool/netcomics";
my $xv = "nice -19 xv";

#add to this list, all the hosts on which you want comics displayed
my @hosts = ("hobbes:0.0");

#execute script on proper machines w/ proper arguments
if (@ARGV == 0) {
    my $display;
    for $display (@hosts) {
	my $host = $1 if $display =~ /^([^:]+)/;
	system("rsh $host $progname $display &") if defined($host);
    }
    exit 0;
}

#display the requested images
chdir $dir;

#defaults
my $delaytime = 1080;   #delay of 18 minutes between comics
my @files = `ls *`;   #all of the comics
my $display = ":0.0"; #local display
my $cmd = $xv; #use XV by default. Changeable to a specific cmd 
if (@ARGV == 1) {
    $_ = shift(@ARGV);

    $display = $1 if /^(.*:\d\.\d)$/; #display it on the correct screen

    #example: don't use the loop below, but utilize the looping mechanism
    #         in xv instead. 
    if (/^(:\d\.\d)$/) {
	while (1) {
	    system("$xv -wait 20 -expand 1.8 -display $1 *");
	    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = 
		localtime(time);
	    exit(0) if ($hour == 3); #stop if it's 3am
	}
    }

    #example: the user @hobbes wants to have just Calvin & Hobbes, with
    #no delay inbetween (script exists immediately after displaying either
    #1 or 3 comics (3 if today is monday))
    if (/hobbes/) {
	@files = `ls Calvin*.gif`;
	$delaytime = 0;
    } 
    
    #example: Ben @hideyoshi or @eeyore wants the following comics, and
    #         wants them distributed over 6 hours.
    if (/(eeyore|hideyoshi)/) {
	@files = `ls Arlo_and_Janis* Beatle_Bailey* Blondie* Baby_Blues* Bizzaro* Calvin* Close_to_Home* Cornered* Dilbert* Garfield* Grin_and_Bear* Herman* Hi_and_Lois* JumpStart* Madam_and_Eve* Mutts* One_Big_Happy* On_The_Fastrack* Over_The_Hedge* Peanuts* Safe_Havens* Second_Chances* Shoe* The_Better_Half* The_Born_Loser* User_Friendly* Wiley* Zenon* Zits*`;
	#distribute the comics from now until 4:25pm
	my $time = time;
	my @ltime = localtime($time);
	my $stop_time = mktime(0,25,16,@ltime[3..6]);
	$delaytime = (($stop_time - $time)/@files); 
	$delaytime =~ s/(\d+).?\d*/$1/;  #make it a whole number
	#print "time = $time; stop = $stop_time; delaytime = $delaytime\n";
	#exit 0;
    }

    #display the images!
    if (@files > 0) {
	for $file (@files) {
	    my $syscmd = "$cmd -display $display $file";
	    if ($delaytime > 0) {
		my $pid;
		if (!defined($pid = fork)) {
		    die "cannot fork: $!";
		} elsif (! $pid) {
		    exec("$syscmd");
		}
		sleep $delaytime; 
	    } else {
		system("$syscmd");
	    }
	}
    }
}

