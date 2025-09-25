#!/usr/bin/perl -w
###########################
###   Jennifer Meneghin ### 
### Updated 25 Feb 2025 by Emily St. John. Changed line 56 from ".fasta" to ".fa"
###   March 13, 2018    ###
###########################

#----------------------------------------------------------------
#Deal with passed parameters
#----------------------------------------------------------------
#If no arguments are passed, show usage message and exit program.
if ($#ARGV == -1) {
    &usage;
}
$in_file = "";
$out_file = "rc_bin_summary.out";
#$sum_col = 1;
#$count_col = 2;
%my_args = @ARGV;
for $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file = $my_args{$i};
    }
    else {
	print "Unrecognized argument: $i\n\n";
	&usage;
    }
}
unless ( open(IN, "$in_file") ) {
    print "Couldn't read input file: $in_file\n";
    &usage;
}
unless ( open(OUT, ">$out_file") ) {
    print "Couldn't write to output file: $out_file\n";
    &usage;
}
print "Parameters:\nInput file = $in_file\nOutput file = $out_file\n\n";
#-----------------------------------------------------------------------------------------------------------------------------------------
#The main event
#-----------------------------------------------------------------------------------------------------------------------------------------
%totalcoverage = ();
%totallength = ();
%totalcontigs = ();
while (<IN>) {
    chomp;
    @fields = split(/\t/);
    #$contig=$fields[0];
    $length=$fields[1];
    $cov_line=$fields[2];
    @covfields = split(/\s/,$cov_line);
    $coverage = $covfields[1];  
    $bin_line=$fields[3];
    if ($bin_line) {
	@binfields = split(/.fa/,$bin_line);
	$bin = $binfields[0];
    }
    else {
	$bin = "No Bin Assigned";
    }
    #print "length = $length\tcov_line = $coverage\tbin = $bin\n";
    if ($totalcoverage{$bin}) {
	$totalcoverage{$bin} = $totalcoverage{$bin} + ($length * $coverage);
    }
    else {
	$totalcoverage{$bin} = $length * $coverage;
    }
    if ($totallength{$bin}) {
	$totallength{$bin} = $totallength{$bin} + $length;
    }
    else {
	$totallength{$bin} = $length;
    }
    if ($totalcontigs{$bin}) {
	$totalcontigs{$bin} = $totalcontigs{$bin} + 1;
    }
    else {
	$totalcontigs{$bin} = 1;
    }
}
print "Bin\tNormalized Read Coverage\tTotal Length\tNumber Contigs\n";
print OUT "Bin\tNormalized Read Coverage\tTotal Length\tNumber Contigs\n";
#foreach $i (sort { $counts{$b} <=> $counts{$a} } keys %counts) {
foreach $i (sort keys %totalcontigs) {
    $thiscoverage = $totalcoverage{$i}/$totallength{$i};
    print "$i\t$thiscoverage\t$totallength{$i}\t$totalcontigs{$i}\n";
    print OUT "$i\t$thiscoverage\t$totallength{$i}\t$totalcontigs{$i}\n";
}
close(IN);
close(OUT);
#-----------------------------------------------------------------------
sub usage {
    print "Jennifer Meneghin\n";
    print "March 13, 2018\n";
    print "Usage: rc_bin_summary.pl -i <input file> -o <output file>\n\n";
    print "This program takes a tabbed delimmited file with:\n";
    print "col 1 = contig, col 2 = length, col 3 = contig and coverage, col 4 = bin and contig combo.\n";
    print "It returns a tab delimmited file with:\n";
    print "with col 1 = Bin ID, col 2 = normalized bin coverage, col 3 = total length of bin, col 4 = total number of contigs for bin.\n\n";
    exit;
}
