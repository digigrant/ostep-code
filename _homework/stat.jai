#import "POSIX";
#import "Basic";

main :: () {
    stat_struct : stat_t;
    stat(to_c_string("stat.jai"), *stat_struct);
    print("%\n", stat_struct);

    using stat_struct;
    print("File: %\n", "stat.jai");
    print("Size: %\tBlocks: %\tIO Block: %\t%\n", st_size, st_blocks, st_blksize, GetFileTypeFromMode(st_mode));
    print("Device: %\tInode: %\tLinks: %\n", st_dev, st_ino, st_nlink);
    print("Access: (%/%)\tUid: (%/%)\tGid: (%/%)\n", st_dev, GetAccessString(st_mode), st_uid, "grant", st_gid, "grant");
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
