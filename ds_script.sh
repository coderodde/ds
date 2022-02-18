function jump_between {
    next_path=$(tail -n 1 $out_file)
    perl -I /home/rodde/lib/perl5/site_perl ~/.ds/ds_engine.pl --update-previous $(pwd)
    cd $next_path
}

out_file=$(mktemp);
perl -I /home/rodde/lib/perl5/site_perl ~/.ds/ds_engine.pl $@ > $out_file
command_type=$(head -n 1 $out_file)

if [ $# -eq 0 ]; then
    jump_between
elif [ "$command_type" == "switch_directory" ]; then
    next_path=$(tail -n 1 $out_file)

    if [ ! -d "$next_path" ]; then 
        echo 2> "Directory \"$next_path\" does not exist."
    else 
        ~/.ds/ds_engine.pl --update-previous $(pwd)
        cd $next_path
    fi
elif [ "$command_type" == "list" ]; then 
    tail -n +2 $out_file
elif [ "$command_type" == "msg" ]; then
    tail -n +2 $out_file
fi

rm $out_file