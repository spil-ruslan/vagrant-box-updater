module VagrantPlugins
  module BoxUpdater
        class Config < Vagrant.plugin(2, :config)
          attr_accessor :disable

          def initialize
            @disable = false
          end

          def finalize!
            @disable = false if @disable == UNSET_VALUE
          end

          def validate(machine)
            {}
          end
        end
    end
end
