use std::ffi::CString;
use std::io::{self, Write};

fn execute_command(command: &str) {
    let args: Vec<&str> = command.split_whitespace().collect();

    // fork()
    // -1 Error
    // 0 We are child
    // PID We are the parent
    unsafe {
        let child_pid = libc::fork();

        match child_pid {
            -1 => {
                eprintln!("Error forking)");
            }
            0 => {
                // We are the child
                // execve
                let c_command = CString::new(args[0]).unwrap();
                let c_args: Vec<CString> =
                    args.iter().map(|&arg| CString::new(arg).unwrap()).collect();
                let mut c_args_ptrs: Vec<*const libc::c_char> =
                    c_args.iter().map(|c_str| c_str.as_ptr()).collect();
                c_args_ptrs.push(std::ptr::null());
                libc::execvp(c_command.as_ptr(), c_args_ptrs.as_ptr());
            }
            _ => {
                // We are the parent
                // We must wait till the child is done
                let mut status: libc::c_int = 0;
                libc::waitpid(child_pid, &mut status, 0);
                // Return to main loop
            }
        }
    }
    // exec()
}
fn main() {
    loop {
        // Print
        print!("> ");
        io::stdout().flush().unwrap();

        // Get input from the user
        let mut input = String::new();
        let _ = io::stdin().read_line(&mut input);
        let input = input.trim();

        // Execute
        match input {
            "exit" => {
                break;
            }
            _ => {
                execute_command(input);
            }
        }
    }
}
