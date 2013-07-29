# == Define: btsync::instance
#
# Launch btsync daemon with resource parameters.
#
# === Parameters
#
# [*user*]
#   A uid for supplying the user under which the btsync daemon should run
#   Defaults to $name.
#
# [*group*]
#   A gid for supplying the group under which the btsync daemon should run.
#   If omitted the daemon will run under the primary group of the user.
#
# [*umask*]
#   The umask for the btsync damon. If omitted the default umask is used.
#
# [*conffile*]
#   Override default configuration file. Defaults to /etc/btsync/$name.conf
#
# [*device_name*]
#   Public name of the device. Defaults to $name.
#
# [*listening_port*]
#   Port the daemon listen to. Defaults to 0 (random port).
#
# [*storage_path*]
#   storage_path dir contains auxilliary app files if no storage_path field:
#   .sync dir created in the directory where binary is located.
#
# [*pid_file*]
#   Override location of pid file.
#
# [*check_for_updates*]
#   Whether or not check for updates. Defaults to false.
#
# [*use_upnp*]
#   Whether or not use UPnP for port mapping. Defaults to true.
#
# [*download_limit*]
#   Download limit in kB/s. 0 means no limit. Defaults to 0.
#
# [*upload_limit*]
#   Upload limit in kB/s. 0 means no limit. Defauls to 0.
#
# [*webui*]
#   Web ui configuration hash:
#
#   [*listen*]
#     Address and port to listen to.
#
#   [*login*]
#     Web ui login.
#
#   [*password*]
#     Web ui password.
#
# [*disk_low_priority*]
#   Sets priority for the file operations on disc. If set to `false`, Sync will
#   perform read and write file operations with the highest speed and priority
#   which can result in degradation of performance for othe applications.
#
# [*lan_encrypt_data*]
#   If set to `true`, will use encryption in the local network.
#
# [*lan_use_tcp*]
#   If set to `true`, Sync will use TCP instead of UDP in local network.
#
# [*rate_limit_local_peers*]
#   Applies speed limits to the peers in local network.
#   By default the limits are not applied in LAN.
#
define btsync::instance(
  $user = $name,
  $group = undef,
  $umask = undef,
  $conffile = "/etc/btsync/${name}.conf",

  $device_name = $name,
  $listening_port = 0,
  $storage_path = undef,
  $pid_file = undef,
  $check_for_updates = false,
  $use_upnp = true,
  $download_limit = 0,
  $upload_limit = 0,
  $webui = {
    listen   => undef,
    login    => undef,
    password => undef,
  },
  $shared_folders = {},
  $disk_low_priority = undef,
  $lan_encrypt_data = undef,
  $lan_use_tcp = undef,
  $rate_limit_local_peers = undef,
) {

  validate_absolute_path($conffile)
  validate_absolute_path($storage_path)

  concat_build { "btsync_${name}": }
  ->
  file { $conffile:
    owner  => $user,
    group  => $group,
    mode   => '0400',
    source => concat_output("btsync_${name}"),
  }

  concat_fragment { "btsync_${name}+01":
    content => template('btsync/yeasoft_initscript_header.erb'),
  }

  concat_fragment { "btsync_${name}+02":
    content => '{',
  }

  concat_build { "btsync_${name}_json":
    parent_build   => "btsync_${name}",
    target         => "/var/lib/puppet/concat/fragments/btsync_${name}/03",
    file_delimiter => ',',
    append_newline => false,
  }

  concat_fragment { "btsync_${name}_json+01":
    content => template('btsync/global_preferences.erb'),
  }

  concat_fragment { "btsync_${name}_json+02":
    content => template('btsync/webui.erb'),
  }

  if $disk_low_priority != undef {
    concat_fragment { "btsync_${name}_json+10":
      content => "
  \"disk_low_priority\": ${disk_low_priority}",
    }
  }

  if $lan_encrypt_data != undef {
    concat_fragment { "btsync_${name}_json+11":
      content => "
  \"lan_encrypt_data\": ${lan_encrypt_data}",
    }
  }

  if $lan_use_tcp != undef {
    concat_fragment { "btsync_${name}_json+12":
      content => "
  \"lan_use_tcp\": ${lan_use_tcp}",
    }
  }

  if $rate_limit_local_peers != undef {
    concat_fragment { "btsync_${name}_json+13":
      content => "
  \"rate_limit_local_peers\": ${rate_limit_local_peers}",
    }
  }

  concat_fragment { "btsync_${name}+99":
    content => '}',
  }

  create_resources(
    btsync::shared_folder,
    $shared_folders,
    { instance => $name })

}
