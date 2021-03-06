require 'spec_helper'

describe SpokenLanguage do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:language_level_code) }
    it { should validate_presence_of(:language_code) }
    it {
      create(:spoken_language)
      should validate_uniqueness_of(:language_code).scoped_to(:user_id)
    }
  end

  describe "scopes" do
    before(:all) do
      @language1 = create(:spoken_language, language_level_code: "mother_tongue")
      @language2 = create(:spoken_language, language_level_code: "advanced")
      @language3 = create(:spoken_language, language_level_code: "intermediate")
      @language4 = create(:spoken_language, language_level_code: "basic")
    end
    after(:all) do
      DatabaseCleaner.clean
    end
    it ".mother_tongue" do
      SpokenLanguage.mother_tongue.should == [@language1]
    end
    it ".advanced" do
      SpokenLanguage.advanced.should == [@language2]
    end
    it ".intermediate" do
      SpokenLanguage.intermediate.should == [@language3]
    end
    it ".basic" do
      SpokenLanguage.basic.should == [@language4]
    end
    describe ".at_least_" do
      it "mother_tongue" do
        SpokenLanguage.at_least_mother_tongue.should == [@language1]
      end
      it "advanced" do
        SpokenLanguage.at_least_advanced.should == [@language1, @language2]
      end
      it "intermediate" do
        SpokenLanguage.at_least_intermediate.should == [@language1, @language2, @language3]
      end
      it "basic" do
        SpokenLanguage.at_least_basic.should == [@language1, @language2, @language3, @language4]
      end
    end

    describe ".by_preferred_language" do
      it "should order by the given language level order" do
        SpokenLanguage.by_language_level.should == [@language1, @language2, @language3, @language4]
      end
    end
  end
end
