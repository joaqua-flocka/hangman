require 'json'

word_list = File.read('wordlist.txt').split
word_list = word_list.select { |word| word.length.between?(5, 12)}
secret_word = word_list[rand(word_list.length)].split('')

class Player
  attr_reader :correct_guess_array, :lives, :save
  def initialize(word, lives, incorrect_guesses = [], save = false)
    @correct_guess_array = Array.new(word.length, '_')
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
    })
    end

  def guess
    puts "Guess a letter! (Enter command '*' to save and quit)\n#{@correct_guess_array.join(' ')}"
    guess = gets.chomp.downcase
    unless guess == '*'
      check_guess(guess)
    else
      @save = true
    end
    puts "#{@lives} lives left!"
    puts "Incorrect guesses: #{@incorrect_guesses}" unless @incorrect_guesses.empty?
  end
end

me = Player.new(secret_word, 6)

until me.correct_guess_array.join == secret_word.join || me.lives == 0 || me.save

  me.guess

end

me.lives == 0 ? puts("You lose!\nCorrect word: #{secret_word.join}") : puts("You win!")

if me.save
  puts me.to_json
end