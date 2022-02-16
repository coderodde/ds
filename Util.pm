package Util;

use constant {
    SORT_BY_TAGS           => "tags",
    SORT_BY_DIRS           => "dirs",
    TAG_FILE_NAME          => "tags",
    
    OPERATION_SWITCH       => "switch_directory",
    OPERATION_NOP          => "nop",
    OPERATION_MSG          => "msg",
    OPERATION_LIST         => "list",
    
    PREVIOUS_DIRECTORY_TAG => "__PREV__",
    
    COMMAND_ADD_SHORT      => "-a",
    COMMAND_ADD_LONG       => "--add-tag",
    COMMAND_ADD_WORD       => "add",
    
    COMMAND_REMOVE_SHORT   => "-r",
    COMMAND_REMOVE_LONG    => "--remove-tag",
    COMMAND_REMOVE_WORD    => "remove",
};

1;  