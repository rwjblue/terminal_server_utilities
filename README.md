Command Line Usage
==================
    Usage: terminal_server [options]
    -a, --all                        List all users on all servers.
        --server-file FILENAME       Read list of servers from a file (each servername should be on a single line).
        --server SERVERNAME          Initialize a server instance.
    -u, --user USER                  List or shadow for a specific user only.
    -s, --shadow                     Shadow a user. (requires --user)
    -r, --reset                      Terminate a users session immediately.  (requires --user)
    -l, --logoff                     Logoff a users session.  (requires --user)
    -d, --disconnect                 Disconnect a users session.  (requires --user)
    -m, --message MESSAGE            Message a single user or all users.  (requires --user or --all)
    -v, --verbose

Library Usage
=============

The TerminalServer class can be used to operate on a single server:

```ruby
  require 'terminal_server'

  ts = TerminalServer.new('servername_goes_here')

  ts.shadow_user(username)
  ts.logoff_user(username)
  ts.reset_user(username)
  ts.logoff_user(username)
  ts.disconnect_user(username)
  ts.message_user(username, message)
```

You can also create a number of TerminalServer instances and call all the same methods on the entire
collection of instantiated servers.

```ruby
  require 'terminal_server'

  ['server01','server02','server03'].each do |name|
    TerminalServer.new(name)
  end

  TerminalServer.shadow_user(username)
  TerminalServer.logoff_user(username)
  TerminalServer.reset_user(username)
  TerminalServer.logoff_user(username)
  TerminalServer.disconnect_user(username)
  TerminalServer.message_user(username, message)

```

If a given user has multiple sessions you will be prompted to select which session to operate on:

```
  ruby terminal_server.rb --user robertj --disconnect

  This user is logged into multiple servers. Please select which session you would like to shadow from the list below:
        1. styx                 (Active)
        2. mcag_server_02       (Active)
  >
```

License
=======
This software is licensed under a modified BSD license.

See LICENSE for more details.