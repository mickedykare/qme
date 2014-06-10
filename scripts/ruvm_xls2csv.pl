#!/usr/bin/perl 
use strict;
use Spreadsheet::ParseExcel;
my $excel_file=pop;
my $parser   = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse($excel_file);
my $worksheet;
my $column;
my $value;
my @cols;
my $col;
my $row=0;
# These are the names of the tabs.
#my @sheets=('regs','mems','blocks','maps','RTL_settings','C_settings');
my @sheets=('regs','blocks','maps','RTL_settings','C_settings');

my $old_key="XXXXXX";
my $old_key_2="XXXXXX";

sub print_note{
    my $msg=pop;
    print "NOTE:$msg\n";
} 
         
sub print_error{
    my $msg=pop;
    print "ERROR:$msg\n";
    exit(1);
} 

sub is_row_empty{
    my $no_of_columns=pop;
    my $row=pop;
    my $sheet=pop;
    my $empty=1;
    my $val;
#    print "DBG: Checking $no_of_columns columns on row $row\n";

    for (my $i=0;$i<$no_of_columns;$i++) {
	my $column=$sheet->get_cell($row,$i);

	if (defined $column) {
	    $val=$column->value();
	    if ($val eq "") {
	    } else {
		return 1;
	    }
	} else {
	    return 0;
	}
    }
    return 0;
}

sub fill_column_if_empty{
    my $fill = pop;
    my $sheet = pop;
    my $col = pop;
    my $row = pop;
    my $old_val = pop;
    my $columnx;
    my $val;
#    print "Checking $row,$col\n";
    $columnx=$sheet->get_cell($row,$col);
    
    if (defined $columnx) {
	$val=$columnx->value();
	if (($val eq "") & ($fill)) {
	    $val=$old_val;
	}else {
	    $old_val=$val;
	}
    } else {
	$val="";
    }
    return $val;
}





sub print_row {
    my $row=pop;
    my $no_of_columns=pop;
    my $sheet=pop;
    my $val;
    my $columnx;
    my $filled=0;
    # Get first column; It is always the key
    $val=&fill_column_if_empty($old_key,$row,0,$sheet,1);
    if ($old_key eq $val) {
	$filled=1;
    } else {
	$old_key = $val;
	$filled=0;
    }
    print FILEP "\"$val\",";

    # this should only be done if we kept the old key. Not for new keys
    $val=&fill_column_if_empty($old_key_2,$row,1,$sheet,$filled);
    $old_key_2 = $val;
    print FILEP "\"$val\",";

#    print "DBG key=$val old=$old_key\n";


    for (my $i=2;$i<$no_of_columns-1;$i++) {
	$columnx=$sheet->get_cell($row,$i);
	if (defined $columnx) {
	    $val=$columnx->value();
    	} else {
	    $val="";
	}
	print FILEP "\"$val\",";
    }

    # Last column
    $columnx=$sheet->get_cell($row,$no_of_columns-1);
    if (defined $columnx) {
	$val=$columnx->value();
    } else {
	$val="";
    }

    print FILEP "\"$val\"\n";



}






foreach my $s (@sheets) {
    my $csvfile=$s.".csv";
    open FILEP,">",$csvfile;
#    &print_note("Checking sheet $s");
    $worksheet = $workbook->worksheet($s);  
    # First thing we want to do is to find out how many columns we have
    # in the sheet. This is done by checking the first row
    $column=$worksheet->get_cell($row,0);
    $value=$column->value();
    @cols=($value);
#    print "DBG: FIRST COL:$value\n";
    $col=0;
    while (defined $column)        {
	$col=$col+1;
	$column=$worksheet->get_cell($row,$col);
	if (defined $column) {
	    $value=$column->value();	    
	    push @cols,$value;
	}
    }    
    $col--;
    for (my $i=0;$i<$col-1;$i++) {
	my $tmp=shift @cols;
	print FILEP "$tmp,";
    }
    my $tmp=shift @cols;
    print FILEP "$tmp\n";

    my $is_not_empty=1;
    while($is_not_empty) {
	$row++;
#	print "DBG:Checking row $row ($col columns)\n";
	$is_not_empty=&is_row_empty($worksheet,$row,$col);

	if ($is_not_empty) {
#	    print "DBG:$row should be printed \n";
	    &print_row($worksheet,$col,$row);
	} 
    }
    $row=0;
    $col=0;
}
