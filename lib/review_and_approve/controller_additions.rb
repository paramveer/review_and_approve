module ReviewAndApprove
  module ControllerAdditions
    def self.extended(base)
      base.send :define_method, :review_ability do |&block|
        Thread.current[:reviewAndApprove_current_ability] = self.send :current_ability
        block.call
      end

      base.around_filter :review_ability
    end

  end
end