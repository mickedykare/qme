#!/bin/tcsh -f
# This script will make sure that all necessary stuff exists for you to 
# be able to run QME
#
#set verbose
set qme_home = `pwd`
set perlpackage = "Spreadsheet-ParseExcel-0.59.tar.gz"
set perldir = "$perlpackage:r:r"
set perlsrc = $qme_home/perlmodules/perlsrc/$perlpackage
echo "Starting by unpacking $perlsrc to $qme_home/perlmodules"
cd $qme_home/perlmodules
mkdir tmp_data
cd tmp_data
gtar -xzf $perlsrc
cd $perldir
perl Makefile.PL INSTALL_BASE=${qme_home}/perlmodules
make 
make install
cd ../.. 
rm -rf tmp_data
echo "Congratulations! Don't forget to check INSTALL.TXT for variables"
