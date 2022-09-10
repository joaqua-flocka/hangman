require 'json'
require 'pry-byebug'

word_list = File.read('wordlist.txt').split
word_list = word_list.select { |word| word.length.between?(5, 12)}
secret_word = word_list[rand(word_list.length)].split('')

class Player
  attr_reader :correct_guess_array, :lives, :save, :secret_word
  @@saves = 0
  def initialize(word, lives, incorrect_guesses = [], save = false, correct_guess_array = nil)
    if correct_guess_array.nil?
      @correct_guess_array = Array.new(word.length, '_')
    else
      @correct_guess_array = correct_guess_array
    end
    @secret_word = word
    @lives = lives
    @incorrect_guesses = incorrect_guesses
    @save = save
    @@saves = Dir.children('saved_games').length
  end

  def check_guess(guess)
    if @secret_word.include?(guess)
      @correct_guess_array.map!.with_index do |char, idx|
        if @secret_word[idx] == guess
          char = guess
        elsif char != '_'
          char
        else
          char = '_'
        end
      end
    elsif !@incorrect_guesses.include?(guess)
      @incorrect_guesses.push(guess)
      @lives -= 1
    end
  end


  def to_json
    JSON.dump({
      correct_guess_array: @correct_guess_array,
      word: @secret_word,
      lives: @lives,
      incorrect_guesses: @incorrect_guesses,
      saves: @@saves
    })
  end

  def self.from_json(string)
    data = JSON.load(string)
    word = data['word']
    lives = data['lives']
    incorrect_guesses = data['incorrect_guesses']
    correct_guess_array = data['correct_guess_array']
    @@saves = data['saves']
    new(word, lives, incorrect_guesses, false, correct_guess_array)
  end

  def self.saves
    @@saves
  end

  def guess
    puts "Guess a letter! (Enter command '*' to save and quit)\n#{@correct_guess_array.join(' ')}"
    guess = gets.chomp.downcase
    unless guess == '*'
      check_guess(guess)
    else
      @save = true
      @@saves += 1
    end
    puts "#{@lives} lives left!\n"
    puts "Incorrect guesses: #{@incorrect_guesses}" unless @incorrect_guesses.empty?
  end
end

def end_game(player)
  if player.save
    filename = "saved_games/save_game_#{Player.saves}.json"
    File.open(filename, 'w') do |file|
      file.puts player.to_json
      puts "\nGame saved to #{filename}"
    end
  else
    player.lives == 0 ? puts("You lose!\nCorrect word: #{player.secret_word.join}") : puts("You win!")
  end
end


puts "Welcome to Hangman!\n[1] - New Game\n[2] - Load Game\n"
choice = gets.chomp.to_i
if choice == 1
  me = Player.new(secret_word, 6)

  until me.correct_guess_array.join == secret_word.join || me.lives == 0 || me.save

    me.guess

  end

  end_game(me)

elsif choice == 2

  saved_games = Dir.children('saved_games')
  puts "Which game would you like to load?\n"
  saved_games.each_with_index do |game, idx|
    puts "[#{idx + 1}]\t#{game}"
  end

  choice = gets.chomp.to_i - 1

  filename = 'saved_games/' + saved_games[choice]
  serialized = File.read(filename)
  me = Player.from_json(serialized)

  puts Player.saves

  until me.correct_guess_array.join == me.secret_word.join || me.lives == 0 || me.save

    me.guess
    #binding.pry
  end

  end_game(me)

  puts "Would you like to delete this save file?\n[1] - Yes, delete save\n[2] - No\n"
  choice = gets.chomp.to_i

  File.delete(filename) if choice == 1
  
end