#! /usr/bin/perl -w

## (See usage below for description.)

# Then print the total estimated time for the simulation, too.
# (Requires average time of a single run.)

use strict;

#print "ARGV: @ARGV\n";
&usage if $#ARGV < 0;

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

# Count to steps and put into param file

my $filename = $filename_prefix . ".par";
open OFILE, ">$filename" or die "Cannot open $filename for writing!\n";
print OFILE "$steps " . ($#params + 1) . "\n";
for (my $i = 0; $i < $steps; $i++ ) {
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
	# multiplicative increment
	push @params, { name => "$name", base => $base,
			mult => $top, steps => $steps };
      } else {
	# additive increment
	push @params, { name => "$name", range_low => $base,
			range_high => $top, steps => $steps };
      }
    } elsif ((/(\w+)\s+([\.\-\w]+)\s*\+\+\s*([\.\-\w]*)/)) {
      # counter
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
	$0 param_file_prefix < param_desc_file

 Generates one Genesis parameter file, to scan
 a full parameter range. Each parameter is changed
 to a fixed number of steps within its range.

 Parameter ranges come from an input file param_desc_file with a row for each param.
 It can have the following forms:
 1. Additive increments
 	param_name range_low range_high num_steps
 2. Multiplicative increments
 	param_name base_val *mul_factor ^num_steps
 3. Independent counter (indicates trial number)
	param_name start_val ++ [increment]

 See the examples in the brute_scripts/paramRanges*.txt.

 The parameters are written with order of appearance to Genesis files.

 Cengiz Gunay <cgunay\@emory.edu>, 2004/05/15

END

    exit -1;
}
