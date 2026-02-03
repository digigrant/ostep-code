#import "POSIX";
#import "Basic";

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

TIME_BUFFER_SIZE :: 256;

FormatTime :: (time : *timespec, format : string) -> formatted_time : string {
    local_time := localtime(*(time.tv_sec));
    
    buffer : string = ---;
    buffer.data = talloc(TIME_BUFFER_SIZE);
    buffer.count = xx strftime(buffer.data, TIME_BUFFER_SIZE, to_c_string(format), local_time);
    
    return buffer;
}
