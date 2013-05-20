desc 'Create caches for existing data'
namespace :review_and_approve do
  task :create_caches => :environment do
    ActiveRecord::Base.subclasses.select{|m| model._using_rev_app? rescue false}.each do |model|
      model.find_each do |obj|
        obj.review_and_approve_after_save_callback(true)
      end
    end
  end
end