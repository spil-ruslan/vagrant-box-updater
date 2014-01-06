module VagrantPlugins
  module BoxUpdater
    module Util
      class Common

        def self.get_path_box_stat_file(env, box_name)
          YAML::ENGINE.yamler='psych'
          stat_file = env[:home_path].join(box_name + ".stat")
	  return stat_file
        end

        def self.save_box_stats(stat_file, box_attributes)
          YAML::ENGINE.yamler='psych'
          File.open(stat_file, 'w+') {|f| f.write(box_attributes.to_yaml) }
        end

        def self.add_box_stats(stat_file, box_attributes)
          YAML::ENGINE.yamler='psych'
	  content = YAML.load_file(stat_file)
	  content = content.merge(box_attributes)
          #env[:ui].info("Save to: #{stat_file}")
          File.open(stat_file, 'w+') {|f| f.write(content.to_yaml) }
        end

        def self.read_box_stats(stat_file, box_name)
          YAML::ENGINE.yamler='psych'
	  content = YAML.load_file(stat_file)
	  return content
        end

        def self.get_modification_attribute(box_path)
          if !box_path.start_with? "http"
            ref_modification_attribute = method(:get_local_file_modification_date?)
          else
            ref_modification_attribute = method(:get_url_modification_attribute?)
          end

          modification_attribute = ref_modification_attribute.call(box_path)
          return modification_attribute
        end
        
        def self.get_url_modification_attribute?(url)
          response = fetch_url(url)
          return { 'Last-Modified' => response['Last-Modified'] } if response['Last-Modified']
          return { 'Etag' => response['ETag'].delete("\"") } if response['Etag']
        end
        
        def self.fetch_url(uri_str, limit = 10)
          # You should choose better exception.
          raise ArgumentError, 'HTTP redirect too deep' if limit == 0
        
          uri = URI.parse(uri_str)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.port == 443)
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE

          # if we have a user and password then chances are we want to use basic auth
          if !uri.user.nil? and !uri.password.nil?
            auth = 'Basic ' + Base64.encode64( "#{uri.user}:#{uri.password}" ).chomp
            headers = {
                "Authorization" => auth
            }
          end

          response = http.head(uri.request_uri, headers || nil)

          case response
          when Net::HTTPSuccess     then response
          when Net::HTTPRedirection then fetch_url(response['location'], limit - 1)
          else
            response.error!
          end
        end
        
        def self.get_local_file_modification_date?(url)
          mtime = File.mtime(url)
          return { 'Last-Modified' => mtime }
        end

      end
    end
  end
end
