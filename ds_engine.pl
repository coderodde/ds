#!/usr/bin/perl
use warnings;
use strict;
use Cwd;
use File::HomeDir;

require File::Temp;

BEGIN { 
    unshift @INC, File::HomeDir->my_home . "/.ds";
}

use DSConstants;
use DirectoryTagEntry;
use DirectoryTagEntryList;
use File::Temp ();

sub show_tag_list {
    my $list = shift;
    my ($show_dirs, $sorted) = @_;
    
    if ($sorted) {
        $list->sort(DSConstants::SORT_BY_TAGS);
    }
    
    if ($show_dirs) {
         $list->print_tags_and_dirs();
    } else {
         $list->print_tags();
    }                               
}

sub show_tag_list_sorted_by_dirs {
    my $list = shift;
    $list->sort(DSConstants::SORT_BY_DIRS);
    $list->print_dirs_and_tags();
}

sub process_jump_to_previous {
    my $list = shift;
    my $previous_dir_tag = $list->get_previous_directory();
    
    print DSConstants::OPERATION_SWITCH, "\n";
    
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

    print DSConstants::OPERATION_SWITCH, "\n";
    
    if (not defined $best_tag_entry) {
        print getcwd();
    } else {
        print $best_tag_entry->dir();     
    }
    
    print "\n";
}

sub process_single_arg {
    my $list = $_[0];
    my $flag = $_[1];
    
    if ($flag =~ /^-[lLsSd]$/) {
        for ($flag) {
            $_ eq DSConstants::COMMAND_LIST_TAGS             && show_tag_list($list, 0, 0);
            $_ eq DSConstants::COMMAND_LIST_TAGS_DIRS        && show_tag_list($list, 1, 0);
            $_ eq DSConstants::COMMAND_LIST_SORTED_TAGS      && show_tag_list($list, 0, 1);
            $_ eq DSConstants::COMMAND_LIST_SORTED_TAGS_DIRS && show_tag_list($list, 1, 1);
            $_ eq DSConstants::COMMAND_LIST_SORTED_DIRS      && show_tag_list_sorted_by_dirs($list);  
        }
    } else {
        jump_to_tagged_directory($list, $flag);   
    }
}

sub add_tag {
    my ($list, $tag, $dir) = @_;
    my $dup_tag_entry = $list->get_tag_entry($tag);
    
    print DSConstants::OPERATION_MSG, "\n";
    
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
    
    print DSConstants::OPERATION_MSG, "\n";
        
    if (defined $remove_tag_entry) {
        print "Removed tag \"" . $remove_tag_entry->tag() . "\"" .
              " pointing to <" . $remove_tag_entry->dir() . ">";          
    } else {
        print "$tag: no such tag.\n";
    }
}

sub update_previous {
    my $list = shift;
    my $new_dir = shift;
    
    $list->update_previous_directory($new_dir);
    save_list($list);
    print DSConstants::OPERATION_NOP;
}

sub process_double_args {
    my ($list, $cmd, $tag) = @_;

    my $cmd_regex = "^" .
                    DSConstants::COMMAND_ADD_SHORT       . "|" .
                    DSConstants::COMMAND_ADD_LONG        . "|" .
                    DSConstants::COMMAND_ADD_WORD        . "|" .
                    DSConstants::COMMAND_REMOVE_SHORT    . "|" .
                    DSConstants::COMMAND_REMOVE_LONG     . "|" .
                    DSConstants::COMMAND_REMOVE_WORD     . "|" .
                    DSConstants::COMMAND_UPDATE_PREVIOUS . "\$";
    
    if ($cmd !~ /$cmd_regex/) {
        die "$cmd: command not recognized.";
    }
    
    for ($cmd) {
        $_ eq DSConstants::COMMAND_ADD_SHORT && add_tag($list, $tag, getcwd());
        $_ eq DSConstants::COMMAND_ADD_LONG  && add_tag($list, $tag, getcwd());
        $_ eq DSConstants::COMMAND_ADD_WORD && add_tag($list, $tag, getcwd());
        
        $_ eq DSConstants::COMMAND_REMOVE_SHORT && remove_tag($list, $tag);
        $_ eq DSConstants::COMMAND_REMOVE_LONG  && remove_tag($list, $tag);
        $_ eq DSConstants::COMMAND_REMOVE_WORD  && remove_tag($list, $tag);
        
        my $update_dir = $tag;
        
        $_ eq DSConstants::COMMAND_UPDATE_PREVIOUS && update_previous($list, $update_dir);
    }
}

sub process_triple_args {
    my ($list, $cmd, $tag, $dir) = @_;

    my $cmd_regex = "^" .
                    DSConstants::COMMAND_ADD_SHORT . "|" .
                    DSConstants::COMMAND_ADD_LONG  . "|" .
                    DSConstants::COMMAND_ADD_WORD  . "\$";
    
    if ($cmd !~ /$cmd_regex/) {
        print DSConstants::OPERATION_MSG . "\n";
        print "$cmd: command not recognized. ";
        print DSConstants::COMMAND_ADD_SHORT, ", ";
        print DSConstants::COMMAND_ADD_LONG, " or ";
        print DSConstants::COMMAND_ADD_WORD, " expected.";
        exit DSConstants::EXIT_STATUS_BAD_COMMAND;
    }
    
    $list->add_tag_entry($tag, $dir);
}

sub process_multiple_args {
    my $list = shift;
    my $cmd = shift;
    
    my $cmd_regex = "^" .
                    DSConstants::COMMAND_ADD_SHORT . "|" .
                    DSConstants::COMMAND_ADD_LONG  . "|" .
                    DSConstants::COMMAND_ADD_WORD  . "\$";
                    
    if ($cmd !~ /$cmd_regex/) {
        die "Command \"$cmd\" not recognized.";
    }
    
    my $tag = shift;
    my @dir_components = @_;
    my $dir = join " ", @dir_components;
    add_tag($list, $tag, $dir);     
}

sub too_many_args {
    my $count = shift;
    print DSConstants::OPERATION_MSG, "Too many arguments: $count.\n";
    exit DSConstants::EXIT_STATUS_TOO_MANY_ARGS;
}

sub get_temp_tag_file_name {
    my $fh = File::Temp->new(TEMPLATE =>
                             DSConstants::TMP_TAG_FILE_NAME_TEMPLATE);
    return $fh->filename;
}

sub save_list {
    my $list = shift;
    my $temp_tag_file_name = get_temp_tag_file_name();
    $list->write_file($temp_tag_file_name);
    unlink(DSConstants::TAG_FILE_NAME);
    rename $temp_tag_file_name, DSConstants::TAG_FILE_NAME;
}

my $directory_tag_list = DirectoryTagEntryList->new();
$directory_tag_list->read_file(DSConstants::TAG_FILE_NAME);

for (scalar @ARGV) {
    $_ == 0 && process_jump_to_previous($directory_tag_list);
    $_ == 1 && process_single_arg      ($directory_tag_list, @ARGV);
    $_ == 2 && process_double_args     ($directory_tag_list, @ARGV);
    $_ == 3 && process_triple_args     ($directory_tag_list, @ARGV);
    $_  > 3 && process_multiple_args   ($directory_tag_list, @ARGV);
}
