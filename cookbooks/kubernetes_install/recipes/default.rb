#
## Cookbook Name:: kubernetes_install
## Recipe:: default
##
## Copyright 2017, Universidad de Chile
##
## License MIT
##

user_home = ENV['HOME']
user = ENV['USER']

#TODO Add check to do this once
execute 'package update if vagrant' do
  command 'apt-get update'
  only_if { File.directory?('/home/vagrant') }
end

package ["apt-transport-https", "ca-certificates", "linux-image-extra-#{node[:os_version]}", "linux-image-extra-virtual"]

apt_repository 'docker' do
  uri 'https://apt.dockerproject.org/repo'
  distribution "#{node['platform']}-#{node['lsb']['codename']}"
  components ['main']
  key 'https://apt.dockerproject.org/gpg'
end

package ['docker-engine', 'bridge-utils']

#TODO add feature to create keys to N servers according to config-default.sh
execute "create ssh keys" do
  command "ssh-keygen -t rsa -f #{user_home}/.ssh/id_rsa -q -N ''"
  creates "#{user_home}/.ssh/id_rsa.pub"
end

#TODO Add guard to avoid entering this code all the time
ruby_block 'add keys to authorized_keys' do
  block do
    auth_keys = Chef::Util::FileEdit.new("#{user_home}/.ssh/authorized_keys")
    id_pub = ''
    id_pub = File.open("#{user_home}/.ssh/id_rsa.pub", &:readline)
    auth_keys.insert_line_if_no_match(/\b#{user}@#{node[:hostname]}\b/, id_pub)
    auth_keys.write_file
  end
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

host_ip = node[:ipaddress]

template '/media/storage/kubernetes/cluster/addons/dns/skydns-rc.yaml.sed' do
  source 'skydns-rc.yaml.sed.erb'
  variables ({
    :host_ip  => host_ip
  })
end

template '/media/storage/kubernetes/cluster/addons/dashboard/dashboard-controller.yaml' do
  source 'dashboard-controller.yaml.erb'
  variables ({
    :host_ip  => host_ip
  })
end

template '/media/storage/kubernetes/cluster/ubuntu/util.sh' do
  source 'util.sh.erb'
end

#Important to check this file and make sure that IPs are good fit for environment
template '/media/storage/kubernetes/cluster/ubuntu/config-default.sh' do
  source 'config-default.sh.erb'
end

#TODO replace only_if with a service validation
execute 'start kube install' do
  command 'KUBERNETES_PROVIDER=ubuntu ./kube-up.sh'
  cwd '/media/storage/kubernetes/cluster'
  only_if {`ps cax |grep kube |wc -l`.to_i == 0}
end

link '/usr/local/bin/kubectl' do
  to '/media/storage/kubernetes/cluster/ubuntu/binaries/kubectl'
end

#FIXME Validate if this was done
execute 'kubectl completition' do
  command <<-EOF
    #!/usr/bin/env bash && \
    source <(kubectl completion bash) && \  
    echo 'source <(kubectl completion bash)' >> #{user_home}/.bash_profile
  EOF
end

#FIXME Validation in only_if not working
execute 'deploy kube-dns and dashboard' do
  command 'KUBERNETES_PROVIDER=ubuntu ./deployAddons.sh'
  cwd '/media/storage/kubernetes/cluster/ubuntu'
  only_if {shell_out('ps cax |grep kube-dns |wc -l').stdout.to_i == 0}
  notifies :run, 'execute[install busybox]', :delayed
  notifies :run, 'execute[install kubernetes bootcamp]', :delayed
end

#Installation of kubernetes-bootcamp and busybox to test the cluster
execute 'install kubernetes bootcamp' do
  command 'kubectl run kubernetes-bootcamp --image=docker.io/jocatalin/kubernetes-bootcamp:v1 --port=8080'
  action :nothing
end

cookbook_file '/media/storage/busybox.yaml' do
  source 'busybox.yaml'
end

execute 'install busybox' do
  command 'kubectl create -f busybox.yaml'
  cwd '/media/storage/'
  action :nothing
end
