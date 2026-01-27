#import "Compiler";
#import "Metaprogram_Plugins";
#import "Basic";
#import "File";

plugins : [..] *Metaprogram_Plugin;

#run,stallable {
    w := compiler_create_workspace();
    set_build_options_dc(.{do_output = false});

    args := get_build_options().compile_time_command_line;
    ok:, plugins_to_create:, args = parse_plugin_arguments(args);
    assert(ok, "failed to parse plugins");
    ok = init_plugins(plugins_to_create, *plugins, w);
    assert(ok, "plugin failed to init");

    {
        options := get_build_options(w);
        options.output_type = .EXECUTABLE;
        options.output_executable_name = "stat";

        if make_directory_if_it_does_not_exist("build") {
            options.output_path = "build";
        }

        set_build_options(options, w);

        // begin intercept
        intercept_flags : Intercept_Flags;
        for plugins if it.before_intercept it.before_intercept(it, *intercept_flags);
        compiler_begin_intercept(w, intercept_flags);

        // add source
        for plugins if it.add_source it.add_source(it);
        add_build_file("stat.jai", w);

        // handle messages
        message_loop_handler();

        // end intercept
        compiler_end_intercept(w);

        // finish, shutdown
        for plugins if it.finish it.finish(it);
        for plugins if it.shutdown it.shutdown(it);
    }
}

message_loop_handler :: () {
    while true {
        message := compiler_wait_for_message();

        for plugins if it.message it.message(it, message);

        if message.kind == {
            case .COMPLETE; break;
        }
    }
}
