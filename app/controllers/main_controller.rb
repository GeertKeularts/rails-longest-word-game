require 'open-uri'
require 'json'

class MainController < ApplicationController
  def game
    @time = Time.now.to_i

    @grid = generate_grid(10)
    @random = @grid.join
  end

  def score
    @answer = params[:answer]
    @random = params[:grid]
    user_input = params[:answer]
    random_grid = params[:grid].chars
    correct_grid = check_grid?(user_input, random_grid)
    real_word = check_word?(user_input)

    if correct_grid && real_word
      start = params[:time]
      done = Time.now.to_i
      outcome = score_cal(user_input, start, done)
      @result = "your score is #{outcome[:score]}."
    else
      @result = "this is incorrect"
    end
  end

  private

  def generate_grid(grid_size)
    random = []
    alphabet = ("A".."Z").to_a
    vowels = %w(A E U I O)
    (grid_size - 1).times { random << alphabet.sample }
    random << vowels.sample
  end

  def check_grid?(user_input, random_grid)
    input = user_input.upcase.chars
    answer = true
    input.each do |letter|
      answer = false if input.count(letter) > random_grid.count(letter)
    end
    answer
  end

  def check_word?(word)
    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{word}"
    open(api_url) do |stream|
      data = JSON.parse(stream.read)
      if data['term0'].nil?
        return false
      else
        data['term0']['PrincipalTranslations']['0']['FirstTranslation']['term']
      end
    end
  end

  def score_cal(attempt, start_time, end_time)
    good_result = {}
    good_result[:time] = end_time.to_i - start_time.to_i
    good_result[:score] = attempt.length * 1000 - (end_time.to_i - start_time.to_i)
    good_result[:message] = "well done"
    good_result
  end
end
