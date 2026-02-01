#import "POSIX";
#import "Basic";
#import "String";

main :: () {
    args := get_command_line_arguments();
    array_unordered_remove_by_index(*args, 0);

    is_verbose, verbose_arg_index := array_find(args, "-l");
    if is_verbose array_unordered_remove_by_index(*args, verbose_arg_index);

    if args.count > 1 {
        print("Too many arguments provided.\n");
        return;
    }

    user_provided_directory := args.count > 0;        
    directory_name := ifx user_provided_directory then args[0] else ".";

    dir := opendir(to_c_string(directory_name));
    if !dir {
        print("Could not open directory '%'.\n", directory_name);
        return;
    }

    filenames : [..] string;
    
    while d := readdir(dir) array_add(*filenames, to_string(d.d_name));

    print("%\n", AssembleFileList(filenames, is_verbose));
}

AssembleFileList :: (filenames : [] string, is_verbose : bool) -> string {
    builder : String_Builder;
    init_string_builder(*builder);

    stat_struct : stat_t;

    for filenames {
        if is_verbose {
            stat(to_c_string(it), *stat_struct);
            print_to_builder(*builder, "%\t", stat_struct.st_dev);
        }
        print_to_builder(*builder, "%\n", it);
    }

    return builder_to_string(*builder);
}
