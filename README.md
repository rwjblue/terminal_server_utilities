Usage: terminal_server [options]
    -a, --all                        List all users on all servers.
    -u, --user USER                  List or shadow for a specific user only.
    -s, --shadow                     Shadow a user. (requires --user)
    -r, --reset                      Terminate a users session immediately.  (requires --user)
    -l, --logoff                     Logoff a users session.  (requires --user)
    -d, --disconnect                 Disconnect a users session.  (requires --user)
    -m, --message MESSAGE            Message a user.  (requires --user or --all)
    -v, --verbose