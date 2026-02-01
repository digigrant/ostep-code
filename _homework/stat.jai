#import "POSIX";
#import "Basic";

TIME_BUFFER_SIZE :: 256;

MINOR_BITS :: 8;
MINOR_MASK :: (1 << MINOR_BITS) - 1;
Major :: (dev : u64) -> u64 { return xx dev >> MINOR_BITS; }
Minor :: (dev : u64) -> u64 { return xx dev & MINOR_MASK; }

main :: () {
    stat_struct : stat_t;
    stat(to_c_string("stat.jai"), *stat_struct);
    // print("%\n", stat_struct);

    using stat_struct;

    builder : String_Builder;
    init_string_builder(*builder);

    time_buffer : string = ---;
    time_buffer.count = TIME_BUFFER_SIZE;
    time_buffer.data = talloc(TIME_BUFFER_SIZE);
    
    print_to_builder(*builder, "%: %\n", FormatNameFixedLength("File", 6), "stat.jai");

    print_to_builder(*builder, "%: %\t", FormatNameFixedLength("Size", 6), st_size);
    print_to_builder(*builder, "Blocks: %\t", st_blocks);
    print_to_builder(*builder, "IO Block: %\t%\n", st_blksize, GetFileTypeFromMode(st_mode));

    print_to_builder(*builder, "Device: %,%\t", Major(st_dev), Minor(st_dev));
    print_to_builder(*builder, "Inode: %\t", st_ino);
    print_to_builder(*builder, "Links: %\n", st_nlink);

    print_to_builder(*builder, "Access: (%/%)\t", st_uid, GetAccessString(st_mode));
    print_to_builder(*builder, "Uid: (%/%)\t", st_uid, "grant");
    print_to_builder(*builder, "Gid: (%/%)\n", st_gid, "grant");

    print_to_builder(*builder, "Access: %\n", FormatTime(*st_atime, *time_buffer));
    print_to_builder(*builder, "Modify: %\n", FormatTime(*st_mtime, *time_buffer));
    print_to_builder(*builder, "Change: %\n", FormatTime(*st_ctime, *time_buffer));
    print_to_builder(*builder, "%: %\n", FormatNameFixedLength("Birth", 6), FormatTime(*st_atime, *time_buffer));
    write_builder(*builder);
}

GetFileTypeFromMode :: (st_mode : u32) -> type_name : string {
    if st_mode & S_IFMT == {
        case S_IFSOCK;  return "socket";
        case S_IFLNK;   return "symbolic link";
        case S_IFREG;   return "regular file";
        case S_IFBLK;   return "block device";
        case S_IFDIR;   return "directory";
        case S_IFCHR;   return "character device";
        case S_IFIFO;   return "FIFO";
    }

    return "unknown";
}

GetAccessString :: (st_mode : u32) -> access : string {
    access_string : string = ---;
    access_string.data = talloc(10);
    access_string.count = 10;

    if st_mode & S_IFMT == {
        case S_IFLNK;       access_string.data[0] = #char "l";
        case S_IFDIR;       access_string.data[0] = #char "d";
        case;               access_string.data[0] = #char "-";
    }

    access_string.data[1] = xx ifx st_mode & S_IRUSR then #char "r" else #char "-";
    access_string.data[2] = xx ifx st_mode & S_IWUSR then #char "w" else #char "-";
    access_string.data[3] = xx ifx st_mode & S_IXUSR then #char "x" else #char "-";

    access_string.data[4] = xx ifx st_mode & S_IRGRP then #char "r" else #char "-";
    access_string.data[5] = xx ifx st_mode & S_IWGRP then #char "w" else #char "-";
    access_string.data[6] = xx ifx st_mode & S_IXGRP then #char "x" else #char "-";
    
    access_string.data[7] = xx ifx st_mode & S_IROTH then #char "r" else #char "-";
    access_string.data[8] = xx ifx st_mode & S_IWOTH then #char "w" else #char "-";
    access_string.data[9] = xx ifx st_mode & S_IXOTH then #char "x" else #char "-";

    return access_string;
}

FormatTime :: (time : *timespec, buffer : *string) -> formatted_time : string {
    TIME_BUFFER_FORMAT :: "%Y-%m-%d %H:%M:%S";
    local_time := localtime(*(time.tv_sec));
    buffer.count = xx strftime(buffer.data, TIME_BUFFER_SIZE, to_c_string(TIME_BUFFER_FORMAT), local_time);
    
    builder : String_Builder;
    init_string_builder(*builder);
    print_to_builder(*builder, "%.%", buffer.*, time.tv_nsec);
    return builder_to_string(*builder);
}

FormatNameFixedLength :: (name : string, len : int) -> string {
    result : string = ---;
    result.data = alloc(len);
    result.count = len;
    memset(result.data, #char " ", len);
    
    for 0..name.count-1 result.data[result.count-1-it] = name.data[name.count-1-it];
    return result;
}
