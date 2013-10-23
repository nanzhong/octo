#octo

A lightweight tool for running commands on multiple hosts at the same time.

I found myself getting increasingly frustrated while working with clusters of remote servers. Things like tailing a log on every server, or wanted to grep for something on the entire cluster was very tedious to do.

I tried using pssh (and family) but it was difficult to manage multiple host groups, and small annoyances like leaving commands running on the remote server when pssh was interrupted/killed made them not so much fun to use. So, I created this tool as a quick way for me to be able to manage clusters of similar servers.

## Features

 - Support for Parallel SSH commands [currently only support public key auth, username:password coming)
 - Support for Parallel MySQL commands [working, but needs more testing]
 - Profile/Server cluster management
 - Option for output to files based on remote server [Future]
 - Graceful error handling [Future]
 - Support for timeouts [Future]

## Requirements

Since octo currently only support public key auth, it relies on your user having his ssh keys properly configured and loaded.

## Installation

    gem install octo

## Configuration

octo looks for a `.octorc` file in your home directory. It's a simple yaml file and the best way to explain it would be to give an example

    ---
    ssh:
      test:
      - root@test.server.com
      stage:
      - root@server1.stage.server.com
      - root@server2.stage.server.com
      prod:
      - root@server1.server.com
      - root@server2.server.com
      - root@server3.server.com
      prod_db:
      - root@db1.server.com
      - root@db2.server.com
    mysql:
      test:
      - test:password@test.server.com/db_test
      staging:
      - stage:password@db1.staging.server.com/db_stage
      prod_central:
      - prod_user:superpassword@central.server.com/db_central
      prod_shards:
      - prod_user:superpassword@shard1.server.com/db_shard_1
      - prod_user:superpassword@shard2.server.com/db_shard_2

This file can also be managed on the command line

    $ octo profile <command>
    
    NAME
        profile - Manage profiles
    
    SYNOPSIS
        octo [global options] profile  add profile server
        octo [global options] profile  list [profile]
        octo [global options] profile  rm profile server
    
    DESCRIPTION
        Manage profile that will be used to run commands. Each profile consists of a set of servers.
    
    COMMANDS
        add  - Add a host to a profile
        list - List all profiles
        rm   - Remove a host from a profile

## Using

Running a parallel command in octo is pretty simple, once you have your profiles configured

    octo run <profile> <command>

For example

    $ octo run prod 'tail -n 3 /var/log/messages'
    [root@server1.server.com] Oct 22 03:49:01 server8 auditd[2519]: Audit daemon rotating log files
    [root@server1.server.com] Oct 22 14:57:09 server8 auditd[2519]: Audit daemon rotating log files
    [root@server1.server.com] Oct 23 03:29:01 server8 auditd[2519]: Audit daemon rotating log files
    [root@server2.server.com] Oct 22 07:48:01 server11 auditd[2400]: Audit daemon rotating log files
    [root@server2.server.com] Oct 22 21:10:01 server11 auditd[2400]: Audit daemon rotating log files
    [root@server2.server.com] Oct 23 12:50:01 server11 auditd[2400]: Audit daemon rotating log files
    [root@server3.server.com] Oct 20 11:40:11 server12 kernel: possible SYN flooding on port 9000. Sending cookies.
    [root@server3.server.com] Oct 21 11:55:49 server12 auditd[2645]: Audit daemon rotating log files
    [root@server3.server.com] Oct 22 12:53:01 server12 auditd[2645]: Audit daemon rotating log files

Of course you can also do things like

    $ octo run prod 'tail -f /var/log/nginx/error.log | grep search' # piping on the remote boxes
    
    $ octo run prod 'tail -f /var/log/nginx/error.log' | grep string # also works locally, but obviously slower
    
    $ octo run prod 'ruby script.rb' > stdout.log 2> stderr.log # stdout and stderr are preserved
    
Octo also has experimental support for running queries in parallel

    $ octo -m mysql run prod_shards 'select username, email, first_name, last_name from users where username like "nan.%"'

    Running query on prod_user:superpassword@shard1.server.com/db_shard_1... 1 results
    +-------------+-------------------------+------------+--------------+
    | username    | email                   | first_name | last_name    |
    +-------------+-------------------------+------------+--------------+
    | nan.test    | nan.test@mailinator.com | New        | Test User    |
    +-------------+-------------------------+------------+--------------+
    Running query on prod_user:superpassword@shard2.server.com/db_shard_2... 3 results
    +------------+---------------------------+------------+-----------+
    | username   | email                     | first_name | last_name |
    +------------+---------------------------+------------+-----------+
    | nan.814    | nan.814@mailinator.com    | bla        | bla       |
    | nan.leigh  |                           |            |           |
    | nan.manley | nan.manley@mailinator.com | bla        | bla       |
    +------------+---------------------------+------------+-----------+

## Contribute

Feel free to submit issues and I will try my best to get to them. If you are interested, pull requests are highly welcome. :)

## License

    The MIT License (MIT)
    
    Copyright (c) 2013 Nan Zhong
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
