#! /usr/bin/perl -w

## (See usage below for description.)

use strict;

&usage if $#ARGV < 1;

my $param_file = shift;
my $param_desc_file = shift;
my $check_exists_script;

if ($#ARGV >= 0) {
  $check_exists_script = shift;
} else {
  $check_exists_script = "checkParamValGenesisFile";
}

my $prefix = '';
my $suffix = '';

if ($#ARGV >= 0) {
  $prefix = shift;
  $suffix = shift if ($#ARGV >= 0);
}

# Open the description file first
open DFILE, "<$param_desc_file"
  or die "Fatal: Cannot open $param_desc_file for reading.\n";

# Read all lines from file
my @param_names;
while (<DFILE>) {
  next if /^\s*#/;		# Ignore remarks
  my $param_name = $1 if /^(\w+)/;
  push @param_names, $param_name;
}

print STDERR "Params: @param_names\n";

# Open Genesis file
open GFILE, "<$param_file"
  or die "Fatal: Cannot open $param_file for reading.\n";

# Skip first line
my $first_line = <GFILE>;

# Read all lines from file
my @param_lines;
while (<GFILE>) {

  my @param_vals = split /\s+/;
  my $param_vals_wo_last = $1 if /^(.*)\s+[01]+\s*$/;
  my $check_command = 
    "$check_exists_script " . ($#param_names + 1) . " @param_names $param_vals_wo_last " .
      "$prefix $suffix";
  #print STDERR "Exec: $check_command\n";

  if (system($check_command) == 0) {
    $param_vals[$#param_vals] = 1; # Exists
  } else {
    $param_vals[$#param_vals] = 0; # Missing
    #print join(' ', @param_vals), "\n";
    push @param_lines, join(' ', @param_vals);
  }
}

# New first line for Genesis file
print $#param_lines + 1, " ", $#param_names + 1, "\n";

# Spit out the missing lines
foreach my $line (@param_lines) {
  print "$line\n";
}

# Et voila!
# -Fin

sub usage {
  print << "END";
 Usage:
	$0 param_file param_desc_file [check_exists_script [prefix [suffix]]] > new_param_file

 Scans the GENESIS-style parameter file and looks for output files in
 the current directory. It needs the param_desc_file for the names
 of the parameters used to generate the output files. 

 The optional check_exists_script should return successfully if a file
 exists given a list of parameters from the parameter file. It should
 generate the file name as would the gensis script and then check for
 its existence. The optional prefix and suffix are passed to the
 check_exists_script.

 Cengiz Gunay <cgunay\@emory.edu>, 2004/10/07

END

    exit -1;
}
