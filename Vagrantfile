# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu-14.04-docker'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.network :forwarded_port, guest: 80, host: 3000      # puma
  config.vm.network :forwarded_port, guest: 5432, host: 5433    # postgres
  
  config.vm.provision :shell, inline: 'mkdir -p /postgres_data'
  
  config.vm.provision 'docker' do |d|
    d.pull_images 'zooniverse/postgresql'
    
    d.run 'zooniverse/postgresql',
          args: '--name pg --publish 5432:5432 --env PG_USER="talk" --env DB="talk_staging" --env PASS="talk" -v /postgres_data:/data'
    
    d.build_image '/vagrant', args: '-t zooniverse/talk'
    d.run 'talk', image: 'zooniverse/talk',
          args: '--publish 80:80 --link pg:pg -v /vagrant:/rails_app --env TALK_DB_PASSWORD="talk" --env SECRET_KEY_BASE="79c13497d5c6bf783c544ad058c28469b101c9612ea607b335863573f37fe4201233b7f044ba5b5923d2e1aa709e4a0bb61f4dbb6a9b9c9dbd03ffeb21c9382d" --env RACK_ENV=staging --env RAILS_ENV=staging --env VAGRANT_APP=1'
  end
  
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '2048']
    vb.customize ['modifyvm', :id, '--cpus', '4']
  end
end
