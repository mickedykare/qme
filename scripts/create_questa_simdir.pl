#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Term::ANSIColor;
use File::Basename;
use Cwd;

my $block;
my $parent;
my $project;
my $simdir;
my $projhome;
my $force=0;
my $help=0;
my $scratchdir=$ENV{'QME_SCRATCH_HOME'};
my $simsettingsdir=$ENV{'QME_SIM_SETTINGS_DIR'};
my $makefile = $ENV{'QME_HOME'}."/"."templates/Makefile.template";
my $block_overrides;

my $srchome=$ENV{'QME_PROJECT_HOME'}."/";

# Functions
sub print_note{
    my $string=pop;
    print color "bold dark blue";
    print "Note: $string\n";
    print color "reset";
}
sub print_error{
    my $string=pop;
    print color "bold dark red";
    print "ERROR: $string\n";
    print color "reset";
}

sub print_warning{
    my $string=pop;
    print color "bold dark yellow";
    print "Warning: $string\n";
    print color "reset";
}
sub system_cmd{
    my $cmd = pop;
    my $status;
    $status=system($cmd);
    &check_syscmd($status);
}



sub check_syscmd {
    my $return_status = $_[0];
    if ($return_status != 0) { 
        my $error_msg = "system call ended with exit status = $return_status.";
	&print_error($error_msg);
	exit(1);
    }
}

sub copy_to{
    my $d = pop;
    my $s = pop;
    &print_note("Copying $s to $d");
    &system_cmd("cp -f $s $d");
}


#update_makefile(makefile.tmpl,makefile)
sub update_makefile{
    my $outfile = pop;
    my $infile=pop;


    open FILE, $infile or die $!;
    my @indata = <FILE>;
    my $tmp;
    close FILE;
    open FILE, ">$outfile" or die $!;

    foreach (@indata) {
	s/___REPLACE_THIS_BLOCKNAME/$block/;
	s/___REPLACE_THIS_BLOCK_OVERRIDES/$block_overrides/;
	s/___REPLACE_THIS_SRCHOME/$srchome/;
	print FILE "$_";
    }
    close FILE;

}







my $usage = <<END;
 Usage: $0 [options] --name=<simdir name> --block=<blockname>
  Options:
    --help, -h                            This text
    --simdir=<name> ,-s=<name>            Specifices the name of the simulation dir
    --parent=<name>,-p=<name>             If you are using a subblock in the library tree
    --block=<block>,-b=<block>            Specifices then name of the block that we want to simulate
    --force,-f                            Force overwrite of files in the simdir
    --scratch=<scratch home>              If you want to specify your own location of your simulation directory
END



GetOptions ("block=s" => \$block,   
	    'help|usage|h' => \$help,
	    "parent=s"   => \$parent,
	    "project=s" => \$project,
	    'scratch=s' => \$scratchdir,
	    "simdir=s" => \$simdir,   
            "force" => \$force)
    or die("Error in command line arguments\n");

if ($help) {
    print color "red";
    print $usage;
    print color "reset";
    exit 0;
}

if ($simdir eq "") {
    die $usage;
}
if ($block eq "") {
    die $usage;
}

$block_overrides=$srchome.$block."/sim/Makefile.block.defaults";

## Check environment variables
if (-e $ENV{'QME_HOME'}) {
    &print_note("Checking Environment Variable QME_HOME (OK)");
} else {
    die("Please check QME_HOME($ENV{'QME_HOME'}) (ERROR)");
}


if (-e $ENV{'QME_PROJECT_HOME'}) {
    &print_note("Checking Environment Variable QME_PROJECT_HOME (OK)");
    $projhome=$ENV{'QME_PROJECT_HOME'};
} else {
    die("Please check QME_PROJECT_HOME (ERROR)");
}

if (-e $ENV{'QME_SCRATCH_HOME'}) {
    &print_note("Checking Environment Variable QME_SCRATCH_HOME (OK)");
} else {
    die("Please check QME_SCRATCH_HOME($ENV{'QME_SCRATCH_HOME'}) (ERROR)");
}

# For simplicity all blocks are considered to be on the same level
if (-e $projhome."/".$block) {
    &print_note("Checking that $projhome/$block exists (OK)");
} else {
    die("Please check either QME_PROJECT_HOME($projhome) or BLOCK name($block)");
}

## We assume that there is a sim directory where all 
## block settings actually exists. This directory is defined by 
if (-e $projhome."/".$block."/".$simsettingsdir) {
    &print_note("Checking that $projhome/$block/$simsettingsdir exists (OK)");
} else {
    &print_note("Checking that $projhome/$block/$simsettingsdir exists (ERROR)");
    die("Please check either QME_SIM_SETTINGS_DIR ($simsettingsdir)");
}

## Check if Makefile.block.defaults exists.
my $block_defaults=$projhome."/".$block."/".$simsettingsdir."/"."Makefile.block.defaults";
if (-e $block_defaults) {
    &print_note("Checking that $block_defaults exists (OK)");
} else {
    &print_warning("$block_defaults does not exist - creating one...");
    &system_cmd("touch $block_defaults");
}


my $simdir_fp=$ENV{'QME_SCRATCH_HOME'}."/".$simdir;

if (-e $simdir_fp) {
    if ($force == 0) {
    die("Error: $simdir_fp already exists, add -force to overwrite");
    } else {
    &print_note("Overwriting some files in $simdir_fp");
#    &system_cmd("rm -rf $simdir_fp");
#    &system_cmd("mkdir  $simdir_fp");

    }

} else {
    &print_note("Checking that $simdir_fp does not exists (OK)");
    &print_note("Creating $simdir_fp");
    &system_cmd("mkdir -p $simdir_fp");
}

# Copy some needed files to the simulation directory

my $destination= $simdir_fp."/"."Makefile";
&print_note("Creating $destination");
&update_makefile($makefile,$destination);
print "cd $simdir_fp\n";

