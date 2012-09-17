module WhiplashAPI

  # Example Class Method
  # def reserved(*names)
  #   class_variable_set(:@@reserved, names.collect{|x| x.to_s})
  # end

  class Base < ActiveResource::Base
    extend WhiplashAPI
    
    self.site = 'https://www.whiplashmerch.com/api/'
    self.format = :json
    
    # Thanks to Brandon Keepers for this little nugget:
    # http://opensoul.org/blog/archives/2010/02/16/active-resource-in-practice/
    class << self
      # If headers are not defined in a given subclass, then obtain
      # headers from the superclass.
      def headers
        if defined?(@headers)
          @headers
        elsif superclass != Object && superclass.headers
          superclass.headers
        else
          @headers ||= {}
        end
      end
      
      def api_key=(api_key)
        headers['X-API-KEY'] = api_key
      end
      
      def api_version=(v)
        headers['X-API-VERSION'] = v
      end
      
      def local=(v)
        self.site = 'http://localhost:3000/api/' if v
      end
      
      def test=(v)
        self.site = 'http://testing.whiplashmerch.com/api/' if v
      end
    
    end
    
    # Example Instance Method
    # def class_name
    #   self.class.name.split('::').last.downcase
    # end
        
  end

end