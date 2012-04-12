#
# Cookbook Name:: mosh
# Recipe:: default
#
# Copyright 2012, Joshua Timberman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

build_dir = "#{Chef::Config[:file_cache_path]}/mosh-source"
version = node['mosh']['version']
tarball_file = "#{Chef::Config[:file_cache_path]}/mosh-#{version}.tar.gz"

node['mosh']['dependencies'].each do |pkg|
  package pkg
end

bash "build-mosh" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  tar -zxvf mosh-#{version}.tar.gz
  (cd mosh-#{version} && ./configure #{node['mosh']['configure_flags'].join(' ')})
  (cd mosh-#{version} && make)
  (cd mosh-#{version} && make install)
  EOH
  only_if { ::File.exists? tarball_file }
end

remote_file tarball_file do
  source node['mosh']['source_url']
  checksum node['mosh']['source_checksum']
  notifies :run, resources("bash[build-mosh]"), :immediately
end
