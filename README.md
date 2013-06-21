# vagrant-box-updater

Vagrant 1.1+ plugin to detect changes to a remote box's creation date,
and perform an interactive update if desired.

By default Vagrant just store box images locally and never checks if
there are updates for that image. Users may therefore end up working
with outdated boxes.

This plugin hooks into `vagrant box add` and `vagrant up`, saving
details about each box sources creation date, and optioning performing
an update when a change is detected.

## Installation

    vagrant plugin install vagrant-box-updater

## Usage

After plugin installed it's recommended to re-add box images so that the
plugin can collect necessary information about the box.

    vagrant box add --force <source_uri>

To disable the plugin for a project:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.box_updater.disable = true

  // ...

end
```

To enable automatic updates for a project:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.box_updater.autoupdate = true

  // ...

end
```
## Install from source (Advanced)

1. Clone project
2. Create a gem file: `rake build`
3. Install local gem: `vagrant plugin install pkg/vagrant-box-updater-0.0.1.gem`


## Contributing

1. Fork it
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create new Pull Request
