#!/usr/bin/perl
use warnings;
use strict;
use lib glob("~/.ds");
use Cwd qw(getcwd);
use File::HomeDir;

use DSConstants;
use DirectoryTagEntry;
use DirectoryTagEntryList;

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
    my $previous_dir = $list->get_previous_directory();

    print DSConstants::OPERATION_SWITCH, "\n";

    if (defined $previous_dir) {
        print $previous_dir;
    } else {
        print getcwd;
    }

    print "\n";
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

sub show_version_info {
    print DSConstants::OPERATION_MSG, "\n";
    print <<"END"
ds (Directory Switcher) 1.6
MIT License

Copyright (c) 2022 Rodion Efremov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

END
}

sub show_help_info {
    print DSConstants::OPERATION_MSG, "\n";
    print <<"END"
Usage: ds
       ds TAG
       ds -a | --add-tag | add TAG [DIR]
       ds -r | --remove-tag | remove TAG [TAG...]
       ds -l | -L | -s | -S | -d

-a | --add-tag | add TAG [DIR]
    Add tag called TAG and point it to DIR.
    If DIR is not specified, point to the current working directory.

-r | --remove-tag | remove TAG [TAG...]
    Remove all the specified tags from the user\'s tag file.

-l
    List all tags in the tag file.

-L
    List all tags and directories in the tag file.

-s
    List all tags in the tag file sorted by tag names.

-S
    List all tags and directories in the tag file sorted by tag names.

-d
    List all directories and tags in the tag file sorted by directories.

TAG
    Switches to the directory tagged with TAG. If there is not TAG in
    the tag file, the closest tag (by Levenshtein distance) is assumed.

[NO ARGS]
    Switch to the previous directory. Issuing this command repeatedly
    allows the user to switch back and forth between two directories.
END
}

sub process_single_arg {
    my $list = $_[0];
    my $flag = $_[1];

    if ($flag =~ /^-[lLsSdvh]|--help|--version$/) {
        for ($flag) {
            $_ eq DSConstants::COMMAND_LIST_TAGS             && show_tag_list($list, 0, 0);
            $_ eq DSConstants::COMMAND_LIST_TAGS_DIRS        && show_tag_list($list, 1, 0);
            $_ eq DSConstants::COMMAND_LIST_SORTED_TAGS      && show_tag_list($list, 0, 1);
            $_ eq DSConstants::COMMAND_LIST_SORTED_TAGS_DIRS && show_tag_list($list, 1, 1);
            $_ eq DSConstants::COMMAND_LIST_SORTED_DIRS      && show_tag_list_sorted_by_dirs($list);
            $_ eq DSConstants::COMMAND_VERSION_SHORT         && show_version_info;
            $_ eq DSConstants::COMMAND_VERSION_LONG          && show_version_info;
            $_ eq DSConstants::COMMAND_HELP_SHORT            && show_help_info;
            $_ eq DSConstants::COMMAND_HELP_LONG             && show_help_info;
        }
    } else {
        jump_to_tagged_directory($list, $flag);
    }
}

sub add_tag {
    my ($list, $tag, $dir) = @_;

    print DSConstants::OPERATION_MSG, "\n";

    if ($tag =~ /\s+/) {
        print "Error: a requested tag contains space characters.\n";
        return;
    }


    my $tag_entry = $list->get_tag_entry($tag);

    if (defined $tag_entry) {
        if ($tag_entry->dir() ne $dir) {
            print "Updating the directory <" . $tag_entry->dir() . "> to <$dir>.";
            $tag_entry->dir($dir);
        } else {
            print "Redirecting the tag \"$tag\" to itself. Nothing changed.";
        }
    } else {
        $list->add_tag_entry($tag, $dir);

        print "Added the tag \"$tag\" to point to\n";
        print "<$dir>.";
    }

    save_list($list);
    print "\n";
}

sub remove_tag {
    my ($list, $tag) = @_;
    my $remove_tag_entry = $list->remove_tag_entry($tag);
    save_list($list);

    print DSConstants::OPERATION_MSG, "\n";

    if (defined $remove_tag_entry) {
        print "Removed tag \"" . $remove_tag_entry->tag() . "\"" .
              " pointing to <" . $remove_tag_entry->dir() . ">.\n";
    } else {
        print "$tag: no such tag.\n";
    }
}

