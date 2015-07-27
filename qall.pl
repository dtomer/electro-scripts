#!/usr/bin/perl

for $i ($ARGV[0]..$ARGV[1]) {system("qdel $i")}
