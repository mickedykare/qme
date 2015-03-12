#!/usr/bin/perl -w
# *************************************************************************************
# convert_htmltestplan.pl
# ************************************************************************************
BEGIN {push @INC,'/vobs/asic/utils/setup/scripts/mksimdir_files/perl_modules/lib/perl5'}
use strict;
use Getopt::Long;
use Term::ANSIColor;

use Excel::Writer::XLSX;                                   

my $workbook = Excel::Writer::XLSX->new( 'backannotated_testplan.xlsx' );
my $worksheet = $workbook->add_worksheet('backannotated_testplan');               

my $testplanfile="";
my $delimiter=";";
my $linkoption=0;
my $csvoption=0;
my $exceloption=0;
my $barsoption=0;

my $help;

my $usage = <<END;
 Usage: $0 [options] 
   Options:
     --testplan_html, -f  testplan.html file in the HTML report directory
     --links, -l          Expand all sections with link information
     --xls                Generate back_annotated.xlsx file 
     --csv                Print out CSV formatted testplan (redirect with > to generate csv file) 
     --bars               Insert a data bar in the cells for Coverage and PercentOfGoal in the generated Excel testplan
     --help, -h           This text
     --delimiter, -d      Delimiter to use in generated csv file, default=;
END


GetOptions ("html_testplan|f=s"   => \$testplanfile,
	    	   "help|h" => \$help,
				"links!" => \$linkoption,
				"xls!" => \$exceloption,
				"csv!" => \$csvoption,
				"bars!" => \$barsoption,
			   "delimiter|d=s" => \$delimiter)
    or die("Error in command line arguments\n");

my $FHIN;

if ($help) { print $usage; exit 0; }
if ($testplanfile eq "") { print $usage; exit 1; }

open($FHIN, "<", $testplanfile) 
    or die "Testplanfile:$testplanfile doesn't Exist!\n";

my $section; 		#z
my $section_number;
my $section_title; 		
my $linkeditems; 	#c
my $covereditems; #v
my $coverage; 		#h
my $percentofgoal;#p
my $type;			#t
my $bins;			#b
my $hits;			#ht
my $hit;				#q
my $link_status;	#ls    1=Unlinked 2=Clean  3=Partial   4=Error
my $description;	#ch
my $weight;			#x1
my $goal;			#x2
my $linkname;
my $linkcolor;

my $rownumber=0;
my $colnumber;

my $line;
my $title;

my $headerformat;
my $normalformat;
my $percentformat;

if ($exceloption) {
	$headerformat = $workbook->add_format();
   $headerformat->set_bold(1);
	$normalformat = $workbook->add_format();
   $normalformat->set_bold(0);
#   $normalformat->set_italic(1);
	$percentformat = $workbook->add_format();
	$percentformat->set_num_format( '[Black]0,00%;' );
}	

sub print_csvrow {
	print "$section_number$delimiter$section_title$delimiter$description$delimiter$linkname$delimiter$type$delimiter$link_status$delimiter$linkeditems$delimiter$covereditems$delimiter$coverage$delimiter$percentofgoal$delimiter$bins$delimiter$hits$delimiter$hit$delimiter$weight$delimiter$goal\n";
}

sub print_excelrow {
	$rownumber++;
	$worksheet->write( $rownumber, 0, $section_number,$normalformat ); 					
	$worksheet->write( $rownumber, 1, $section_title ,$normalformat);  				  
	$worksheet->write( $rownumber, 2, $description,$normalformat);					 
	$worksheet->write( $rownumber, 3, $linkname,$normalformat); 					
	$worksheet->write( $rownumber, 4, $type,$normalformat); 					
	$worksheet->write( $rownumber, 5, $weight,$normalformat);  				  
	$worksheet->write( $rownumber, 6, $goal,$normalformat); 					
	$worksheet->write( $rownumber, 7, $link_status,$normalformat);					 
	$worksheet->write( $rownumber, 8, $linkeditems,$normalformat);					 
	$worksheet->write( $rownumber, 9, $covereditems,$normalformat);  				  
	$worksheet->write( $rownumber,10, $coverage,$normalformat);					 
	$worksheet->write( $rownumber,11, $percentofgoal,$normalformat); 					
	$worksheet->write( $rownumber,12, $bins,$normalformat); 					
	$worksheet->write( $rownumber,13, $hits,$normalformat); 					
	$worksheet->write( $rownumber,14, $hit,$normalformat);  				  
}

################
#### Header ####
################
if ($csvoption) {
	$title="sectionnumber,sectiontitle,description,link,type,link_status,linkeditems,covereditems,coverage,percentofgoal,bins,hits,hit,weight,goal";
   $title=~s/,/$delimiter/g;
   print "$title\n";
} 
if ($exceloption) {
	$worksheet->write( $rownumber, 0, 'Sectionnumber ',$headerformat); 					
	$worksheet->write( $rownumber, 1, 'Sectiontitle ',$headerformat);  				  
	$worksheet->write( $rownumber, 2, 'Description ',$headerformat);					 
	$worksheet->write( $rownumber, 3, 'Link ',$headerformat); 					
	$worksheet->write( $rownumber, 4, 'Type ',$headerformat); 					
	$worksheet->write( $rownumber, 5, 'Weight ',$headerformat);  				  
	$worksheet->write( $rownumber, 6, 'Goal ',$headerformat); 					
	$worksheet->write( $rownumber, 7, 'Link_status ',$headerformat);					 
	$worksheet->write( $rownumber, 8, 'Linkeditems ',$headerformat);					 
	$worksheet->write( $rownumber, 9, 'Covereditems ',$headerformat);  				  
	$worksheet->write( $rownumber,10, 'Coverage ',$headerformat);					 
	$worksheet->write( $rownumber,11, 'Percentofgoal ',$headerformat); 					
	$worksheet->write( $rownumber,12, 'Bins ',$headerformat); 					
	$worksheet->write( $rownumber,13, 'Hits ',$headerformat); 					
	$worksheet->write( $rownumber,14, 'Hit%',$headerformat);  				  
} 

