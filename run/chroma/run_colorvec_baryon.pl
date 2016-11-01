#!/usr/bin/perl


$, = ' ';		# set output field separator
$\ = "\n";		# set output record separator

die "Usage: $0 <perl param file> <seqno>\n" unless @ARGV == 2;

use File::Basename;
$basedir = dirname($0);

$param_file = shift(@ARGV);
$seqno      = shift(@ARGV);

die "Input parameter file= $param_file  does not exist\n" unless -f $param_file;

require "${basedir}/colorvec_work.pl";
require "$param_file";


&params($seqno);  # Source the parameters. Perl is not strongly typed, so exploit this malfeature.

print "nrow= ", @HMCParam::nrow;
&setup_rng($seqno);


$HMCParam::start_t = ($HMCParam::start_t + $HMCParam::origin) % $HMCParam::nrow[3];
$HMCParam::end_t = ($HMCParam::end_t + $HMCParam::origin) % $HMCParam::nrow[3];


if (defined($ENV{'PBS_O_WORKDIR'}))
{
  chdir($ENV{'PBS_O_WORKDIR'});
}

# Local
my $stem = $HMCParam::stem;

my $eig_db   = $HMCParam::eig_file;
my $baryon_db = $HMCParam::baryon_file;

my $local_baryon_db = "/scratch/${baryon_db}";

my $input  = "${stem}.ini.xml${seqno}";
my $output = "${stem}.out.xml${seqno}";



#
# Build harom input
#
&print_harom_header_xml($input);

# Print the baryonspec
&print_harom_baryon_colorvec($local_baryon_db, $input);
##&print_harom_baryon_colorvec_no_deriv($local_baryon_db, $input);

#if ($HMCParam::mom2_max != 0)
#{
#  &print_harom_baryon_colorvec($local_baryon_db, $input);
#}

&print_harom_trailer_xml($input);

# Run the harom program
system("echo 'Here is /scratch'; /bin/ls -lt /scratch");
&run_program_direct($HMCParam::run, $HMCParam::harom_exe, $input, $output);



###&test_xml(&gzip($output));

&copy_back($HMCParam::remote_baryon_db, $local_baryon_db);

exit(0);

