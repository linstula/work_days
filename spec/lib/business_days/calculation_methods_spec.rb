require_relative '../../spec_helper'

describe BusinessDays::CalculationMethods, :type => :holiday_helpers do
  let(:today)        {Date.today}
  let(:current_year) {Date.today.year}

  let(:dummy_class) do
    Class.new do
      extend(BusinessDays::CalculationMethods)
    end
  end

  subject{dummy_class}

  context "#weekend_day?" do
    let(:date) {double('date', :sunday? => false, :saturday? => false)}

    it "should be true for sundays" do
      date.should_receive(:sunday?).and_return(true)
      subject.weekend_day?(date).should be_true
    end

    it "should be true for saturdays" do
      date.should_receive(:saturday?).and_return(true)
      subject.weekend_day?(date).should be_true
    end

    it "should be false for non-saturdays/non-sundays" do
      date.should_receive(:sunday?).and_return(false)
      date.should_receive(:saturday?).and_return(false)
      subject.weekend_day?(date).should be_false
    end
    it "should be true for weekday holidays" do
      all_holiday_dates.each do |date|
        date = Date.parse(date)
        weekend_flag = date.saturday? || date.sunday?

        subject.weekend_day?(date).should == weekend_flag
      end
    end
  end

  context "#week_day?" do
    it "is true when weekend_day? is false" do
      subject.should_receive(:weekend_day?).and_return(false)
      subject.week_day?(today).should be_true
    end

    it "is false when weekend_day? is true" do
      subject.should_receive(:weekend_day?).and_return(true)
      subject.week_day?(today).should be_false
    end
  end

  context "#work_day?" do
    it "should be true for a non-holiday weekday" do
      subject.should_receive(:week_day?).and_return(true)
      subject.should_receive(:holiday?).and_return(false)

      subject.work_day?(today).should be_true
    end

    it "should be false for a holiday" do
      subject.should_receive(:week_day?).and_return(true)
      subject.should_receive(:holiday?).and_return(true)

      subject.work_day?(today).should be_false
    end

    it "should be false for a weekend" do
      subject.should_receive(:week_day?).and_return(false)
      subject.should_not_receive(:holiday?)

      subject.work_day?(today).should be_false
    end
  end

  context "#non_work_day?" do
    it "is true when work_day? is false" do
      subject.should_receive(:work_day?).and_return(false)
      subject.non_work_day?(today).should be_true
    end

    it "is false when work_day? is true" do
      subject.should_receive(:work_day?).and_return(true)
      subject.non_work_day?(today).should be_false
    end
  end

  context "#work_days_in_range" do
    it "should return an array of the work days between two dates" do
      valid_work_days = []

      start_date = random_date
      end_date   = start_date + rand(35)

      (start_date..end_date).each do |date|
        work_day = random_boolean

        valid_work_days << date if work_day
        subject.should_receive(:work_day?).with(date).and_return(work_day)
      end

      subject.work_days_in_range(start_date, end_date).should eq(valid_work_days)
    end
  end

  context "#next_work_day" do
    it "iterates through each day until it finds the first non-holiday/weekend" do
      first_work_day = random_date
      starting_date  = first_work_day - 2

      subject.should_receive(:non_work_day?).twice.and_return(true)
      subject.should_receive(:non_work_day?).with(first_work_day).and_return(false)

      subject.next_work_day(starting_date).should eq(first_work_day)
    end
  end

  context "#previous_work_day" do
    it "iterates backwards through each day until it finds the first non-holiday/weekend" do
      first_work_day = random_date
      starting_date  = first_work_day + 2

      subject.should_receive(:non_work_day?).twice.and_return(true)
      subject.should_receive(:non_work_day?).with(first_work_day).and_return(false)

      subject.previous_work_day(starting_date).should eq(first_work_day)
    end
  end
end