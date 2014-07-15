#!/usr/bin/perl -w
# *************************************************************************************
# keyword_highlight.pl
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

use Term::ANSIColor;
$disable=pop;

  highlight( );                   # push number filter on STDOUT
  
  while (<>) {                # act like /bin/cat
      print;
  } 
  close STDOUT;               # tell kids we're done--politely
  exit;
  
  sub highlight {
      my $pid;
      return if $pid = open STDOUT, "|-";
      die "cannot fork: $!" unless defined $pid;
      while (<STDIN>) { 
	  if ($disable) {
	      printf "%s", $_; 
	  } else {

	  if ($_ =~ /Warning:/) {
	  printf color "yellow";
	  printf "%s", $_; 
	  print color "reset";

	  } elsif  ($_ =~ /Error:/) {
	      printf color "red";
	      printf "%s", $_; 
	      print color "reset";

	  }

	  else {
	  printf "%s", $_; 
	  }
	  }      
      } 
      

      exit;
  } 
  
