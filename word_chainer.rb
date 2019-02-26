require 'set'

class Word_Chainer

    attr_reader :dictionary, :current_words, :all_seen_words, :path

    def initialize(dictionary_file_name)
        @dictionary = Set.new 
        File.readlines(dictionary_file_name).map(&:chomp).each do |word|
            @dictionary.add(word)
        end 
        @current_words = []
        @all_seen_words = {}
        @path = []
    end 

    def adjacent_words(word)
        words_with_same_length = @dictionary.select {|w| w.length == word.length}
        adjacents = Set.new

        wdup = word.dup
        wdup.chars.each_index do |i|
            word_subset = word[0...i] + word[i+1..-1]
            words_with_same_length.each do |w2|
                w2_subset = w2[0...i] + w2[i+1..-1]
                if word_subset == w2_subset
                    adjacents.add(w2)
                end
            end
        end 

        adjacents.reject {|w| w == word}
    end 

    def run(source, target)
        @current_words = [source]
        @all_seen_words = { source => nil}

        while current_words.length != 0
            new_words = self.explore_current_words(target)
            @current_words = new_words
        end 

        build_path(target)
        @path.reverse! << target
        @path
    end

    def explore_current_words(target)
        new_current_words = []

        @current_words.each do |current_word|
            adjacents = adjacent_words(current_word)
            adjacents.each do |adjacent_word|
                if !@all_seen_words.include?(adjacent_word)
                    new_current_words << adjacent_word
                    @all_seen_words[adjacent_word] = current_word
                    return [] if @all_seen_words.include?(target)
                end 
            end
        end 

        new_current_words
    end

    def build_path(target)
        return nil if !@all_seen_words[target]
        @path << @all_seen_words[target]
        build_path(@all_seen_words[target])
    end 
end 

words = Word_Chainer.new("dictionary.txt")
p words.run("duck", "ruby") # ==> ["duck", "dunk", "dune", "rune", "rube", "ruby"]