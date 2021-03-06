#BaseRule
#Usage:
#    Initialize -> add_triggers -> ready -> is_met?
#    It does not check the validity of symbol

require 'rubygems'
require 'yahoo_stock'

class BaseRule

    #for test only
    attr_accessor :condition, :triggers, :symbol

    #Only support single symbol query
    #symbol: string
    def initialize symbol
        @symbol = symbol
        @condition = Hash.new
        @triggers = Hash.new
    end

    #raw_triggers: { :indicator => [:up_or_down, target] }
    def add_triggers raw_triggers
        raw_triggers.each do |k, v|
            @triggers[k] = triggerize(*v)
        end
    end

    #symbol: string, the symbol representation of the stock. e.g. GOOG
    def get_condition
        @condition
    end

    #Last step for match
    def ready
        quote = DataPool::DataPool.query(@symbol, @triggers)
        #need to convert the queried value to integer
        begin
            quote.each { |k, v| @condition[k] = v.to_f }
            @condition[:updated_time] = Time.new
        rescue
            puts "Query failed."
            return false
        end
        return true
    end

    #up_or_down: :up or :down
    #target: numeric
    def triggerize up_or_down, target
        if up_or_down == :up
            lambda { |x| x >= target }
        elsif up_or_down == :down
            lambda { |x| x <= target }
        else
            raise "Wrong up_or_down, expecting :up or :down"
        end
    end

    #condition: { :indicator => value }
    #return ture if all triggers are met
    def is_met?
        return false if @condition.size == 0
        results = @triggers.map { |ind, trigger| trigger.call @condition[ind]}
        return results.reduce(true) { |c, v| c && v }
    end
end