sub update_previous {
    my $list = shift;
    my $new_dir = shift;

    $list->update_previous_directory($new_dir);
    save_list($list);
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
        $_ eq DSConstants::COMMAND_ADD_WORD  && add_tag($list, $tag, getcwd());

        $_ eq DSConstants::COMMAND_REMOVE_SHORT && remove_tag($list, $tag);
        $_ eq DSConstants::COMMAND_REMOVE_LONG  && remove_tag($list, $tag);
        $_ eq DSConstants::COMMAND_REMOVE_WORD  && remove_tag($list, $tag);

        my $update_dir = $tag;

        $_ eq DSConstants::COMMAND_UPDATE_PREVIOUS && update_previous($list, $update_dir);
    }
}

sub process_triple_args {
    my $list = shift;
    my $cmd = shift;
    my $tag = shift;
    my $dir = shift;

    my $cmd_regex = "^" .
                    DSConstants::COMMAND_ADD_SHORT    . "|" .
                    DSConstants::COMMAND_ADD_LONG     . "|" .
                    DSConstants::COMMAND_ADD_WORD     . "|" .
                    DSConstants::COMMAND_REMOVE_SHORT . "|" .
                    DSConstants::COMMAND_REMOVE_LONG  . "|" .
                    DSConstants::COMMAND_REMOVE_WORD  . "\$";

    if ($cmd !~ /$cmd_regex/) {
        print DSConstants::OPERATION_MSG . "\n";
        print "$cmd: command not recognized.";
        print DSConstants::COMMAND_ADD_SHORT, ", ";
        print DSConstants::COMMAND_ADD_LONG, " or ";
        print DSConstants::COMMAND_ADD_WORD, " expected.";
        exit DSConstants::EXIT_STATUS_BAD_COMMAND;
    }

    if ($cmd eq DSConstants::COMMAND_REMOVE_SHORT ||
        $cmd eq DSConstants::COMMAND_REMOVE_LONG ||
        $cmd eq DSConstants::COMMAND_REMOVE_WORD) {
        # $tag contains the first out of two tags to remove:
        print DSConstants::OPERATION_MSG, "\n";
        my $removed_tag_entry = $list->remove_tag_entry($tag);

        if ($removed_tag_entry) {
            print "Removed tag \"" . $tag . "\".\n";
        } else {
            print "No tag \"" . $tag . "\". Omitting.\n";
        }

        $removed_tag_entry = $list->remove_tag_entry($dir);

        if ($removed_tag_entry) {
            print "Removed tag \"" . $dir . "\".\n";
        } else {
            print "No tag \"" . $dir . "\". Omitting.\n";
        }

        save_list($list);
    } else {
        add_tag($list, $tag, $dir);
    }
}

sub process_multiple_args {
    my $list = shift;
    my $cmd = shift;

    my $cmd_regex = "^(" .
                    DSConstants::COMMAND_ADD_SHORT       . "|" .
                    DSConstants::COMMAND_ADD_LONG        . "|" .
                    DSConstants::COMMAND_ADD_WORD        . "|" .
                    DSConstants::COMMAND_REMOVE_SHORT    . "|" .
                    DSConstants::COMMAND_REMOVE_LONG     . "|" .
                    DSConstants::COMMAND_REMOVE_WORD     . "|" .
                    DSConstants::COMMAND_UPDATE_PREVIOUS . "\$)";

    if ($cmd !~ /$cmd_regex/) {
        die "Command \"$cmd\" not recognized.";
    }

    if ($cmd eq DSConstants::COMMAND_REMOVE_SHORT ||
        $cmd eq DSConstants::COMMAND_REMOVE_LONG ||
        $cmd eq DSConstants::COMMAND_REMOVE_WORD) {

        print DSConstants::OPERATION_MSG . "\n";

        my @all_arguments = @_;

        for my $tag_name (@all_arguments) {
            my $tag_entry = $list->remove_tag_entry($tag_name);

            if ($tag_entry) {
                print "Removed \"" . $tag_entry->tag() . "\".\n";
            } else {
                print "No tag \"" . $tag_name . "\ in the tags file. Omitting.\n";
            }
        }

        save_list($list);
        return;
    }

    my @all_arguments = @_;

    my $tag = shift;
    my @dir_components = @_;
    my $dir = join " ", @dir_components;

    if ($1 eq DSConstants::COMMAND_UPDATE_PREVIOUS) {
        my $path = join " ", @all_arguments;
        update_previous($list, $path);
    } else {
        add_tag($list, $tag, $dir);
    }
}

sub save_list {
    my $list = shift;
    $list->write_file(DSConstants::TAG_FILE_NAME);
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
