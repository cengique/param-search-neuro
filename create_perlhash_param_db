#!/usr/bin/perl -W

use Fcntl;
use DB_File;

if ($#ARGV < 0) {
  print "Error: arguments missing.\n\n";
  &usage;
  exit -1;
}

my $param_file = shift;
my %param_rows;

my $dbfilename = "$param_file" . ".db";

tie(%param_rows, DB_File, $dbfilename, O_RDWR|O_CREAT, 0666, $DB_HASH ) or
  die "Cannot create the parameter database $dbfilename: \n$!\n";

# Open Genesis file
open GFILE, "<$param_file"
  or die "Fatal: Cannot open $param_file for reading.\n";

# Read the first line (useless)
$_ = <GFILE>;

die "Cannot read number of rows and parameters from file $param_file.\n" 
  unless (/(\d+)\s+(\d+)/);

my $num_rows = $1;
my $num_params = $2;

print "$num_rows rows and $num_params parameters in file $param_file.\n";

# Loop over all lines
my $row_num = 1;
while (<GFILE>) {
  # Save the whole row in the hash bucket
  $param_rows{$row_num++} = $_;
}

#Commit to db file
untie %param_rows;

sub usage {
  print "Usage: $0 parameter_file\n\n" .
    "Creates a parameter database that uses a hash-based \n" .
      "access without needing to search all rows. The database would\n" .
	"consist of files with .dir and .pag appended the original parameter file name.\n\n";
}
