desc 'Create caches for existing data'
namespace :review_and_approve do
  task :create_caches, [:arg1, :arg2, :arg3, :arg4, :arg5] => :environment do |t, args|
    puts "In review_and_approve:create_caches"
    
    models = []
    if args.count > 0
      models = args.map{|k,v| v.constantize rescue nil}.compact
    else
      models = ActiveRecord::Base.subclasses.select{|model| 
        model._using_rev_app? rescue false
      }
    end

    models.each do |model|
      
      puts "Processing #{model.name}"
      model.find_each do |obj|
        obj.review_and_approve_after_save_callback(true)
      end
      puts "\n"
    end
  end
end