#! /usr/bin/perl -w

## (See usage below for description.)

use strict;

&usage if $#ARGV < 1;

my $param_file = shift;
my $param_desc_file = shift;

# Open the description file first
open DFILE, "<$param_desc_file"
  or die "Fatal: Cannot open $param_desc_file for reading.\n";

# Read all lines from file
my @param_names;
while (<DFILE>) {
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
  my $n = 0;
  my @name_vals = grep {$_ = $_ . "_" . $param_names[$n]
			  if $n <= $#param_names;
			$n = $n + 1; ($n - 1) <= $#param_names}
    @param_vals;

  # Do it again, because we destroyed it
  @param_vals = split /\s+/;
  my $filename = join('_', @name_vals) . '.bin'; # Extension
  #print STDERR "$filename\n";

  if (-r $filename) {
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
	$0 param_file param_desc_file > new_param_file

 Scans the GENESIS-style parameter file and looks for output files in
 the current directory. It needs the param_desc_file for the names
 of the parameters used to generate the output files. 

 Cengiz Gunay <cgunay\@emory.edu>, 2004/10/07

END

    exit -1;
}
