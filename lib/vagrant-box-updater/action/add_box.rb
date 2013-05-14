require 'vagrant/action/builder'
require 'yaml'

module VagrantPlugins
  module BoxUpdater
    module Action
      class AddBox

        include Vagrant::Action::Builtin

        def initialize(app, env)
          @app = app
        end

        def call(env)
            box_url = env[:box_url]
            box_name = env[:box_name]

            begin
                remote_modification_date = get_remote_modification_date?(box_url)
            rescue
                env[:ui].error("Unable access: #{box_url}")
                env[:ui].error("Can not collect image status, please check box url and repeat action")
                @app.call(env)
                return 0
            end

            @box_attributes = {"modification_date" => remote_modification_date, "url" => box_url}
            env[:ui].info("Box details: #{@box_attributes.to_yaml}")
            stat_file = env[:home_path].join(box_name + ".stat")
            File.open(stat_file, 'w+') {|f| f.write(@box_attributes.to_yaml) }
            @app.call(env)
        end

        def get_remote_modification_date?(url)
          require 'open-uri'
          require 'net/http'
          url = URI.parse(url)
          Net::HTTP.start(url.host, url.port) do |http|
            response = http.head(url.request_uri)
            return response['Last-Modified']
          end
        end

      end
    end
  end
end
