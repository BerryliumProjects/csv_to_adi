use POSIX qw(strftime);
use strict;
use warnings;

my ($infile, $outfile) = @ARGV;

unless ($outfile) {
   ($infile =~ /\.csv$|\.txt/) or die "Input file should be .csv or .txt\n"; 
   $outfile = $infile;
   $outfile =~ s/\..*?$/.adi/;
   printf "Output file: %s\n", $outfile;
}

(open IN, "<$infile") or die "Missing input file $infile\n";

# input file should be comma or tab separated file with headers at the top

(open OUT, ">$outfile") or die "Could not open $outfile for update\n";

print OUT "ADIF format file created from spreadsheet\n";

my $timestamp = strftime("%Y%m%d %H%M%S", localtime);

print OUT "<adif_ver:5>3.1.1\n";
printf OUT "<created_timestamp:15>%s\n", $timestamp;
printf OUT "<eoh>\n\n";

my $headerline = <IN>;
chomp $headerline;
my @fieldnames = split /[,\t]/, $headerline;
my $fieldcnt = scalar(@fieldnames);

my $recordcnt = 0;
while (my $record = <IN>) {
   chomp $record; # remove newline and trim
   last if length($record) == 0;
   $recordcnt++;
   my @fields = split /[,\t]/, $record;

   for (my $fieldix = 0; $fieldix < $fieldcnt; $fieldix++) {
      my $field = $fields[$fieldix]; 
      my $fieldlen = length($field);
      next unless $fieldlen; # catches null and 0
      printf OUT "<%s:%i>%s ", $fieldnames[$fieldix], $fieldlen, $field;
   }

   print OUT "<eor>\n";
}

close IN;
close OUT;
printf "%i records written to %s\n", $recordcnt, $outfile;

# example record output:
#<call:5>K5TIA <gridsquare:0> <mode:4>MFSK <submode:3>FT4 <rst_sent:2>1D <rst_rcvd:2>1D <qso_date:8>20220625 <time_on:6>210124 <qso_date_off:8>20220625 <time_off:6>210124 <band:3>20m <freq:9>14.081946 <station_callsign:5>W9MDB <my_gridsquare:6>EM49HV <contest_id:14>ARRL-FIELD-DAY <SRX_STRING:6>1D STX <class:2>1D <arrl_sect:3>STX <eor>

