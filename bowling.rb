class Frame
  attr_reader :pins

  def initialize
    @pins = []
  end

  def add_pins(pin)
    pins << pin
    raise BowlingError unless valid?
  end

  def done?
    strike? || pins.count == 2
  end

  def score(next_frames)
    case
      when strike?
        raw_score + next_frames.flat_map(&:pins).first(2).sum
      when spare?
        raw_score + next_frames.flat_map(&:pins).first
      else
        raw_score
    end
  end

  private

  def spare?
    raw_score == 10 && pins.count == 2
  end

  def strike?
    pins.first == 10
  end

  def raw_score
    pins.sum
  end

  def valid?
    raw_score.between?(0, 10)
  end
end


class LastFrame < Frame
  def done?
    pins.count == 3 || (pins.count == 2 && raw_score < 10)
  end

  def valid?
    pins.all? { |p| p.between?(0, 10) } &&
      raw_score.between?(0, 30) &&
      case
        when pins.first(2).sum == 20
          true
        when pins.first == 10
          raw_score <= 20
        else
          true
      end
  end
end

class Game
  attr_reader :frames

  def initialize
    @frames = []
    @current_frame = Frame.new
  end

  def score
    raise BowlingError unless frames.count == 10
    frames.each.with_index(1).sum do |frame, index|
      frame.score(frames[index, index + 1] || [])
    end
  end

  def roll(pins)
    raise BowlingError if frames.count == 10
    @current_frame.add_pins pins
    if @current_frame.done?
      frames << @current_frame
      @current_frame = frames.count == 9 ? LastFrame.new : Frame.new
    end
  end
end


class BowlingError < StandardError
end


module BookKeeping
  VERSION = 3
end
