#import "POSIX";
#import "POSIX_Extra";
#import "Basic";

TIME_FORMAT :: "%Y-%m-%d %H:%M:%S";

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

    print_to_builder(*builder, "Access: %.%\n", FormatTime(*st_atime, TIME_FORMAT), st_atime.tv_nsec);
    print_to_builder(*builder, "Modify: %.%\n", FormatTime(*st_mtime, TIME_FORMAT), st_mtime.tv_nsec);
    print_to_builder(*builder, "Change: %.%\n", FormatTime(*st_ctime, TIME_FORMAT), st_ctime.tv_nsec);
    print_to_builder(*builder, "%: %.%\n", FormatNameFixedLength("Birth", 6), FormatTime(*st_atime, TIME_FORMAT), st_atime.tv_nsec);
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

FormatNameFixedLength :: (name : string, len : int) -> string {
    result : string = ---;
    result.data = alloc(len);
    result.count = len;
    memset(result.data, #char " ", len);
    
    for 0..name.count-1 result.data[result.count-1-it] = name.data[name.count-1-it];
    return result;
}
