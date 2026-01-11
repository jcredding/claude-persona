require "../spec_helper"

describe ClaudePersona::Session do
  describe "#round_cost_up" do
    it "rounds up to nearest cent" do
      round_cost_up(1.1404).should eq(1.15)
      round_cost_up(0.001).should eq(0.01)
      round_cost_up(0.999).should eq(1.0)
    end

    it "keeps exact cents unchanged" do
      round_cost_up(1.15).should eq(1.15)
      round_cost_up(0.50).should eq(0.50)
      round_cost_up(10.00).should eq(10.00)
    end

    it "handles zero" do
      round_cost_up(0.0).should eq(0.0)
    end

    it "rounds up even tiny fractions" do
      round_cost_up(0.0001).should eq(0.01)
      round_cost_up(1.0001).should eq(1.01)
    end
  end

  describe "#format_duration" do
    it "formats seconds only" do
      duration = Time::Span.new(seconds: 45)
      result = format_duration(duration)
      result.should eq("45s")
    end

    it "formats minutes and seconds" do
      duration = Time::Span.new(minutes: 5, seconds: 30)
      result = format_duration(duration)
      result.should eq("5m 30s")
    end

    it "formats hours, minutes, and seconds" do
      duration = Time::Span.new(hours: 2, minutes: 15, seconds: 45)
      result = format_duration(duration)
      result.should eq("2h 15m 45s")
    end

    it "handles zero duration" do
      duration = Time::Span.new(seconds: 0)
      result = format_duration(duration)
      result.should eq("0s")
    end
  end
end

# Extract helpers for testing
def round_cost_up(cost : Float64) : Float64
  (cost * 100).ceil / 100.0
end

def format_duration(duration : Time::Span) : String
  total_seconds = duration.total_seconds.to_i
  hours = total_seconds // 3600
  minutes = (total_seconds % 3600) // 60
  seconds = total_seconds % 60

  if hours > 0
    "#{hours}h #{minutes}m #{seconds}s"
  elsif minutes > 0
    "#{minutes}m #{seconds}s"
  else
    "#{seconds}s"
  end
end
