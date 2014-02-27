#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Term::ANSIColor;

my $cflags="";
my $fltfile="";
my $verbose=0;
my $vlogargs="";
my $vcomargs="";
my $default_lib="";

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
    my $f;
    my $cmd;
    if ($file =~ /:/) {
	my @line=split ":",$file;
	$f = $line[0];
	$args = $line[1];
    } else {
	$f = $file;    
    }

    # This is only valid if we have a library:
    # Check if this is a VHDL file
    if ($f =~ /\.vhd$/) {
	$cmd = "vcom -work $lib $f $args $vcomargs";
	&infomsg("$cmd");
    } elsif (($f =~ /\.sv$/)|($f =~ /\.v$/)|($f =~ /\.svh$/)) {
	$cmd = "vlog -work $lib $f $args $vlogargs";
	&infomsg("$cmd");
    } elsif (($f =~ /\.c$/)|($f =~ /\.cpp$/)) {
	$cmd = "vlog -work $lib $f $args -ccflags $cflags";
	&infomsg("$cmd");
    } else {
	&infomsg("Unknown filetype:$f");
    }
} 
 





GetOptions ("cflags=s" => \$cflags,    # numeric
	    "file=s"   => \$fltfile,      # string
	    "vlogargs=s" => \$vlogargs,
	    "vcomargs=s" => \$vcomargs,
	    "default_lib=s" => \$default_lib,
	    "verbose"  => \$verbose)   # flag
    or die("Error in command line arguments\n");

&infomsg("Parsing $fltfile");
open(FHIN, "<", $fltfile) 
    or die "cannot open $!";
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
	my @line=split "=",$f;
	$lib=pop @line;
	&infomsg("Found library $lib");
    } else {
	&compile_file($f,$lib);
    }
}
