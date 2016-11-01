#!/usr/bin/perl

sub determine_arch
{

local($h) = `hostname | sed 's/qcd2m.../qcd2m/' | sed 's/qcd3g.../qcd3g/' | sed 's/qcd4g.../qcd4g/' | sed 's/qcd3t../qcd3t/' | sed 's/qcd4t../qcd4t/' | sed 's/qcd6n.../qcd6n/' | sed 's/jaguar.*/jaguar/' | sed 's/bigben.*/bigben/' | sed 's/yodjag.*/yodjag/' | sed 's/pion..../pion/' | sed 's/kaon..../kaon/' | sed 's/qcd7n..../qcd7n/' | sed 's/qcd8n.*/qcd8n/' | sed 's/.*ranger.*/ranger/' | sed 's/qcd9q.*/qcd9q/' | sed 's/qcd9g.*/qcd9g/' | sed 's/qcd10q.*/qcd10q/' | sed 's/qcd12m.*/qcd12m/' | sed 's/qcd12s.*/qcd12s/' | sed 's/qcd10g.*/qcd10g/' | sed 's/qcd10i.*/qcd10i/' | sed 's/redstar.*/redstar/' | sed 's/qcd11g.*/qcd11g/' | sed 's/qcd12kmi.*/qcd12kmi/' | sed 's/qcd12k.*/qcd12k/' | sed 's/farm.*/farm/'`; chomp $h;

# Note: do not have 9g or 10g in here - have to handle separately
%Machines = (
    'qcd9q'    => \&ib_9q,
    'qcd10q'   => \&ib_9q,
    'qcd12s'   => \&ib_9q,
    'qcd15'    => \&ib_9q,
    'qcd12m'   => \&ib_9q,
    'farm'     => \&ib_9q,
    'qcd9g'    => \&ib_gpu,
    'qcd10g'   => \&ib_gpu,
    'qcd11g'   => \&ib_gpu,
    'qcd12k'   => \&ib_gpu,
    'qcdgpu'   => \&ib_gpu,
    'redstar'  => \&scalar,
    'qcd10i'   => \&scalar_9q_qmt,
    'qcd12kmi' => \&scalar_9q_qmt,
    'jaguar'   => \&ornl_xt3,
    'yodjag'   => \&ornl_xt3,
    'ranger'   => \&ranger,
    'bigben'   => \&psc_xt3,
    'kaon'     => \&fnal_ib4,
    'pion'     => \&fnal_ib,
);

if ($Machines{$h}) {
    $Machines{$h}->();
}
else
{
    printf "$0 : unknown machine  $h";
    exit(1);
}

}

sub gigE
{
    local($conf) = "/etc/qmp/4g/8x8x4";
    $run = "/usr/local/qmp/bin/QMP_run.gige --qmp-rsh remsh --qmp-f ${conf}/3d_conf_l --qmp-l ${conf}/3d_list_l ";
    $arch = "gigE";
}

sub ib
{
    my $PBS_NODEFILE = (exists $ENV{'PBS_NODEFILE'} ? $ENV{'PBS_NODEFILE'} : '~/ib.conf');

    my $np = `cat $PBS_NODEFILE | wc -l |awk '{print $NF}'`; chomp $np;
    $run = "/usr/local/mvapich-0.9.8/bin/mpirun_rsh -rsh -np $np -hostfile $PBS_NODEFILE";
    $arch = "ib";
}

sub ib_7n
{
    my $PBS_NODEFILE = (exists $ENV{'PBS_NODEFILE'} ? $ENV{'PBS_NODEFILE'} : '~/ib7n.conf');
    my $np = `cat $PBS_NODEFILE | wc -l |awk '{print $NF}'`; chomp $np;
    $run = "/usr/local/mvapich-0.9.9/bin/mpirun_rsh -rsh -np $np -hostfile $PBS_NODEFILE";

#    $run = "/usr/local/bin/mpiexec";
    $arch = "ib7n";
}

sub ib_9q
{
    my $PBS_NODEFILE = (exists $ENV{'PBS_NODEFILE'} ? $ENV{'PBS_NODEFILE'} : '~/ib9q.conf');
    my $np = `cat $PBS_NODEFILE | wc -l |awk '{print $NF}'`; chomp $np;
    $run = "/usr/mpi/gcc/mvapich2-1.8/bin/mpirun_rsh -rsh -np $np -hostfile $PBS_NODEFILE";

    $arch = "ib9q";
}

sub ib_gpu
{
    my $PBS_NODEFILE = (exists $ENV{'PBS_NODEFILE'} ? $ENV{'PBS_NODEFILE'} : '~/ib9q.conf');
    my $np = `cat $PBS_NODEFILE | wc -l |awk '{print $NF}'`; chomp $np;
    #$run = "/usr/mpi/gcc/mvapich2-1.8/bin/mpirun_rsh -rsh -np $np -hostfile $PBS_NODEFILE";
    $run = "mpirun -np $np -hostfile $PBS_NODEFILE";

    $arch = "cuda";
}

sub fnal_ib
{
    my $PBS_NODEFILE = (exists $ENV{'PBS_NODEFILE'} ? $ENV{'PBS_NODEFILE'} : '~/ib.conf');
    
    my $np = `cat $PBS_NODEFILE | wc -l |awk '{print $NF}'`; chomp $np;
    $run = "/usr/local/mvapich/bin/mpirun_rsh -rsh -np $np -hostfile $PBS_NODEFILE";
    $arch = "ib";
}

sub fnal_ib4
{
    my $PBS_NODEFILE = (exists $ENV{'PBS_NODEFILE'} ? $ENV{'PBS_NODEFILE'} : '~/ib.conf');
    
    my $np = `cat $PBS_NODEFILE | wc -l |awk '{print $NF}'`; chomp $np;
    $np *= 4;     # These opteron nodes require manually firing up 4 independent mpi processes
    $run = "/usr/local/mvapich/bin/mpirun_rsh -rsh -np $np";
    $arch = "ib";
}

sub ranger
{
    $run = "/share/sge/default/pe_scripts/ibrun";
    $arch = "sun-const";
}

sub ornl_xt3
{
    $run = "yod";
    $arch = "xt3";
}

sub psc_xt3
{
    $run = "pbsyod";
    $arch = "xt3";
}

sub scalar
{
    $run = "";
    $arch = "scalar";
}

sub cuda
{
    $run = "env QMT_NUM_THREADS=8";
    $arch = "cuda";
}

sub scalar7n
{
    $run = "";
    $arch = "scalar7n";
}

sub scalar_7n_qmt
{
    $run = "";
    $arch = "scalar-7n-qmt";
}

sub scalar_9q_qmt
{
    $run = "";
    $arch = "scalar-9q-qmt";
}

sub myrinet
{
    my $PBS_NODEFILE = (exists $ENV{'PBS_NODEFILE'} ? $ENV{'PBS_NODEFILE'} : '~/gm.conf');
    
    my $np = `cat $PBS_NODEFILE | wc -l | awk '{print $NF}'`; chomp $np;
    $run = "/usr/local/mpich-gm-1.2.5/bin/mpirun -np $np -machinefile $PBS_NODEFILE";
    $arch = "gm";
}

1;

