require 'json'
require 'pry-byebug'

word_list = File.read('wordlist.txt').split
word_list = word_list.select { |word| word.length.between?(5, 12)}
secret_word = word_list[rand(word_list.length)].split('')

class Player
  attr_reader :correct_guess_array, :lives, :save, :saves, :secret_word
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
    puts "#{@lives} lives left!"
    puts "Incorrect guesses: #{@incorrect_guesses}" unless @incorrect_guesses.empty?
  end
end


puts "Welcome to Hangman!\n[1] - New Game\n[2] - Load Game\n"
choice = gets.chomp.to_i
if choice == 1
  me = Player.new(secret_word, 6)

  until me.correct_guess_array.join == secret_word.join || me.lives == 0 || me.save

    me.guess

  end


  if me.save
    File.open("save_game.json", 'w') do |file|
      file.puts me.to_json
    end
  else
    me.lives == 0 ? puts("You lose!\nCorrect word: #{me.secret_word.join}") : puts("You win!")
  end

elsif choice == 2
  serialized = File.read("save_game.json")
  me = Player.from_json(serialized)

  until me.correct_guess_array.join == me.secret_word.join || me.lives == 0 || me.save

    me.guess
    #binding.pry
  end

  
  if me.save
    File.open("save_game.json", 'w') do |file|
      file.puts me.to_json
    end
  else
    me.lives == 0 ? puts("You lose!\nCorrect word: #{me.secret_word.join}") : puts("You win!")
  end
end