while ($line = <$FHIN>) {
	chomp $line;
	if (($line =~/^\s*<tr/) & ($line=~/z="/)) { 
	   $colnumber=0;
		$section="";
		$section_number="";
		$section_title="";
		$linkeditems="";
		$covereditems="";
		$coverage=""; 	
		$percentofgoal="";
		$type="";		
		$bins="";		
		$hits="";		
		$hit="";			
		$link_status="";
		$description="";
		$weight="";		
		$goal="";		
		$linkname="";
		if ($line =~ /\sz="(.*?)"/) {
			$section=$1;
		}
		if ($line =~ /\sc="(.*?)"/) {
			$linkeditems=$1;
		}
		if ($line =~ /\sv="(.*?)"/) {
			$covereditems=$1;
		}
		if ($line =~ /\sh="(.*?)"/) {
			$coverage=$1;
		}
		if ($line =~ /\sp="(.*?)"/) {
			$percentofgoal=$1;
		}
		if ($line =~ /\st="(.*?)"/) {
			$type=$1;
		}
		if ($line =~ /\sb="(.*?)"/) {
			$bins=$1;
		}
		if ($line =~ /\sht="(.*?)"/) {
			$hits=$1;
		}
		if ($line =~ /\sq="(.*?)"/) {
			$hit=$1;
			if ($hit eq "--") {
				$hit="";
			} else {
				$hit =~ s/%//;  # Remove the percentage sign
			}
		}
		if ($line =~ /\sls="(.*?)"/) {
			$link_status=$1;
			if ($link_status=="1") {
			$link_status="Unlinked";
			} elsif ($link_status=="2"){
			$link_status="Clean";
			}elsif ($link_status=="3"){
			$link_status="Partial";
			}elsif ($link_status=="4"){
			$link_status="Error";
			}
		}
		if ($line =~ /\sch="(.*?)"/) {
			$description=$1;
		}
		if ($line =~ /\sx1="(.*?)"/) {
			$weight=$1;
		}
		if ($line =~ /\sx2="(.*?)"/) {
			$goal=$1;
		}
		if ($type ne "Testplan") { 
			# This is a link, get the linkname and the linkcolor
			if ($line =~ /\sz="(.*?)"/) {
				$linkname=$1;
			}
			if ($line =~ /\shc="(.*?)"/) {
				$linkcolor=$1;
			}
		}
		if ($section =~ /(.*?)\s+(.*)/) {
			$section_number="'$1";
			$section_title=$2;
		}
		if ($type eq "Testplan") {
			if ($csvoption) {
				&print_csvrow;
			} 
			if ($exceloption) {
				&print_excelrow;
			}
		} elsif ($linkoption) {
			if ($csvoption) {
				&print_csvrow;
			} 
			if ($exceloption) {
				&print_excelrow;
			}
		}
	}
}

##### Time to colorize for Excel
if ($exceloption) {
	my $range="K2:K$rownumber"; ### This is the Coverage column
	# First colorize the cell with a 3- grade scale Red -> Yellow -> Green
	$worksheet->conditional_formatting( $range, { type => '3_color_scale',min_color => "#F8696B", mid_color => "#FFEB84", max_color => "#63BE7B", mid_type => 'percent',  } );
	if ($barsoption) {
		# Now insert a bar in the cell as well going from 0% -> 100%
		$worksheet->conditional_formatting( $range, { type => 'data_bar', bar_color => "#63BE7B"},  );
	}
	$range="L2:L$rownumber";  ### This is the Percent Of Gaol column
	# First colorize the cell with a 3- grade scale Red -> Yellow -> Green
	$worksheet->conditional_formatting( $range, { type => '3_color_scale',min_color => "#F8696B", mid_color => "#FFEB84", max_color => "#63BE7B", mid_type => 'percent',  } );
	if ($barsoption) {
		# Now insert a bar in the cell as well going from 0% -> 100%
		$worksheet->conditional_formatting( $range, { type => 'data_bar', bar_color => "#63BE7B"},  );
	}
	$range="O2:O$rownumber";  ### This is the Hit% Column
	# First colorize the cell with a 3- grade scale Red -> Yellow -> Green
	$worksheet->conditional_formatting( $range, { type => '3_color_scale',min_color => "#F8696B", mid_color => "#FFEB84", max_color => "#63BE7B", mid_type => 'percent',  } );
	if ($barsoption) {
		# Now insert a bar in the cell as well going from 0% -> 100%
		$worksheet->conditional_formatting( $range, { type => 'data_bar', bar_color => "#63BE7B"},  );
	}
}
