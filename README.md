BitTorrent Sync
===============

Overview
--------

The btsync module allows you to easily manage BitTorrent Sync instances with Puppet.

Pre-requirement
---------------

If you don't already have a btsync package repository, you can include btsync::repo class, that will configure yeasoft repository for Debian and Ubuntu:

    include btsync::repo


Usage
-----

Just include the `btsync` class:

    include btsync

Launching an instances
----------------------

Declare an instance:

    btsync::instance { 'user':
      storage_path => '/home/user/.sync',
      webui        => {
        listen   => '0.0.0.0:8888',
        login    => 'admin',
        password => 'password',
      }
    }

You can also do it in one step:

    class { 'btsync':
      instances => {
        user => {
          storage_path => '/home/user/.sync',
          webui        => {
            listen   => '0.0.0.0:8888',
            login    => 'admin',
            password => 'password',
          }
        }
      }
    }

You can also store you configuration in hiera:

    ---
    btsync::instances:
      user:
        storage_path: /home/user/.sync
        webui:
          listen: 0.0.0.0:8888
          login: admin
          password: password

And simply include the `btsync` class if you have puppet 3+:

    include btsync

Shared folders
--------------

You can also declare a shared folder:

    btsync::shared_folder { 'MY_SECRET_1':
      instance => 'user',
      dir      => '/home/user/bittorrent/sync_test',
    }

Or in in one step:

    class { 'btsync':
      instances => {
        user => {
          storage_path => '/home/user/.sync',
          webui        => {
            listen   => '0.0.0.0:8888',
            login    => 'admin',
            password => 'password',
          },
          shared_folders => {
            'MY_SECRET_1' => {
              dir => '/home/user/bittorrent/sync_test',
            }
          }
        }
      }
    }

And of course in hiera:

    ---
    btsync::instances:
      user:
        storage_path: /home/user/.sync
        webui:
          listen: 0.0.0.0:8888
          login: admin
          password: password
        shared_folders:
          MY_SECRET_1:
            dir: /home/user/bittorrent/sync_test

Known hosts:
------------

A Btsync::Known_host resource is automatically exported for the given secret key, and every Btsync::Known_host resources matching the given secret key are automatically realized.

You can also declare explicitely a known host resource for a given secret key:

    btsync::known_host { '192.168.1.2:44444':
      secret   => 'MY_SECRET_1',
      instance => 'btsync',
    }

Or in one step:

    class { 'btsync':
      instances => {
        user => {
          storage_path => '/home/user/.sync',
          webui        => {
            listen   => '0.0.0.0:8888',
            login    => 'admin',
            password => 'password',
          },
          shared_folders => {
            'MY_SECRET_1' => {
              dir         => '/home/user/bittorrent/sync_test',
              known_hosts => ['192.168.1.2:44444'],
            }
          }
        }
      }
    }

Or with hiera:

    ---
    btsync::instances:
      user:
        storage_path: /home/user/.sync
        webui:
          listen: 0.0.0.0:8888
          login: admin
          password: password
        shared_folders:
          MY_SECRET_1:
            dir: /home/user/bittorrent/sync_test
            known_hosts: ['192.168.1.2:44444']

This example configures an instance like the sample configuration of BitTorrent Sync 1.1.48:

    ---
    btsync::instances:
      user:
        device_name: My Sync Device
        listening_port: 0
        storage_path: /home/user/.sync
        check_for_updates: true
        use_upnp: true
        download_limit: 0
        upload_limit: 0
        webui:
          listen: 0.0.0.0:8888
          login: admin
          password: password
        shared_folders:
          MY_SECRET_1:
            dir: /home/user/bittorrent/sync_test
            use_relay_server: true
            use_tracker: true
            use_dht: true
            search_lan: true
            use_sync_trash: true
            known_hosts: ['192.168.1.2:44444']

Reference
---------

Classes:

* [btsync](#class-btsync)

Resources:

* [btsync::instance](#resource-btsyncinstance)

###Class: btsync
This class is used to install btsync.

####`version`
The version of BitTorrent Sync to install/manage.

####`enable`
Should the service be enabled during boot time?

####`start`
Should the service be started by Puppet

####`instances`
Hash of instances to run

###Resource: btsync::instance
This resource is used to declare a btsync instance to run.

####`user`
A uid for supplying the user under which the btsync daemon should run. Defaults to resource name.

####`group`
A gid for supplying the group under which the btsync daemon should run. If omitted the daemon will run under the primary group of the user.

####`umask`
The umask for the btsync damon. If omitted the default umask is used.

####`conffile`
Override default configuration file. Defaults to /etc/btsync/$name.conf

####`device_name`
Public name of the device. Defaults to $name.

####`listening_port`
Port the daemon listen to. Defaults to 0 (random port).

####`storage_path`
storage_path dir contains auxilliary app files if no storage_path field: .sync dir created in the directory where binary is located.

####`pid_file`
Override location of pid file.

####`check_for_updates`
Whether or not check for updates. Defaults to `false`.

####`use_upnp`
Whether or not use UPnP for port mapping. Defaults to `true`.

####`download_limit`
Download limit in kB/s. `0` means no limit. Defaults to `0`.

####`upload_limit`
Upload limit in kB/s. `0` means no limit. Defauls to `0`.

####`webui`
Hash containing web user interface configuration.

####`webui['listen']`
Address and port to listen to.

####`webui['login']`
Web ui login.

####`webui['password']`
Web ui password.

####`shared_folders`
Hash containing shared folders resources.

####`disk_low_priority`
Sets priority for the file operations on disc. If set to `false`, Sync will perform read and write file operations with	the highest speed and priority which can result in degradation of performance for othe applications.

####`lan_encrypt_data`
If set to `true`, will use encryption in the local network.

####`lan_use_tcp`
If set to `true`, Sync will use TCP instead of UDP in local network.
Note: disabling	encryption and using TCP in LAN can increase speed ofsync on low-end devices due to lower use of CPU.

####`rate_limit_local_peers`
Applies speed limits to the peers in local network. By default the limits are not applied in LAN.

TODO
----

* Unit tests
* Finish documentation
