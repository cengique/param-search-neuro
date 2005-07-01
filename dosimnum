#!/usr/bin/perl -W

use Fcntl;
use DB_File;

if ($#ARGV < 1) {
  print "Error: arguments missing.\n\n";
  &usage;
  exit -1;
}

my $parfile = shift;
my $row_num = shift;

die "Row numbers start from 1!" if $row_num < 1;

my $dbfilename = "$parfile.db";

tie(%param_rows, DB_File, $dbfilename, O_RDONLY, 0666, $DB_HASH ) or
  die "Cannot access the parameter database $dbfilename:\n$!\n\n";

# read parameter row
print $param_rows{$row_num};

untie %param_rows;

sub usage {
  print "Usage: $0 parameter_file row_num\n\n" .
    "Reads a row from the parameter database using a hash-based \n" .
      "access without searching all rows. Run create_perlhash_param_db \n" .
	"to initialize the database file from a text-based parameter file.\n" .
	"Row numbers start from 1.\n";
}
