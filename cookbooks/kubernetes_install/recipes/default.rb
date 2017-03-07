package ['apt-transport-https', 'ca-certificates', 'linux-image-extra-$(uname -r)', 'linux-image-extra-virtual']

apt_repository "docker" do
  uri "https://apt.dockerproject.org/repo"
  distribution "#{node['platform']}-#{node['lsb']['codename']}"
  components ["main"]
  key "https://apt.dockerproject.org/gpg"
end

#Look for another way to force update of apt-cache
# execute "apt-get-update" do
#   command "apt-get update"
# end

package ['docker-engine', 'bridge-utils']

execute "create ssh keys" do
  command "ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ''"
end

execute "add keys for no passwd login" do
  command "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
end


