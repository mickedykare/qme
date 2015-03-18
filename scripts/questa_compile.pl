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
my @vlogargs="";
my @vcomargs="";
my $setup="";
my $default_lib="";
my $library_home="questa_libs";
my $arch="32";
my $gcc_version="4.3.3";
my $nocolor=0;
my $prev_lib="";
my $prev_args="__NOARGS__";
my $prev_type="unknown";
my $generic_vlog_args="";
my $generic_vcom_args="";




# Let's find out the path to vmap
# Since we can use any variable for questa we do the following

my $model_tech_path=$ENV{"QUESTA_HOME"};
my $db;
my $file;
my $type;
my $args="";
my $id;


#@library x_lib
#@vlogargs:+define+xyz 
#@vcomargs:+define+xyz 

#file1.v
#file2.v
#
#
#
#




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





sub compile{
    my $ml=pop;
    my $l=pop;
    my $t=pop;
    my $args=pop;
    my $files = pop;
    my $vlargs = join " " ,@vlogargs;
    my $vcargs = join " " ,@vcomargs;
    my $cmd;
    if ($t eq "verilog") {	
	$cmd="vlog -work $l $files $args $ml $vlargs $setup $generic_vlog_args";
	&infomsg("Launching: $cmd",$nocolor);
	&system_cmd_hl($cmd);

    } elsif ($t eq "vhdl") {
	$cmd="vcom -work $l $files $args $vcargs $generic_vcom_args";
	&infomsg("Launching: $cmd",$nocolor);
	&system_cmd_hl($cmd);
	
    } elsif ($t eq "c") {
	if ($usegcc) {
	    my @x=split "/",$files; # Only expect one file for C code in this case
	    my $basename = pop @x;
	    &infomsg("####################################################################################################",$nocolor);
	    &infomsg("Using old way of compililing and linking c-code. Please refer to DPI Use Flow in Questa Users manual",$nocolor);
	    &infomsg("####################################################################################################",$nocolor);
	    &system_cmd("test -e c_libs/$l||mkdir -p c_libs/$l");
	    $cmd="gcc -m$arch $args $cflags $files -o ./c_libs/$l/$basename".".o";
	    &infomsg("Launching: $cmd",$nocolor);
	    &system_cmd($cmd);
	    $cmd="g++ -m$arch $ldflags `find ./c_libs/$l/ -name *.o -print` -o ./c_libs/$l".".so";
	    &infomsg("Launching: $cmd",$nocolor);
	    &system_cmd($cmd);
	} else {
	    $cmd = "vlog -$arch -work $l $files -ccflags \"$args $cflags\" -dpicppinstall $gcc_version";
	    &infomsg("Launching: $cmd",$nocolor);
	    &system_cmd_hl($cmd);
	}


    }
}


