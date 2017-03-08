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
tar_extract 'https://github.com/GoogleCloudPlatform/kubernetes/releases/download/v1.5.1/kubernetes.tar.gz' do
  target_dir '/media/storage/'
end

tar_extract '/media/storage/kubernetes/server/kubernetes-salt.tar.gz' do
  action :extract_local
  target_dir '/media/storage/kubernetes/cluster'
  creates '/media/storage/kubernetes/cluster/saltbase'
  tar_flags ['--strip-components 1']
end

hostname = `hostname -i |awk '{print $1}'`.chomp


template '/media/storage/kubernetes/cluster/addons/dns/skydns-rc.yaml.sed' do
  source 'skydns-rc.yaml.sed.erb'
  variables ({
    :hostname  => hostname
  })
end

template '/media/storage/kubernetes/cluster/addons/dashboard/dashboard-controller.yaml' do
  source 'dashboard-controller.yaml.erb'
  variables ({
    :hostname  => hostname
  })
end

template '/media/storage/kubernetes/cluster/ubuntu/util.sh' do
  source 'util.sh.erb'
end

#Check template again when installing in definitive environment
template '/media/storage/kubernetes/cluster/ubuntu/config-default.sh' do
  source 'config-default.sh.erb'
end

#TODO replace only_if with a service validation
execute 'start kube install' do
  command 'KUBERNETES_PROVIDER=ubuntu ./kube-up.sh'
  cwd '//media/storage/kubernetes/cluster'
  only_if {`ps cax |grep kube |wc -l`.to_i == 0}
end

# kubectl_path = '/media/storage/kubernetes/cluster/ubuntu/binaries/kubectl'
# if File.exists?(kubectl_path)
#   file '/usr/local/bin/kubectl' do
#     content IO.read(kubectl_path)
#     mode '775'
#     # only_if {File.exist?('/media/storage/kubernetes/cluster/ubuntu/binaries/kubectl')}
#   end
# end
#
link '/usr/local/bin/kubectl' do
  to '/media/storage/kubernetes/cluster/ubuntu/binaries/kubectl'
end
