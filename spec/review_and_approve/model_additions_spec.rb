require 'spec_helper'

class AR < SuperModel::Base
  extend ReviewAndApprove::ModelAdditions
  review_and_approve :field => :hello, :by => [:one, :two], :cache_key => Proc.new{|o,m| "RaA_key_#{o.class.name}_#{o.id}_#{m}"}
  attr_accessor :one, :two
end

class Ability
  include CanCan::Ability
end

describe ReviewAndApprove::ModelAdditions do
  describe "#review_and_approve" do
    it "sets up an attr_accessor for the given field" do 
      a = AR.new
      lambda{a.hello="world"}.should_not raise_exception
      a.hello.should=="world"
    end

    it "should set up published_version method" do
      AR.method_defined?(:published_version).should be_true
    end

    it "should set up current_version method" do
      AR.method_defined?(:current_version).should be_true
    end

    describe "#published_version" do
      it "reads method values from db" do
        a = AR.new
        a.stubs(:id).returns 1

        obj = mock 'object'
        obj.expects(:cache_data).returns 1
        CacheRecord.expects(:find_by_key).with("RaA_key_AR_1_as_json_published_version").returns obj
        
        a.published_version(:as_json).should==1
      end
    end

    describe "#current_version" do
      it "reads method values from db" do
        a = AR.new
        a.stubs(:id).returns 1

        obj = mock 'object'
        obj.expects(:cache_data).returns 1
        CacheRecord.expects(:find_by_key).with("RaA_key_AR_1_as_json_current_version").returns obj

        a.current_version(:as_json).should == 1
      end
    end

    describe "#published?" do
      it "reads published value from the db" do
        a = AR.new
        ActiveRecord::Relation.any_instance.expects(:count).returns 1
        a.published?.should be_true
      end

      it "returns false if there is no data in the db" do
        a = AR.new
        ActiveRecord::Relation.any_instance.expects(:count).returns 0
        a.published?.should be_false
      end
    end

    describe "after_save behavior for able users" do
      context "if object.publish field is true" do
        it "writes all setup methods to db for both published and current_version" do
          a = AR.new
          a.stubs(:id).returns 1
          a.hello = true
          abl = Ability.new
          abl.can(:publish, a)
          Thread.current[:reviewAndApprove_current_ability] = abl
          
          object = mock 'CacheRecord'
          object.stubs(:cache_data=).returns true
          CacheRecord.stubs(:find_or_initialize_by_key).returns(object)
          object.expects(:save).times(4).returns true
          
          a.save
        end
        context "if object.publish field is false" do
          it "only writes current_versions to db" do
            # This shoudl fail with the new functionality. 
            # Should have required an update to accommodate current_version saves
            a = AR.new
            a.stubs(:id).returns 1
            a.hello = false
            abl = Ability.new
            abl.can(:publish, a)
            Thread.current[:reviewAndApprove_current_ability] = abl

            obj = mock 'object'
            CacheRecord.stubs(:find_or_initialize_by_key).returns(obj)
            
            obj.stubs(:cache_data=).returns true
            obj.expects(:save).times(2).returns true
            
            lambda { a.save }.should_not raise_exception
          end
        end
      
      end

    end
    describe "for users that are not allowed to publish record" do
      context "if publish field set to true before save" do
        # Test case crashing without line number. need to investigate
        it "forces save to return false" do
          a = AR.new
          a.stubs(:id).returns 1
          a.hello = true
          abl = Ability.new
          abl.cannot(:publish, a)
          Thread.current[:reviewAndApprove_current_ability] = abl

          CacheRecord.expects(:find_or_initialize_by_key).raises
          
          a.valid?.should be_false
          lambda{ a.save }.should_not raise_exception

        end
      end
    end
  end
end