#! /usr/bin/perl -w

## (See usage below for description.)

# Then print the total estimated time for the simulation, too.
# (Requires average time of a single run.)

use strict;

#print "ARGV: @ARGV\n";
&usage if $#ARGV < 1;

my $nodes = shift;
my $filename_prefix = shift;

my @params = @{&readParamFile};

# Display data structure
# Calculate total number of runs
my $steps = 1;
foreach my $param (@params) {
  my %param = %$param;
  print "Param: ", %param, "\n";
  $steps *= $param{steps};
}

print "" . ($#params + 1) . " parameters. $steps total number of simulations.\n";

# Count to steps and put into separate param files
my $count_per_node = int($steps / $nodes + 0.5 ); # Round up
for (my $i = 0; $i < $steps; $i++ ) {
  if ( $i % $count_per_node == 0 ) {
    close OFILE if $i != 0;
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
  my $orig_count = $count;
  
  my $param_row = "";
  foreach my $param (@params) {
    my %param = %$param;
    my $param_step = $count % $param{steps};
    #print "Param $param{name}, val=", $param_step, "\n";
    my $param_val;
    if (exists $param{range_low}) { # Linear increment parameter
      if ( $param{steps} == 1) {
	$param_val = $param{range_low};
      } else {
	$param_val = $param{range_low} + 
	  $param_step * ($param{range_high} - $param{range_low}) / 
	    ( $param{steps} - 1); # inclusive
      }
    } elsif (exists $param{base}) { # Geometric increment parameter
      $param_val = $param{base} * pow($param{mult}, $param_step);
    } elsif (exists $param{start}) { # counter
      $param_val = $param{start} + $orig_count;
    } else {
      die "Invalid parameter: $param\n";
    }
    $param_row .= $param_val . " ";
    $count /= $param{steps};
  }
  $_ = $param_row . "0\n";
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

# Returns the power of a number
sub pow {
  my $base = shift;
  my $power = shift;

  $_ = exp($power * log($base));
}

sub readParamFile {
  my @params;

  # Read std input
  while (<>) {
    next if /^\s*#/;		# Skip comment inputs.
    if (/(\w+)\s+([\.\-\w]+)([\*\s]+)([\.\-\w]+)([\^\s]+)(\w+)/) {
      print "Name: '$1', '$2'$3'$4'$5'$6'\n";
      my $name = $1;
      my $base = $2;
      my $top = $4;
      my $steps = $6;
      $_ = $3;
      if (/\*/) {
	push @params, { name => "$name", base => $base,
			mult => $top, steps => $steps };
      } else {
	push @params, { name => "$name", range_low => $base,
			range_high => $top, steps => $steps };
      }
    } elsif ((/(\w+)\s+([\.\-\w]+)\s*\+\+\s*([\.\-\w]*)/)) {
      print "Name: '$1', '$2'++ '$3'\n";
      push @params, { name => "$1", start => $2,
		      increment => $3, steps => 1 };
    }
  }

  $_ = \@params;
}

sub usage {
  print << "END";
 Usage:
	$0 num_CPUs param_file_prefix

 Generates N Genesis parameter files, one for each CPU, to scan
 a full parameter range. Each parameter is changed
 to a fixed number of steps within its range.

 Parameter ranges come from an input file with a row for each param.
 It can have the following forms:
 1. Additive increments
 	param_name range_low range_high num_steps
 2. Multiplicative increments
 	param_name base_val *mul_factor ^num_steps
 3. Independent counter (indicates trial number)
	param_name start_val ++ [increment]

 The parameters are written with order of appearance to Genesis files.

 Cengiz Gunay <cgunay\@emory.edu>, 2004/05/15

END

    exit -1;
}