GetOptions ("cflags=s" => \$cflags,    # numeric
	    "file=s"   => \$fltfile,      # string
	    "setup=s" => \$setup,
	    "vlogargs=s" => \@vlogargs,
	    "vcomargs=s" => \@vcomargs,
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
    if (($l =~/^\#/)|($l =~ /^ *$/)) {
#	print "DBG:skipping line:$l\n";
    } else {
	$l =~ s/\s+$//;
	push @tmp,$l;

    }
}

@indata=@tmp;
my $lib=$default_lib;
my @liborder;
my @fileorder;
my @argorder;
my @typeorder;

my $cmd="rm -f $library_home/liborder.txt";
&system_cmd($cmd);

# Build a hash
# db->{'lib'}->{type}->{<file>}->{arguments}
my $i=1;
$cmd="test -e $library_home||mkdir -p $library_home"; 
&system_cmd_hl($cmd);
&infomsg("Analyzing contents of FLT file and creating libraries",$nocolor);
foreach my $f (@indata) {
 #   &infomsg("LINE: $f",$nocolor);
    if ($f =~ /^\@library/ ) {
	$generic_vlog_args="";
	$generic_vcom_args="";
	my @line=split " ",$f;
	$lib=pop @line;
	push @liborder,$lib;
	$file="";
	$args="";
	$i = 1;
	$cmd="test -e $library_home/$lib||vlib $library_home/$lib"; 
	&system_cmd_hl($cmd);
	$cmd="vmap $lib $ENV{PWD}/$library_home/$lib"; 
	&system_cmd_hl($cmd);
	$cmd = "echo $lib >> $library_home/liborder.txt";
	&system_cmd_hl($cmd);
    } elsif ($f =~ /^\@vlogargs:/ ) {
	my @line=split ":",$f;
	my $tmp=pop @line;
	$generic_vlog_args=join " ", $generic_vlog_args,$tmp;
    } elsif ($f =~ /^\@vcomargs:/ ) {
	my @line=split ":",$f;
	my $tmp=pop @line;
	$generic_vcom_args=join " ", $generic_vcom_args,$tmp;
    } else {
	if ($f =~ /:/) {
	    my @line=split ":",$f;
	    $file = $line[0];
	    $args = $line[1];
	} else {
	    $file = $f;
	    $args="";
	}

	################################################################

	if (($file =~ /\.vhd$/)|($file =~ /\.vhdl$/)) {
	    $type="vhdl";
	} elsif (($file =~ /\.sv$/)|($file =~ /\.v$/)|($file =~ /\.svh$/)) {
	    $type="verilog";
	} elsif (($file =~ /\.c$/)|($file =~ /\.cpp$/)) {
	    $type="c"; 
	} else {
	    &infomsg("Unknown filetype:$file",$nocolor);
	    exit(1);
	}
#	print "DBG:$lib $i $file\n";
	$db->{$lib}->{"$i"}->{'filename'}=$file;
	$db->{$lib}->{"$i"}->{'type'}=$type;
	$db->{$lib}->{"$i"}->{'args'}=$args;
	$db->{$lib}->{'no_of_files'}=$i;
    $i++;

    }

 #   print "DBG: Next line:$i\n";

}

# At this point we should have a hash that contains all files that should be compiled.
# 1. We are going to, for each library, compile all verilog files with the same arguments, where number is adjacent
# I.e compile order MUST be respected

#&infomsg("#################################",$nocolor);
my @vmap=`vmap|grep "maps to"|grep -v $model_tech_path|cut -d" " -f1|sed s/\\"/-L\\ /|sed s/\\"//g`;
chomp @vmap;
my $mapped_libs=join " ",@vmap;
my $command_files="";
my $command_args="";


&infomsg("Optimizing compile commands to save time where possible",$nocolor);
for my $library (@liborder) {
    my $no_of_files=$db->{$library}->{'no_of_files'};
#    &infomsg("Analyzing $no_of_files files in $library",$nocolor);
    for (my $n=1; $n<=$no_of_files;$n++){
#	print "DBG:$library $n \n";
	$file= $db->{$library}->{"$n"}->{'filename'};
	$args= $db->{$library}->{"$n"}->{'args'};
	$type= $db->{$library}->{"$n"}->{'type'};
	$i++;
#	print "-------------------------\n";
#	&infomsg("n = $n,LIB=$library,PREV_LIB=$prev_lib",$nocolor);
#	&infomsg("FILE=$file",$nocolor);
#	&infomsg("ARGS=$args, PREV_ARGS=$prev_args",$nocolor);
#	&infomsg("TYPE=$type,PREV_TYPE=$prev_type",$nocolor);

	if ($library eq $prev_lib) {
#	    print "DBG:Same library as previous file ($library,$type,$prev_type)\n";
	    if (($type eq $prev_type)& ($type ne "c")) {
#		print "DBG:Same type as previous file and not c code($type)\n";
		if ($args eq $prev_args) {
#		    print "DBG:Same arguments as previous file MERGE POSSIBLE\n";
		    $command_files = join " ", $command_files,$file;
#		    print "DBG:files = $command_files\n";
		} else {
#		    print "DBG:Different arguments (prev=$prev_args,args=$args) compared to previous file. NO MERGE\n";
		    if ($command_files ne "") {
#			print "DBG:Compile previous files: $prev_lib $command_files $prev_args\n";		    
			&compile($command_files,$prev_args,$prev_type,$prev_lib,$mapped_libs);
		    }
		    $prev_args=$args;
		    $prev_type=$type;
		    $command_files=$file;
		    $command_args=$args;
		}
	    } else {
#		print "DBG:Different type compared to previous file ($prev_type). NO MERGE\n";
		if ($command_files ne "") {
#		    print "DBG:Compile previous files:$prev_lib $command_files $args\n";
		    &compile($command_files,$prev_args,$prev_type,$prev_lib,$mapped_libs);
		}
		$prev_args=$args;
		$prev_type=$type;
		$command_files=$file;
		$command_args=$args;
	
	    }
	} else {
#	    print "DBG:Different library compared to previous file. NO MERGE\n";
	    if ($command_files ne "") {
#		print "DBG:Compile previous files: $prev_lib $command_files $prev_args\n";		    
		    &compile($command_files,$prev_args,$prev_type,$prev_lib,$mapped_libs);

	    }
	    $prev_args=$args;
	    $prev_type=$type;
	    $command_files=$file;
	    $command_args = $args;
	    # compile
	    $prev_lib = $library;
	}
    }
}


if ($command_files ne "") {
#    print "DBG:Compile outstanding files: $prev_lib $command_files $prev_args\n";		    
    &compile($command_files,$prev_args,$prev_type,$prev_lib,$mapped_libs);

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

