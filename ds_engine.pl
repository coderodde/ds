#!/usr/bin/perl
use warnings;
use strict;     
BEGIN { unshift @INC, '.'; }
use DirectoryTagEntry;
use DirectoryTagEntryList;
use Cwd;
use Util;

sub show_tag_list {
    my $list = shift;
    my ($show_dirs, $sorted) = @_;
    
    if ($sorted) {
        $list->sort(Util::SORT_BY_TAGS);
        
        if ($show_dirs) {
             $list->print_tags_and_dirs();
        } else {
             $list->print_tags();
        }                                            
    }
}

sub show_tag_list_sorted_by_dirs {
    my $list = shift;
    $list->print_dirs_tags();
}

sub process_jump_to_previous {
    my $list = shift;
    my $previous_dir_tag = $list->get_previous_directory();
    
    print Util::OPERATION_SWITCH, "\n";
    
    if (defined $previous_dir_tag) {
        print $previous_dir_tag->dir();
    } else {
        print getcwd;
    }
}

sub jump_to_tagged_directory {
    my $list = shift;
    my $tag = shift;
    my $dir = $list->match($tag);

    print Util::OPERATION_SWITCH, "\n";    
    
    if (not defined $dir) {
        print getcwd, "\n";
    } else {
        print $dir, "\n";     
    }
}

sub process_single_arg {
    my $flag = $_[0];
    my $list = $_[1];
    
    if ($flag =~ /^-[lLsSd]$/) {
        for ($flag) {
            $_ eq "-l" && show_tag_list($list, 0, 0);
            $_ eq "-L" && show_tag_list($list, 1, 0);
            $_ eq "-s" && show_tag_list($list, 0, 1);
            $_ eq "-S" && show_tag_list($list, 1, 1);
            $_ eq "-d" && show_tag_list_sorted_by_dirs($list);
        }
    } else {
        jump_to_tagged_directory($list, $flag);   
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

my $directory_tag_list = DirectoryTagEntryList->new();
$directory_tag_list->read_file(Util::TAG_FILE_NAME);

for (scalar @ARGV) {
    $_ == 0 && process_jump_to_previous($directory_tag_list);
    $_ == 1 && process_single_arg  ($directory_tag_list, @ARGV);
    $_ == 2 && process_double_args ($directory_tag_list, @ARGV);
    $_ == 3 && process_triple_args ($directory_tag_list, @ARGV);
}
