#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Term::ANSIColor;

# These variables are only used if your are using the old gcc flow for dpi code
# I.e. not using dpiheader.h

use constant CLIBS_DIR        => "./c_libs";
use constant OBJLINK_COMMAND  => "g++";
use constant OBJLINK_OPTIONS  => "-shared -lm -Wl,-Bsymbolic -Wl,-export-dynamic -Wl,-rpath,".CLIBS_DIR;

my $ldflags=OBJLINK_OPTIONS;
my $usegcc=0;
my $cflags="";
my $fltfile="";
my $verbose=0;
my $vlogargs="";
my $vcomargs="";
my $default_lib="";
my $library_home="questa_libs";
my $arch="32";
my $gcc_version="4.3.3";

# Let's find out the path to vmap
# Since we can use any variable for questa we do the following

my $model_tech_path=$ENV{"QUESTASIM_HOME"};


sub infomsg{
    my $s = pop;
    print color 'bold dark blue';
    print "Note: $s\n";
    print color 'reset';
}



sub compile_file{
    my $lib=pop;
    my $file = pop;
    my $args="";
    my @f;
    my $cmd;
    my $type="";
    my $tmp;

    my @vmap=`vmap|grep "maps to"|grep -v $model_tech_path|cut -d" " -f1|sed s/\\"/-L\\ /|sed s/\\"//g`;
    chomp @vmap;
    my $mapped_libs=join " ",@vmap;

    if ($file =~ /:/) {
	my @line=split ":",$file;
	@f = split",",$line[0];
	$args = $line[1];
    } else {
	push @f ,$file;    
    }

    # $f might contain many files:
    my @flist=split " ",$f[0];
    

    # ###############################################################
    # This is only valid if we have a library:
    # Check if this is a VHDL file
    # First of all. We will use the first file to decide file type
    # Then we will check if we have conflicting types
    # ###############################################################
    if (($flist[0] =~ /\.vhd$/)|($flist[0] =~ /\.vhdl$/)) {
	    $type="vhdl";
    } elsif (($flist[0] =~ /\.sv$/)|($flist[0] =~ /\.v$/)|($flist[0] =~ /\.svh$/)) {
	$type="verilog";

    } elsif (($flist[0] =~ /\.c$/)|($flist[0] =~ /\.cpp$/)) {
	$type="c"; 
    } else {
	&infomsg("Unknown filetype:$flist[0]");
	exit(1);
    }

    # Next step is to compile the code
    $tmp = join " ",@f;
#    print "DEBUG:$args\n";
    if ($type eq "vhdl") {
	$cmd = "vcom -$arch -work $lib $tmp $args $vcomargs";
	&infomsg("Launching: $cmd");
	&system_cmd_hl($cmd);

    } elsif ($type eq "verilog") {
	$cmd = "vlog -$arch -work $lib $tmp $args $vlogargs $mapped_libs";

	&infomsg("Launching: $cmd");
	&system_cmd_hl($cmd);
    } elsif ($type eq "c") {
	if ($usegcc) {
	    my @x=split "/",$tmp;
	    my $basename = pop @x;
	    &infomsg("####################################################################################################");
	    &infomsg("Using old way of compililing and linking c-code. Please refer to DPI Use Flow in Questa Users manual");
	    &infomsg("####################################################################################################");

	    &system_cmd("test -e c_libs/$lib||mkdir -p c_libs/$lib");
	    $cmd="gcc -m$arch $args $cflags $tmp -o ./c_libs/$lib/$basename".".o";
	    &infomsg("Launching: $cmd");
	    &system_cmd($cmd);
	    $cmd="g++ -m$arch $ldflags `find ./c_libs/$lib/ -name *.o -print` -o ./c_libs/$lib".".so";
	    &infomsg("Launching: $cmd");
	    &system_cmd($cmd);
	    

	} else {
	$cmd = "vlog -$arch -work $lib $tmp -ccflags \"$args $cflags\" -dpicppinstall $gcc_version -";
	&infomsg("Launching: $cmd");
	&system_cmd_hl($cmd);
	}


    } else {
	&infomsg("Unknown filetype:$type");
	exit(1);

    }



} 
 

GetOptions ("cflags=s" => \$cflags,    # numeric
	    "file=s"   => \$fltfile,      # string
	    "vlogargs=s" => \$vlogargs,
	    "vcomargs=s" => \$vcomargs,
	    "default_lib=s" => \$default_lib,
	    "arch=s"  => \$arch,
	    "usegcc"  => \$usegcc,
	    "ldflags=s" => \$ldflags,
	    "gccversion=s" => \$gcc_version,
	    "verbose"  => \$verbose)   # flag
    or die("Error in command line arguments\n");




&infomsg("Parsing $fltfile");
open(FHIN, "<", $fltfile) 
    or die "cannot open $fltfile\n";
# First remove all lines starting with "#"

my @indata=<FHIN>;
chomp @indata;
my @tmp;
foreach my $l (@indata) {
    if (($l =~/^\#/)|($l =~ /^$/)) {
#	print "DBG:skipping $l\n";
    } else {
	push @tmp,$l;
    }
}

@indata=@tmp;
my $lib=$default_lib;


foreach my $f (@indata) {
    if ($f =~ /^\@library/ ) {
	my @line=split " ",$f;
	$lib=pop @line;
	&infomsg("Creating library $lib if does not exists");
	my $cmd="test -e $library_home||mkdir $library_home";
	&system_cmd($cmd);
	$cmd="vlib $library_home/$lib";
	&system_cmd_hl($cmd);
	$cmd="vmap $lib $ENV{'PWD'}/$library_home/$lib";
	&system_cmd_hl($cmd);
    } else {
	 


	&compile_file($f,$lib);
    }
}



sub system_cmd{
    my $cmd = pop;
    my $status;
    $status=system($cmd);
    if ($status > 0) {
	die("$cmd failed, exiting...");
    }
}

sub system_cmd_hl{
    my $cmd = pop;
    my $status;
    my $tmp = "bash -o pipefail -c '$cmd|keyword_highlight.pl 0";
    $status=system($cmd);
    if ($status > 0) {
	die("$cmd failed, exiting...");
    }
}

