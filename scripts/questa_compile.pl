#!/usr/bin/perl -w
# *************************************************************************************
# questa_compile.pl
# Questa Makefile Environment
#
# Copyright 2014 Mentor Graphics Corporation
# All Rights Reserved
#
# THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
# MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS
#
# bugs, enhancment requests to: Mikael_Andersson@mentor.com
# ************************************************************************************

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
my $nocolor=0;
# Let's find out the path to vmap
# Since we can use any variable for questa we do the following

my $model_tech_path=$ENV{"QUESTA_HOME"};


sub infomsg{
    my $nocolor=pop;
    my $s = pop;

    if ($nocolor==0) {
	print color 'bold dark blue';
	print "Note: $s\n";
	print color 'reset';
    } else {
	print "Note: $s\n";
    }
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
	&infomsg("Unknown filetype:$flist[0]",$nocolor);
	exit(1);
    }

    # Next step is to compile the code
    $tmp = join " ",@f;
#    print "DEBUG:$args\n";
    if ($type eq "vhdl") {
	$cmd = "vcom -$arch -work $lib $tmp $args $vcomargs";
	&infomsg("Launching: $cmd",$nocolor);
	&system_cmd_hl($cmd);

    } elsif ($type eq "verilog") {
	$cmd = "vlog -$arch -work $lib $tmp $args $vlogargs $mapped_libs";

	&infomsg("Launching: $cmd",$nocolor);
	&system_cmd_hl($cmd);
    } elsif ($type eq "c") {
	if ($usegcc) {
	    my @x=split "/",$tmp;
	    my $basename = pop @x;
	    &infomsg("####################################################################################################",$nocolor);
	    &infomsg("Using old way of compililing and linking c-code. Please refer to DPI Use Flow in Questa Users manual",$nocolor);
	    &infomsg("####################################################################################################",$nocolor);

	    &system_cmd("test -e c_libs/$lib||mkdir -p c_libs/$lib");
	    $cmd="gcc -m$arch $args $cflags $tmp -o ./c_libs/$lib/$basename".".o";
	    &infomsg("Launching: $cmd",$nocolor);
	    &system_cmd($cmd);
	    $cmd="g++ -m$arch $ldflags `find ./c_libs/$lib/ -name *.o -print` -o ./c_libs/$lib".".so";
	    &infomsg("Launching: $cmd",$nocolor);
	    &system_cmd($cmd);
	    

	} else {
	$cmd = "vlog -$arch -work $lib $tmp -ccflags \"$args $cflags\" -dpicppinstall $gcc_version -";
	&infomsg("Launching: $cmd",$nocolor);
	&system_cmd_hl($cmd);
	}


    } else {
	&infomsg("Unknown filetype:$type",$nocolor);
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
	    "nocolor"  => \$nocolor,   # flag
	    "verbose"  => \$verbose)   # flag
    or die("Error in command line arguments\n");




&infomsg("Parsing $fltfile",$nocolor);
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

my $cmd="rm -f $library_home/liborder.txt";
&system_cmd($cmd);


foreach my $f (@indata) {
    if ($f =~ /^\@library/ ) {
	my @line=split " ",$f;
	$lib=pop @line;
	&infomsg("Creating library $lib if does not exists",$nocolor);
	my $cmd="test -e $library_home||mkdir $library_home";
	&system_cmd($cmd);

	&infomsg("Creating library $lib/touchfiles if does not exists",$nocolor);
	my $cmd="test -e $library_home/touchfiles||mkdir $library_home/touchfiles";
	&system_cmd($cmd);
	&infomsg("Creating $lib",$nocolor);
	$cmd="vlib $library_home/$lib";
	&system_cmd_hl($cmd);
	&infomsg("Mapping $lib",$nocolor);
	$cmd="vmap $lib $ENV{'PWD'}/$library_home/$lib";
	&system_cmd_hl($cmd);
	my $cmd="echo $lib >> $library_home/liborder.txt";
	&system_cmd($cmd);

    } else {
	 


	&compile_file($f,$lib);
	my $cmd="touch $library_home/touchfiles/$lib";
	&system_cmd_hl($cmd);

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

