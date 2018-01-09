class Frame
  MAX_ROLLS = 2
  MIN_PINS = 0
  MAX_PINS = 10

  attr_reader :pins

  def initialize
    @pins = []
  end

  def add_pins(pin)
    pins << pin
    raise BowlingError unless valid?
  end

  def done?
    strike? || pins.count == MAX_ROLLS
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
    raw_score == MAX_PINS && pins.count == MAX_ROLLS
  end

  def strike?
    pins.first == MAX_PINS
  end

  def raw_score
    pins.sum
  end

  def valid?
    raw_score.between?(MIN_PINS, MAX_PINS)
  end
end


class LastFrame < Frame
  MAX_ROLLS = 3
  MAX_RAW_SCORE = 30

  def done?
    pins.count == MAX_ROLLS || (pins.count == 2 && raw_score < MAX_PINS)
  end

  def valid?
    pins.all? { |p| p.between?(MIN_PINS, MAX_PINS) } &&
      raw_score.between?(MIN_PINS, MAX_RAW_SCORE) &&
      case
        when pins.first(2).sum == 20
          true
        when pins.first == MAX_PINS
          raw_score <= 20
        else
          true
      end
  end
end

class Game
  FRAMES_COUNT = 10
  attr_reader :frames

  def initialize
    @frames = []
    @current_frame = Frame.new
  end

  def score
    raise BowlingError unless frames.count == FRAMES_COUNT
    frames.each.with_index(1).sum do |frame, index|
      frame.score(frames[index, index + 1] || [])
    end
  end

  def roll(pins)
    raise BowlingError if frames.count == FRAMES_COUNT
    @current_frame.add_pins pins
    if @current_frame.done?
      frames << @current_frame
      @current_frame = frames.count == (FRAMES_COUNT - 1) ? LastFrame.new : Frame.new
    end
  end
end


class BowlingError < StandardError
end


module BookKeeping
  VERSION = 3
end
