module VagrantPlugins
  module BoxUpdater
    module Util
      class Common

        def self.get_path_box_stat_file(env, box_name)
          YAML::ENGINE.yamler='syck'
          stat_file = env[:home_path].join(box_name + ".stat")
	  return stat_file
        end

        def self.save_box_stats(stat_file, box_attributes)
          YAML::ENGINE.yamler='syck'
          File.open(stat_file, 'w+') {|f| f.write(box_attributes.to_yaml) }
        end

        def self.add_box_stats(stat_file, box_attributes)
          YAML::ENGINE.yamler='syck'
	  content = YAML.load_file(stat_file)
	  content = content.merge(box_attributes)
          #env[:ui].info("Save to: #{stat_file}")
          File.open(stat_file, 'w+') {|f| f.write(content.to_yaml) }
        end

        def self.read_box_stats(stat_file, box_name)
          YAML::ENGINE.yamler='syck'
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
          
          if !uri.user.nil?
            http.basic_auth uri.user, uri.password
          end
        
          #request = Net::HTTP::Get.new(uri.request_uri, { 'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.63 Safari/537.31' })
          #response = Net::HTTP.start(uri.host, uri.port) { |http| http.request(request) }
          #response = http.request(request)
          response = http.head(uri.request_uri)
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
