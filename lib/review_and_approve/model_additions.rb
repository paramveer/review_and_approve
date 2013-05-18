module ReviewAndApprove
  module ModelAdditions
    def review_and_approve(*args)
      # Extracting options:
      # 1. methods to cache - option :by, default value [:as_json]
      # 2. attribute to track as published - option :field, default value :publish
      methods = [:as_json]
      field = :publish
      args.each do |arg|
        if arg.is_a? Hash
          if !arg[:by].nil?
            methods = arg[:by]
          end
          if !arg[:field].nil?
            field = arg[:field]
          end
        end
      end

      # define the field as an attribute on the model
      attr_accessor field

      after_save do
        published = self.send(field)
        #If we are publishing the record
        if published and (published==true or published=="true" or self.send(field).to_i>0 rescue false) #in case the field gets set to "0" and "1"
          methods.each do |method|
            # Refresh all caches
            Rails.cache.write("ReviewAndApprove_#{self.class.name}_#{self.id}_#{method}", self.send(method))
          end
        end

        true
      end

      send(:define_method, :published_version) do |method_name|
        Rails.cache.read("ReviewAndApprove_#{self.class.name}_#{self.id}_#{method_name}")
      end

      send(:define_method, :mass_assignment_authorizer) do |role = :default|
        # force add the :publish attribute into attr_accessible
        super(role) + [field]
      end

      validates_each field do |record, attr, value|
        able = Thread.current[:reviewAndApprove_current_ability].try(:can?, :publish, record)
        # if user can not publish the record, create an error.
        if !able and value and (value==true or value=="true" or value.to_i>0 rescue false)
          record.errors[attr] << "can not be marked as true by this user"
        end
      end
    end
  end
end
