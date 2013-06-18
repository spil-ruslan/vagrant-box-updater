require 'yaml'
require 'net/http'
require 'uri'
require 'vagrant-box-updater/util/common'

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
	  path_box_stat_file = Util::Common.get_path_box_stat_file(env, box_name)

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
	    Util::Common.save_box_stats(path_box_stat_file, @box_attributes)
          end

          box_stats = YAML.load_file(stat_file)

          box_url = box_stats["url"]

          current_modification_date = box_stats["Last-Modified"] 
	  # "Etag" attribute is not in use - but we may use it in future 
	  # What we trying to achieve : some public resources such as github.com does not provide "Last-Modified"
	  # but "Etag" id, so optionally we may need number of generic methods to decide if object modified
          current_modification_etag = box_stats["Etag"] 

          if current_modification_date == nil and current_modification_etag != nil
            env[:ui].warn("Not enough data to decide whether image need to be updated")
            env[:ui].warn("Remote server does not provide \"Last-Modified\" field in the header but \"Etag\" which is not supported at the moment")
            env[:ui].warn("This is known issue for some websites (like github.com)")
            env[:ui].warn("If you want to have this functionality added, please, fire feature request on oficial plugin page on github")
            @app.call(env)
            return 0
          end

          if current_modification_date == nil
            env[:ui].warn("Not enough data to decide whether image need to be updated")
            env[:ui].warn("Please, add box again \"vagrant box add -f\" so it'll update image data")
            @app.call(env)
            return 0
          end

          if box_url == nil
            env[:ui].warn("Local box url is not set")
            env[:ui].warn("Unable to check remote box")
            env[:ui].warn("Please, add box again \"vagrant box add -f\" so it'll update image data")
            @app.call(env)
            return 0
          end

          begin
            env[:ui].info("Verify remote image data: #{box_url}")
            remote_modification_attribute = Util::Common.get_modification_attribute(box_url)
          rescue 
            env[:ui].warn("Unable access: #{box_url}")
            env[:ui].warn("Skip remote box check")
            @app.call(env)
            return 0
          end

          if remote_modification_attribute['Last-Modified'] == nil
            env[:ui].warn("Can not retrieve any useful data for: #{box_url}")
            env[:ui].warn("Skip remote box check")
            @app.call(env)
            return 0
          end
          remote_modification_timestamp = remote_modification_attribute['Last-Modified'].is_a?(Time) ? remote_modification_attribute['Last-Modified'] : Time.parse(remote_modification_attribute['Last-Modified'])
          current_modification_timestamp = current_modification_date.is_a?(Time) ? current_modification_date : Time.parse(current_modification_date)

          #env[:ui].info("Remote box timestamp #{remote_modification_timestamp}")
          #env[:ui].info("Local box timestamp #{current_modification_timestamp}")

          if current_modification_timestamp.to_i < remote_modification_timestamp.to_i
	    box_stats = Util::Common.read_box_stats(path_box_stat_file, box_name)
	    if box_stats['ignored_image_attribute'] and box_stats['ignored_image_attribute'].to_i == remote_modification_timestamp.to_i
              env[:ui].warn("Modified image detected, this update set to be ignored until next change")
	    else
              env[:ui].warn("Modified image detected : #{box_stats['url']} #{remote_modification_attribute}")
	      if ask_confirm(env,"Would you like to update the box? \nIf negative - we keep ignoring this update, and notify only when another update detected. \nType (Y/N)")
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
                env[:ui].warn("This update will be ignored")   
	        Util::Common.add_box_stats(path_box_stat_file, {'ignored_image_attribute' => remote_modification_timestamp})
                @app.call(env)
              end
	    end
	  else
            env[:ui].info("Box is uptodate")
          end

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

      end
    end
  end
end
