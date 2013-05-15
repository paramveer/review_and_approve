module ReviewAndApprove
  module ModelAdditions
    class ModelValidator < ActiveModel::Validator
      def validate(record)
        if Thread.current[:reviewAndApprove_current_ability].cannot?(:publish, record) and record.published
          record.errors[:published] << "can not be marked as true by this user"
        end
      end
    end

    def review_and_approve(*args)
      methods = [:as_json]
      args.each do |arg|
        if arg.is_a? Hash
          if arg[:by].present?
            methods = arg[:by]
          end
        end
      end
      before_save do
        if Thread.current[:reviewAndApprove_current_ability].cannot? :publish, self
          self.published = false
        end
        true
      end

      after_save do
        if self.published
          methods.each do |method|
            Rails.cache.write("ReviewAndApprove_#{self.class.name}_#{self.id}_#{method}", self.send(method))
          end
        end
      end

      send(:define_method, :published_version) do |method_name|
        Rails.cache.read("ReviewAndApprove_#{self.class.name}_#{self.id}_#{method_name}")
      end

      send(:validates_with, ReviewAndApprove::ModelAdditions::ModelValidator)
    end
  end
end
