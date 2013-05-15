module ReviewAndApprove
  class Railtie < Rails::Railtie
    initializer 'review_and_approve.model_additions' do
      ActiveSupport.on_load(:active_record) do
        extend ModelAdditions
      end
    end
  end
end