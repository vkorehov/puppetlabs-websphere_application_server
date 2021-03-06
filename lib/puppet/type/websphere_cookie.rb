require 'pathname'

Puppet::Type.newtype(:websphere_cookie) do
  @doc = <<-DOC
    @summary Manages the existence of a WebSphere Cookie. The current provider does _not_ manage parameters post-creation.
    @example Remove session cookie
      websphere_cookie { 'SecureSessionCookie_1':
        ensure         => 'absent',
        profile_base   => '/opt/IBM/WebSphere/AppServer/profiles',
        dmgr_profile   => 'PROFILE_DMGR_01',
        user           => 'root',
        scope          => 'cell',
        cell           => 'CELL_02',
      }
  DOC

  autorequire(:user) do
    self[:user]
  end

  ensurable

  validate do
    [:dmgr_profile, :name, :user, :cell].each do |value|
      raise ArgumentError, "Invalid #{value} #{self[:value]}" unless value =~ %r{^[-0-9A-Za-z._]+$}
    end

    raise ArgumentError, 'cell is a required attribute' if self[:cell].nil?
    raise("Invalid profile_base #{self[:profile_base]}") unless Pathname.new(self[:profile_base]).absolute?
    raise ArgumentError 'Invalid scope, must be "node", "server", "cell", or "cluster"' unless self[:scope] =~ %r{^(node|server|cell|cluster)$}
  end

  newparam(:dmgr_profile) do
    desc <<-EOT
      Required. The name of the DMGR _profile_ that this provider should be
      managed under.
    EOT
  end

  newparam(:profile) do
    desc <<-EOT
      Optional. The profile of the server to use for executing wsadmin
      commands. Will default to dmgr_profile if not set.
    EOT
  end

  newparam(:name) do
    isnamevar
    desc 'Cookie ID. For example cells/CELL_02|cell.xml#SecureSessionCookie_1'
  end

  newparam(:profile_base) do
    desc <<-EOT
      Required. The full path to the profiles directory where the
      `dmgr_profile` can be found.  The IBM default is
      `/opt/IBM/WebSphere/AppServer/profiles`
    EOT
  end

  newparam(:user) do
    defaultto 'root'
    desc <<-EOT
      Optional. The user to run the `wsadmin` command as. Defaults to 'root'
    EOT
  end

  newparam(:path) do
    defaultto '/'
    desc <<-EOT
      Optional. Path for cookie
    EOT
  end

  newparam(:domain) do
    defaultto '*'
    desc <<-EOT
      Optional. Domain for cookie
    EOT
  end

  newparam(:node_name) do
    desc <<-EOT
      Required if `scope` is server or node.
    EOT
  end

  newparam(:server) do
    desc <<-EOT
      Required if `scope` is server.
    EOT
  end

  newparam(:cluster) do
    desc <<-EOT
      Required if `scope` is cluster.
    EOT
  end

  newparam(:cell) do
    desc <<-EOT
      Required.  The cell that this provider should be managed under.
    EOT
  end

  newparam(:scope) do
    desc <<-EOT
    The scope to manage the JDBC Provider at.
    Valid values are: node, server, cell, or cluster
    EOT
  end

  newparam(:description) do
    desc <<-EOT
    An optional description for entry
    EOT
  end

  newparam(:wsadmin_user) do
    desc 'The username for wsadmin authentication'
  end

  newparam(:wsadmin_pass) do
    desc 'The password for wsadmin authentication'
  end
end
