function jump_between {
    next_path=$(tail -n 1 $out_file)
    perl ds_engine.pl --update-previous $(pwd)
    echo "next:  $next_path"
    cd $next_path
}

out_file=$(mktemp);
perl ds_engine.pl $@ > $out_file
command_type=$(head -n 1 $out_file)

if [ $# -eq 0 ]; then
    jump_between
fi

#echo $command_type

rm $out_file    