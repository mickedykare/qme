#!/usr/bin/perl
use strict;
use Getopt::Long;
use Spreadsheet::ParseExcel;
use Spreadsheet::XLSX;
use POSIX qw(strftime);
use File::Basename;

my $worksheet;

my $excelfile;
my $datestring = strftime "%Y %b %e %H:%M:%S", localtime;

GetOptions ("input|i=s"			=> \$excelfile	)	or die;

defined $excelfile or die "You must provide an excelfile name with -i or -input!\n";

(my $filename,my $path,my $suffix) = fileparse($excelfile,qr"\..[^.]*$");
my $xmlfilename="$filename.xml";

print "##################################################\n";
print "Converting from:$excelfile\n";
print "Converting to:  $xmlfilename\n";
print "##################################################\n";

open XMLFILE, ">$xmlfilename" or die $!;
my $parser;
my $workbook;

if ($suffix =~ /xlsx/) {
	$workbook   = Spreadsheet::XLSX->new($excelfile);
} elsif ($suffix =~ /xls/) {
	$parser   = Spreadsheet::ParseExcel->new();
	$workbook = $parser->parse($excelfile);
	die $parser->error(), ".\n" if ( !defined $workbook );
}


print XMLFILE "<!-- WorkBook Path: $excelfile -->\n";
print XMLFILE "<!-- Date: $datestring -->\n";
print XMLFILE "<Workbook>\n";
for my $worksheet ( $workbook->worksheets() ) {
	my $worksheetname=$worksheet->get_name();
 	my ( $row_min, $row_max ) = $worksheet->row_range();
   my ( $col_min, $col_max ) = $worksheet->col_range();
	##################################################################
	## Not necessary that the first row is the one as row_min since ##
	## the user might have backannotated coverage numbers           ##
	## So look for the first row that has more than 4 columns       ##
	##################################################################
	my $start_row=$row_min;
	for (my $r=$row_min; $r<$row_max;$r++) {
		my $cell_with_contents=0;
		for (my $c=$col_min;$c<$col_max;$c++) {
   		my $cell = $worksheet->get_cell($r, $c);
			next unless $cell;
			my $val=$cell->value();
			if ($val ne "") {
			  	$cell_with_contents++;
			}
		}
		if ($cell_with_contents>4) {
			$start_row=$r;
			last;
		}
	}

	# Skip the worksheet with _LINK_DETAILS (hidden one) and the ones with columns less than 6 (should make it only the verification plan)
	if ( !($worksheetname =~ /^_/) && $col_max-$col_min>5) {
	   print "Found worksheet: $worksheetname\n";
		print "The rows range from $start_row to $row_max  \n";
		print "The columns range from $col_min to $col_max\n";
		print "These are the columns:\n";
		for (my $c=$col_min;$c<=$col_max;$c++) {
			my $description= $worksheet->get_cell($start_row, $c)->value();
			printf "Column:%2d  -- $description\n",$c;
		}

	   print "##################################################\n";
		print XMLFILE "   <Worksheet>  <!-- $worksheetname -->\n";
		print XMLFILE "     <Table>\n";
		for (my $row=$start_row+1;$row<=$row_max;$row++) {
			print XMLFILE "        <Row>\n";
			for (my $col=$col_min;$col<=$col_max;$col++) {
				print XMLFILE "           <Cell>";
				my $cell = $worksheet->get_cell($row, $col);
				if ($cell) {
					my $value = $cell->value();
					# Since we are writing out XML we need to substitute some reserved characters
					$value =~ s/&/&amp;/g;
					$value =~ s/\"/&quot;/g;
					$value =~ s/</&lt;/g;
					$value =~ s/>/&gt;/g;
					print XMLFILE "$value";
				}
				my $description= $worksheet->get_cell($start_row, $col)->value();
				# Since we are writing out XML we need to substitute some reserved characters
				$description =~ s/&/&amp;/g;
				$description =~ s/\"/&quot;/g;
				$description =~ s/</&lt;/g;
				$description =~ s/>/&gt;/g;
				print XMLFILE "</Cell>  <!-- $description -->\n";
			}
			print XMLFILE "        </Row>\n";
		}
		print XMLFILE "     </Table>\n";
		print XMLFILE "   </Worksheet>  <!-- $worksheetname -->\n";
	}
}
print XMLFILE "</Workbook>\n";
close (XMLFILE);

print "Converted $excelfile to $xmlfilename\n";

