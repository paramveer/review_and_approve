module ReviewAndApprove
  class Railtie < Rails::Railtie
    initializer 'review_and_approve.model_additions' do
      ActiveSupport.on_load(:active_record) do
        extend ModelAdditions
      end
    end

    initializer "review_and_approve.contoller_additions" do
      ActiveSupport.on_load(:action_controller) do
        extend ReviewAndApprove::ControllerAdditions # ActiveSupport::Concern
      end
    end
  end
end