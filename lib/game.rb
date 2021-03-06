# hangman/lib/game.rb
# frozen_string_literal: true

module Hangman
  class Game
    attr_reader :rules, :secret, :won, :guesses, :results

    def initialize(rules: Rules.new, secret: Secret.new, player: Player.new, guesses: '', results: '')
      @rules = rules
      @secret = secret
      @player = player
      @display = Display.new(@rules)
      @guesses = guesses
      @results = results
      @won = false
    end

    def max_turns
      @rules.turns
    end

    def gameover?
      @rules.check_gameover(secret: @secret, guesses: @guesses, results: @results)
    end

    def make_secret
      @secret.load_rules(@rules)
      @secret.grab_secret_word if @secret.empty?
      !@secret.empty?
    end

    def test_secret
      @secret.test_set_word
    end

    def welcome_msg
      @player.prompt_name if @player.name.empty?
      @display.show_message { puts "Okay, #{@player.name}, let's hope you have what it takes to save the man!" }
    end

    def setup
      welcome_msg
      make_secret if @secret.empty?
    end

    def play_round
      # Logic to play round
      @display.render(secret: @secret, guesses: @guesses, results: @results)

      ans = @player.prompt_round_input
      if ans == 'save'
        Save.save_to_file('save', to_yaml)
        @display.show_message { print "Saved! You can't enter 'save' again for this round. Continue to guess?" }
        continue = Player.prompt_yesno
        exit if continue == 'n'
        ans = @player.prompt_guess until ans.length == 1
      else
        @guesses += ans
      end

      @results = @secret.compare(guesses)
    end

    def after_round
      @won = @rules.player_win?(@secret, @guesses, @results)
      @display.render(secret: @secret, guesses: @guesses, results: @results) unless @won
      @display.show_message { print "The secret was '#{@secret}'... " }
      @display.show_message { puts @won ? 'you got it! Way to go!' : 'maybe next time!' }
    end

    def to_yaml
      Save.serialize(self)
    end
  end
end
