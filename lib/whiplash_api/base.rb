module WhiplashAPI

  # Example Class Method
  # def reserved(*names)
  #   class_variable_set(:@@reserved, names.collect{|x| x.to_s})
  # end

  class Base < ActiveResource::Base
    extend WhiplashAPI
    
    self.site = 'http://localhost:3000/api/'
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
    
    end
    
    # Example Instance Method
    # def class_name
    #   self.class.name.split('::').last.downcase
    # end
        
  end

end