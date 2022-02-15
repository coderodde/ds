#!/usr/bin/perl
use warnings;
use strict;
BEGIN { unshift @INC, '.'; }
use DirectoryTagEntry;
use DirectoryTagEntryList;
use Cwd;

my $tag_file_name = "tags";

sub show_tag_list {
    my ($show_dirs, $sorted) = @_;
    print "dirs: $show_dirs, sorted: $sorted\n";
}

sub show_tag_list_sorted_by_dirs {
    print "by dirs\n";
}

sub process_jump_to_previous {
    print "jump to prev!\n";
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

sub add_tag {
    my ($tag, $dir) = @_;
    print "add tag $tag $dir\n";
}

sub remove_tag {
    my ($tag) = @_;
    print "remove tag $tag\n";
}

sub update_previous {
    my ($new_dir) = @_;
    print "update to $new_dir\n";
}

sub process_double_args {
    my ($cmd, $tag) = @_;
    
    if ($cmd !~ /^-a|--add-tag|add|-r|--remove-tag|remove|--update-previous$/) {
        die "$cmd: command not recognized.";
    }
    
    for ($cmd) {
        $_ eq "-a"        && add_tag($tag, getcwd());
        $_ eq "--add-tag" && add_tag($tag, getcwd());
        $_ eq "add"       && add_tag($tag, getcwd());
        
        $_ eq "-r"           && remove_tag($tag);
        $_ eq "--remove-tag" && remove_tag($tag);
        $_ eq "remove"       && remove_tag($tag);
        
        my $update_dir = $tag;
        
        $_ eq "--update-previous" && update_previous($update_dir);
    }
}

sub process_triple_args {
    my ($cmd, $tag, $dir) = @_;

    if ($cmd !~ /^-a|--add-tag|add$/) {
        die "$cmd: command not recognized.";
    }
    
    add_tag($tag, $dir);
}

if (scalar @ARGV > 3) {
    print STDERR "Too many arguments!";
    exit 1;
}

my $tag = DirectoryTag->new( tag => "home",
                             dir => "/home/rodde" );

my $directory_tag_list = DirectoryTagList->new();
$directory_tag_list->read_file($tag_file_name);
print "LIST ", $directory_tag_list->length(), "\n";

for (scalar @ARGV) {
    $_ == 0 && process_jump_to_previous;
    $_ == 1 && process_single_arg  @ARGV;
    $_ == 2 && process_double_args @ARGV;
    $_ == 3 && process_triple_args @ARGV;
}

$directory_tag_list->update_previous_directory("fds");

#my $ss = "  tag    dir  add ";
#if ($ss =~ /^\s*(\w+)\s+(.*)$/g) {
#    print "1: $1<<\n";
#    print "2: $2<<\n";
#    print "yes";
#} else {
#    print "no";
#}

