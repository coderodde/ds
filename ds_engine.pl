#!/usr/bin/perl
use warnings;
use strict;

sub show_tag_list {
    my ($show_dirs, $sorted) = @_;
    print "dirs: $show_dirs, sorted: $sorted\n";
}

sub show_tag_list_sorted_by_dirs {
    print "by dirs\n";
}

sub process_jump_to_previous {
    
}

sub jump_to_tagged_directory {
    print "cd .";
}

sub process_single_arg {
    my ($arg) = @_;
    
    if ($arg =~ /^-[lLsSd]$/) {
        for ($arg) {
            $_ eq "-l" && show_tag_list(0, 0);
            $_ eq "-L" && show_tag_list(1, 0);
            $_ eq "-s" && show_tag_list(0, 1);
            $_ eq "-S" && show_tag_list(1, 1);
            $_ eq "-d" && show_tag_list_sorted_by_dirs();
        }
    } else {
        jump_to_tagged_directory($arg);   
    }
}

sub process_double_args {
    my ($arg1, $arg2) = @_;
    
}

sub process_triple_args {
    my ($arg1, $arg2, $arg3) = @_;

}

if (scalar @ARGV > 3) {
    print STDERR "Too many arguments!";
    exit 1;
}

for (scalar @ARGV) {
    $_ == 0 && process_jump_to_previous;
    $_ == 1 && process_single_arg  @ARGV;
    $_ == 2 && process_double_args @ARGV;
    $_ == 3 && process_triple_args @ARGV;
}