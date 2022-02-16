package DSConstants;

use constant {
    SORT_BY_TAGS => "tags",
    SORT_BY_DIRS => "dirs",
    
    TAG_FILE_NAME              => "tags",
    TMP_TAG_FILE_NAME_TEMPLATE => "tags.XXXXX",
    
    OPERATION_SWITCH => "switch_directory",
    OPERATION_NOP    => "nop",
    OPERATION_MSG    => "msg",
    OPERATION_LIST   => "list",
    
    PREVIOUS_DIRECTORY_TAG => "__PREV__",
    
    COMMAND_LIST_TAGS             => "-l",
    COMMAND_LIST_TAGS_DIRS        => "-L",
    COMMAND_LIST_SORTED_TAGS      => "-s",
    COMMAND_LIST_SORTED_TAGS_DIRS => "-S",
    COMMAND_LIST_SORTED_DIRS      => "-d",
    
    COMMAND_HELP_SHORT => "-h",
    COMMAND_HELP_LONG  => "--help",
    COMMAND_HELP_WOORD => "help",
    
    COMMAND_VERSION_SHORT => "-v",
    COMMAND_VERSION_LONG  => "--version",
    COMMAND_VERSION_WORD  => "version",
    
    COMMAND_ADD_SHORT => "-a",
    COMMAND_ADD_LONG  => "--add-tag",
    COMMAND_ADD_WORD  => "add",
    
    COMMAND_REMOVE_SHORT => "-r",
    COMMAND_REMOVE_LONG  => "--remove-tag",
    COMMAND_REMOVE_WORD  => "remove",
    
    EXIT_STATUS_TOO_MANY_ARGS => 1,
    EXIT_STATUS_BAD_COMMAND   => 2
    
};

1;  