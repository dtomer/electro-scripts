package System_Specific

use strict;
use warnings;

our $VERSION = '0.1';

=head1 NAME

System_Specific

=head1 SYNOPSIS

    use  lib "$ENV{'HOME'}/bin/lib/
    my $vars= System_Specific->new();
    
=head1 DESCRIPTION

This module takes care of getting info on how to get some system specific commands, as how to submit
a job, where to run things, which scripts to use.
In case a new cluster is added, new information needs to be gathered. I think the best way to do it
is to use the environment variable $HOSTNAME, that should identify the cluster wher ewe're running things 
univocally. 

=begin comment

### Version History ###

0.1   25/08/2015  Identify all the system-sensitive information

sub new{
  
