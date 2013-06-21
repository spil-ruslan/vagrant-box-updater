module VagrantPlugins
  module BoxUpdater
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :disable, :autoupdate

      def initialize
        @disable = false
        @autoupdate = false
      end

      def finalize!
        @disable = false if @disable == UNSET_VALUE
        @autoupdate = false if @autoupdate == UNSET_VALUE
      end

      def validate(machine)
        {}
      end
    end
  end
end
