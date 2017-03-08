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

#FIXME manage the prompt when key is already created
execute "create ssh keys" do
  command "ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ''"
  ignore_failure true
end

#FIXME execute this if ssh keys creation is successful
execute "add keys for no passwd login" do
  command "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
end

directory '/media/storage'


#I didn't find a way to autocreate target_dir if doesn't exist
tar_extract "https://github.com/GoogleCloudPlatform/kubernetes/releases/download/v1.5.1/kubernetes.tar.gz" do
  target_dir '/media/storage/'
  creates '/media/storage/extracted'
end
