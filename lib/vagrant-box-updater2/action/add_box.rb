require 'yaml'
require 'net/http'
require 'uri'
require 'base64'
require 'vagrant-box-updater2/util/common'

module VagrantPlugins
  module BoxUpdater
    module Action
      class AddBox

        def initialize(app, env)
          @app = app
        end

        def call(env)
          box_url = env[:box_url]
          box_name = env[:box_name]
          begin
            modification_attribute = Util::Common.get_modification_attribute(box_url)
          rescue
            env[:ui].error("Unable to access: #{box_url}")
            env[:ui].error("Can not collect image status, please check box url and repeat action")
            @app.call(env)
            return 0
          end
          @box_attributes = {"url" => box_url}.merge(modification_attribute)
          path_box_stat_file = Util::Common.get_path_box_stat_file(env, box_name)
          Util::Common.save_box_stats(path_box_stat_file, @box_attributes)
          @app.call(env)
        end
      end
    end
  end
end
