#! /usr/bin/perl -w

## (See usage below for description.)

# Then print the total estimated time for the simulation, too.
# (Requires average time of a single run.)

use strict;

my @params;

#print "ARGV: @ARGV\n";
&usage if $#ARGV < 1;
#die "Specify number of nodes on command line!\n" ;
my $nodes = shift;
my $filename_prefix = shift;

# Read std input
while (<>) {
  /(\w+)\s+([\.\-\w]+)\s+([\.\-\w]+)\s+(\w+)/;
  print "Name: '$1', '$2', '$3', '$4'\n";
  push @params, { name => "$1", range_low => $2, range_high => $3, steps => $4 };
}

# Display data structure
# Calculate total number of runs
my $steps = 1;
foreach my $param (@params) {
  my %param = %$param;
  print "Param: ", %param, "\n";
  $steps *= $param{steps};
}

print "$steps total number of simulations.\n";

# Count to steps and put into separate param files
my $count_per_node = int($steps / $nodes + 0.5 ); # Round up
for (my $i = 0; $i < $steps; $i++ ) {
  if ( $i % $count_per_node == 0 ) {
    close OFILE if tell(OFILE) != -1;
    my $filename = $filename_prefix . "_" . int($i / $count_per_node) . ".par";
    open OFILE, ">$filename" or die "Cannot open $filename for writing!\n";
    my $count_left = min($count_per_node, $steps - $i);
    print OFILE "$count_left " . ($#params + 1) . "\n";
  }
  print OFILE paramConf($i);
}
close OFILE if tell(OFILE) != -1;

# Parameter values according to a specific count
sub paramConf {
  my $count = shift;
  
  my $param_row = "";
  foreach my $param (@params) {
    my %param = %$param;
    my $param_step = $count % $param{steps};
    #print "Param $param{name}, val=", $param_step, "\n";
    my $param_val;
    if ( $param{steps} == 1) {
      $param_val = $param{range_low};
    } else {
      $param_val = $param{range_low} + 
		    $param_step * ($param{range_high} - $param{range_low}) / 
		    ( $param{steps} - 1); # inclusive
    }
    $param_row .= $param_val . " ";
    $count /= $param{steps};
  }
  $_ = $param_row . " 0\n";
}

# Returns the minimum of two values
sub min {
  my $a = shift;
  my $b = shift;

  if ( $a >= $b ) {
    $_ = $b;
  } else {
    $_ = $a;
  }
}

sub usage {
  print << "END";
 Usage:
	$0 num_CPUs param_file_prefix

 Generates N Genesis parameter files, one for each CPU, to scan 
 a full parameter range. Each parameter is changed
 to a fixed number of steps within its range.
 
 Parameter ranges come from an input file a row for each param:
 	param_name range_low range_high num_steps
 The parameters are written with order of appearance to Genesis files.

 Cengiz Gunay <cgunay\@emory.edu>, 2004/05/15

END

    exit -1;
}
