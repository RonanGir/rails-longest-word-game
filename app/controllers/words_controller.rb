require 'open-uri'
require 'json'

class WordsController < ApplicationController

  def game
    @grid = generate_grid(9)
    @start_time = Time.now
  end

  def score
    @end_time = Time.now
    @score = run_game(params[:attempt], params[:grid], Time.parse(params[:start_time]), @end_time)
  end

  def generate_grid(grid_size)
    return grid_size.times.map { ("A".."Z").to_a.sample }
  end

  def occurence_verif?(grid, attempt)
    attempted_array = attempt.upcase.chars

    first_hash = Hash.new(0)
    second_hash = Hash.new(0)

    grid.split(' ').each { |letter| first_hash[letter] = grid.count(letter) }
    attempted_array.each { |letter| second_hash[letter] = attempted_array.count(letter) }

    second_hash.all? { |letter, occurence| occurence <= first_hash[letter] }
  end

  def run_game(attempt, grid, start_time, end_time)
    score = 0

    if occurence_verif?(grid, attempt)
      url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
      word_api_serialize = open(url).read
      word_api = JSON.parse(word_api_serialize)

      if word_api["found"]
        score = (attempt.size - (end_time - start_time)) + 100
        message = "well done"
      else
        message = "not an english word"
      end

    else
      message = "it's not in the grid"

    end
    return { score: score, message: message, time: end_time - start_time }
  end
end
