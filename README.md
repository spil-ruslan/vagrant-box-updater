# vagrant-box-updater

  vagrant-box-updater - Vagrant (version 1.1+) plugin  save details about box images, checks remote box images for updates, notify user and perform interactive update

  By default Vagrant just store box image to localdisk (during box add) and never checks if there are updates for that image, so users may end up working with outdated boxes.

  This plugin meant to notify user about new versions of remote box images available, and provide interactive prompt to download updates. 


  vagrant plugin hooks into :

	"vagrant box add" - save details about remote box image: image creation timestamp, image source path (box data stored in yaml format inside ~/.vagrant.d/$box_name.stat);

	"vagrant up" -	checks source box url for updates (use remote file modification date to define whether image updated or not), 
					when update found - print message and optionally perform interactive download.
 

## Installation

1. Clone project
2. run "rake build" - this should create gem file
3. install plugin to vagrant environment "sudo vagrant  plugin install pkg/vagrant-box-updater-0.0.1.gem" 

## Usage

It is possible to disable plugin by adding configuration parameter to Vagrantfile:

config.box_updater.disable = true

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
