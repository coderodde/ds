#!/usr/bin/perl
use warnings;
use strict;     
BEGIN { unshift @INC, '.'; }
use DirectoryTagEntry;
use DirectoryTagEntryList;
use Cwd;
use File::Temp qw/ tempfile /;
use Util;

sub show_tag_list {
    my $list = shift;
    my ($show_dirs, $sorted) = @_;
    
    if ($sorted) {
        $list->sort(Util::SORT_BY_TAGS);
    }
    
    if ($show_dirs) {
         $list->print_tags_and_dirs();
    } else {
         $list->print_tags();
    }                               
}

sub show_tag_list_sorted_by_dirs {
    my $list = shift;
    $list->sort(Util::SORT_BY_DIRS);
    $list->print_dirs_and_tags();
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
    my $best_tag_entry = $list->match($tag);

    print Util::OPERATION_SWITCH, "\n";    
    
    if (not defined $best_tag_entry) {
        print getcwd, "\n";
    } else {
        print "cd ", $best_tag_entry->dir(), "\n";     
    }
}

sub process_single_arg {
    my $list = $_[0];
    my $flag = $_[1];
    
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
    my ($list, $tag, $dir) = @_;
    my $dup_tag_entry = $list->get_tag_entry($tag);
    
    print Util::OPERATION_MSG, "\n";
    
    if ($dup_tag_entry) {
        print "Updating the tag \"$tag\" to point from\n<",
              $dup_tag_entry->dir(),
              ">to\n<$dir>\n";
              
        $dup_tag_entry->dir($dir);
    } else {
        print "Added the tag \"$tag\" to point to \n",
              "<$dir>.\n";
              
        $list->add_tag_entry($tag, $dir);
    }
    
    save_list($list);
}

sub remove_tag {
    my ($list,, $tag) = @_;
    my $remove_tag_entry = $list->remove_tag_entry($tag);
    save_list($list);
    
    print Util::OPERATION_MSG, "\n";
        
    if (defined $remove_tag_entry) {
        print "Removed tag \"" . $remove_tag_entry->tag() . "\"" .
              " pointing to <" . $remove_tag_entry->dir() . ">";          
    } else {
        print "$tag: no such tag.\n";
    }
}

sub update_previous {
    my ($new_dir) = @_;
    print "update to $new_dir\n";
}

sub process_double_args {
    my ($list, $cmd, $tag) = @_;
    
    if ($cmd !~ /^-a|--add-tag|add|-r|--remove-tag|remove|--update-previous$/) {
        die "$cmd: command not recognized.";
    }
    
    for ($cmd) {
        $_ eq "-a"        && add_tag($list, $tag, getcwd());
        $_ eq "--add-tag" && add_tag($list, $tag, getcwd());
        $_ eq "add"       && add_tag($list, $tag, getcwd());
        
        $_ eq "-r"           && remove_tag($list, $tag);
        $_ eq "--remove-tag" && remove_tag($list, $tag);
        $_ eq "remove"       && remove_tag($list, $tag);
        
        my $update_dir = $tag;
        
        $_ eq "--update-previous" && update_previous($update_dir);
    }
}

sub process_triple_args {
    my ($list, $cmd, $tag, $dir) = @_;

    if ($cmd !~ /^-a|--add-tag|add$/) {
        print Util::OPERATION_MSG . "\n";
        print "$cmd: command not recognized. ";
        print Util::COMMAND_ADD_SHORT, ", ";
        print Util::COMMAND_ADD_LONG, " or ";
        print Util::COMMAND_ADD_WORD, " expected.";
        exit Util::EXIT_STATUS_BAD_COMMAND;
    }
    
    $list->add_tag_entry($tag, $dir);
}

sub too_many_args {
    my $count = shift;
    print Util::OPERATION_MSG, "Too many arguments: $count.\n";
    exit Util::EXIT_STATUS_TOO_MANY_ARGS;
}

sub get_temp_tag_file_name {
    return tempfile();
}

sub save_list {
    my $list = shift;
    my $temp_tag_file_name = get_temp_tag_file_name();
    $list->write_file($temp_tag_file_name);
    unlink(Util::TAG_FILE_NAME);
    rename $temp_tag_file_name, Util::TAG_FILE_NAME;
}

my $directory_tag_list = DirectoryTagEntryList->new();
$directory_tag_list->read_file(Util::TAG_FILE_NAME);

for (scalar @ARGV) {
    $_ == 0 && process_jump_to_previous($directory_tag_list);
    $_ == 1 && process_single_arg      ($directory_tag_list, @ARGV);
    $_ == 2 && process_double_args     ($directory_tag_list, @ARGV);
    $_ == 3 && process_triple_args     ($directory_tag_list, @ARGV);
    $_  > 3 && too_many_args           (scalar @ARGV);
}
