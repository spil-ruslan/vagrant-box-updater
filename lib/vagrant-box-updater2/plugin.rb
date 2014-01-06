module VagrantPlugins
  module BoxUpdater
    class Plugin < Vagrant.plugin('2')
      name 'Vagrant BoxUpdater'
      description 'Plugin allows to check source box for updates and interactively prompt user when update is available.'

      config(:box_updater) do
        require_relative 'config'
        Config
      end

      #action_hook 'do-before-boot' do |hook|
      #  require_relative 'action/up_box'
      #  #hook.after ::Vagrant::Action::Builtin::ConfigValidate, VagrantPlugins::BoxUpdater::Action::UpBox
      #  hook.before Vagrant::Action::Builtin::Provision, VagrantPlugins::BoxUpdater::Action::UpBox
      #end

      action_hook(:do_before_boot, :machine_action_up) do |hook|
	      require_relative 'action/up_box'
        hook.prepend(VagrantPlugins::BoxUpdater::Action::UpBox)
        hook.prepend(V)
      end

      action_hook 'on_update' do |hook|
        require_relative 'action/add_box'
        hook.after ::Vagrant::Action::Builtin::BoxAdd, VagrantPlugins::BoxUpdater::Action::AddBox
      end

    end
  end 
end
