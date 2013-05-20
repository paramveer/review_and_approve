desc 'Create caches for existing data'
namespace :review_and_approve do
  task :create_caches => :environment do
    puts "In review_and_approve:create_caches"
    ActiveRecord::Base.subclasses.select{|model| 
      model._using_rev_app? rescue false
      }.each do |model|
      
      puts "Processing #{model.name}"
      model.find_each do |obj|
        obj.review_and_approve_after_save_callback(true)
      end
      puts "\n"
    end
  end
end