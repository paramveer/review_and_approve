module ReviewAndApprove
  module ModelAdditions
    def review_and_approve(*args)
      # Extracting options:
      # 1. methods to cache - option :by, default value [:as_json]
      # 2. attribute to track as published - option :field, default value :publish
      field = :publish
      methods = [:as_json]
      key_proc = Proc.new{|obj, method| "ReviewAndApprove_#{obj.class.name}_#{obj.id}_#{method}"}
      args.each do |arg|
        if arg.is_a? Hash
          if !arg[:by].nil?
            methods = arg[:by]
          end
          if !arg[:field].nil?
            field = arg[:field]
          end
          if !arg[:cache_key].nil?
            key_proc = arg[:cache_key]
          end
        end
      end

      # define the field as an attribute on the model
      attr_accessor field

      # identifier on the class that it has been set up with review_and_approve
      send(:define_singleton_method, :_using_rev_app?) do
        true
      end

      after_save :review_and_approve_after_save_callback

      send(:define_method, :review_and_approve_after_save_callback) do |publish = false|
        published = self.send(field) || publish
        #If we are publishing the record
        if published and (published==true or published=="true" or published=="on" or self.send(field).to_i>0 rescue false) #in case the field gets set to "0" and "1"
          methods.each do |method|
            # Refresh published cache
            cr = CacheRecord.find_or_initialize_by_key("#{key_proc.call(self, method)}_published_version")
            cr.cache_data =  self.send(method)
            cr.save
          end
        end

        methods.each do |method|
          #Refresh current value cache
          cr = CacheRecord.find_or_initialize_by_key("#{key_proc.call(self, method)}_current_version")
          cr.cache_data = self.send(method)
          cr.save
        end

        true
      end

      send(:define_method, :published_version) do |method_name|
        CacheRecord.find_by_key("#{key_proc.call(self, method_name)}_published_version").cache_data rescue nil
      end

      send(:define_method, :current_version) do |method_name|
        CacheRecord.find_by_key("#{key_proc.call(self, method_name)}_current_version").cache_data rescue nil
      end


      send(:define_method, :mass_assignment_authorizer) do |role = :default|
        # force add the :publish attribute into attr_accessible
        super(role) + [field]
      end

      validates_each field do |record, attr, value|
        able = Thread.current[:reviewAndApprove_current_ability].try(:can?, :publish, record)
        # if user can not publish the record, create an error.
        if !able and value and (value==true or value=="true" or value=="on" or value.to_i>0 rescue false)
          record.errors[attr] << "can not be marked as true by this user"
        end
      end
    end
  end
end
