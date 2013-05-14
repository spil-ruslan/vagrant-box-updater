require 'yaml'

module VagrantPlugins
  module BoxUpdater
    module Action
      class UpBox

        def initialize(app, env)
          @app = app
        end

        def call(env)
          require 'time'
          box_name = env[:machine].config.vm.box
          box_url  = env[:machine].config.vm.box_url

          disable_plugin_flag = env[:machine].config.box_updater.disable
          if disable_plugin_flag == true
            env[:ui].warn("Update disabled")    
            @app.call(env)
            return 0
          end
          
          stat_file = env[:home_path].join(box_name + ".stat")

          # Create empty stat file if missing 
          if !File.file?(stat_file)
            env[:ui].info("Local stat file not found: #{stat_file}")
            @box_attributes = {"modification_date" => nil, "url" => box_url}
            puts @box_attributes.to_yaml
            File.open(stat_file, 'w+') {|f| f.write(@box_attributes.to_yaml) }
          end

          box_stats = YAML.load_file(stat_file)

          present_modification_date = box_stats["modification_date"] 
          box_url = box_stats["url"]

          if present_modification_date == nil
            env[:ui].warn("Local box image \"modification_date\" is not set")
            env[:ui].warn("Unable to check remote box")
            env[:ui].warn("Please, add box again \"vagrant box add\" so it'll update image data")
            @app.call(env)
            return 0
          end

          if box_url == nil
            env[:ui].warn("Local box url is not set")
            env[:ui].warn("Unable to check remote box")
            env[:ui].warn("Please, add box again \"vagrant box add\" so it'll update image data")
            @app.call(env)
            return 0
          end

          begin
              env[:ui].info("Verify remote box modification date: #{box_url}")
              remote_modification_date = get_remote_modification_date?(box_url)
          rescue 
              env[:ui].warn("Unable access: #{box_url}")
              env[:ui].warn("Skip remote box check")
              @app.call(env)
              return 0
          end

          if remote_modification_date == nil
              env[:ui].warn("Can not retrieve 'Last-Modified' attribute for: #{box_url}")
              env[:ui].warn("Skip remote box check")
              @app.call(env)
              return 0
          end

          remote_modification_timestamp = Time.parse(remote_modification_date)
          present_modification_timestamp = Time.parse(present_modification_date)

          env[:ui].info("Remote box timestamp #{remote_modification_timestamp}")
          env[:ui].info("Local box timestamp #{present_modification_timestamp}")

          if present_modification_timestamp < remote_modification_timestamp
            env[:ui].warn("Updated image detected!!!!")
            if ask_confirm(env,"Would you like to update the box? (Y/N)")
              env[:ui].info("Going to update and replace box \"#{box_name}\" now!")
              provider = nil
              env[:action_runner].run(Vagrant::Action.action_box_add, {
                :box_name     => box_name,
                :box_provider => provider,
                :box_url      => box_url,
                :box_force    => true,
                :box_download_insecure => true,
               })
            else
            env[:ui].warn("Update disabled")    
            @app.call(env)
            end
          end

          env[:ui].info("Box is uptodate")    
          @app.call(env)
        end
        
        private 

        def ask_confirm(env, message)
          choice = nil
          # If we have a force key set and we're forcing, then set
          # the result to "Y"
          choice = "Y" if @force_key && env[@force_key]
          # If we haven't chosen yes, then ask the user via TTY
          choice = env[:ui].ask(message) if !choice
          # The result is only true if the user said "Y"
          result = choice && choice.upcase == "Y"
          return result  
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
