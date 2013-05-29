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

    describe "after_save behavior for able users" do
      context "if object.publish field is true" do
        it "writes all setup methods to db" do
          a = AR.new
          a.stubs(:id).returns 1
          a.hello = true
          abl = Ability.new
          abl.can(:publish, a)
          Thread.current[:reviewAndApprove_current_ability] = abl
          
          object = mock 'CacheRecord'
          object.stubs(:cache_data=).returns true
          CacheRecord.stubs(:find_or_initialize_by_key).returns(object)
          object.expects(:save).at_least(2).returns true
          
          a.save
        end
      end
      context "if object.publish field is false" do
        it "does not write anything to db" do
          # This shoudl fail with the new functionality. 
          # Should have required an update to accommodate current_version saves
          a = AR.new
          a.stubs(:id).returns 1
          a.hello = false
          abl = Ability.new
          abl.can(:publish, a)
          Thread.current[:reviewAndApprove_current_ability] = abl
          
          CacheRecord.any_instance.expects(:save).raises

          lambda { a.save }.should_not raise_exception
        end
      end
    end
    describe "for users that are not allowed to publish record" do
      context "if publish field set to true before save" do
        it "forces save to return false" do
          a = AR.new
          a.stubs(:id).returns 1
          a.hello = true
          abl = Ability.new
          abl.cannot(:publish, a)
          Thread.current[:reviewAndApprove_current_ability] = abl

          CacheRecord.expects(:find_or_initialize_by_key).with("RaA_key_AR_1_one_published_version", nil).raises
          CacheRecord.expects(:find_or_initialize_by_key).with("RaA_key_AR_1_two_published_version", nil).raises
          
          a.valid?.should be_false
          lambda{ a.save }.should_not raise_exception

        end
      end
    end
  end
end