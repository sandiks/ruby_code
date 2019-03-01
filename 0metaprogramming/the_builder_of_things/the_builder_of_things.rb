# https://www.codewars.com/kata/the-builder-of-things/ruby
# https://www.codewars.com/kata/reviews/5571e09a385f59d95f000063/groups/59426d64e6049310a70006ce

# imported to handle any plural/singular conversions
require 'active_support/core_ext/string'

class Thing
  def initialize(name)
    @properties = {}
    is_the.name.send(name)
  end

  def is_a
    @state = State::DefineBoolean.new(true)
    self
  end

  def is_not_a
    @state = State::DefineBoolean.new(false)
    self
  end

  def has(count)
    @state = State::Has.new(count)
    self
  end

  def is_the
    @state = State::IsThe.new
    self
  end

  def can
    @state = State::Can.new
    self
  end

  alias being_the is_the
  alias and_the is_the
  alias having has

  def method_missing(sym, *args, &block)
    if /\?$/.match(sym)
      @state = State::QueryBoolean.new
    end

    if @properties.key?(sym)
      @state = State::Query.new
    end

    if @state
      return @state.call(self, sym, *args, &block)
    end

    super
  end

  ###############################################
  # FIXME: These two methods should not be public
  attr_accessor :properties

  def reset_state
    @state = nil
  end
  ###############################################


  module State
    class DefineBoolean
      def initialize(value)
        @value = value
      end

      def call(thing, sym, *args, &block)
        thing.properties[sym] = @value
        thing
      end
    end

    class QueryBoolean
      def call(thing, sym, *args, &block)
        method_name = /\?$/.match(sym).pre_match.to_sym
        thing.reset_state
        thing.properties[method_name]
      end
    end

    class Query
      def call(thing, sym, *args, &block)
        value = thing.properties[sym]
        if value.is_a? Proc
          thing.instance_exec(*args, &value)
        else
          value
        end
      end
    end

    class Has
      def initialize(how_many)
        @how_many = how_many
      end

      def call(thing, sym, *args, &block)
        what = sym.to_s.singularize
        thing.properties[sym] = if @how_many == 1
                                  thing_that_is_a(what)
                                else
                                  ThingArray.new(@how_many) { thing_that_is_a(what) }
                                end
      end

      private

      def thing_that_is_a(what)
        Thing.new(what).is_a.send(what)
      end
    end

    class IsThe
      def initialize
        @property = nil
      end

      def call(thing, sym, *args, &block)
        if @property
          thing.properties[@property] = sym.to_s
          thing.reset_state
        else
          @property = sym
        end
        thing
      end
    end

    class Can
      def call(thing, sym, *args, &block)
        logging_method_name = args.first
        thing.properties[sym] = logging_lambda(thing, logging_method_name, &block)
        thing
      end

      private

      def logging_lambda(thing, logging_method_name, &block)
        lambda do |arg|
          result = instance_exec arg, &block
          if logging_method_name
            (thing.properties[logging_method_name.to_sym] ||= []) << result
          end
          result
        end
      end
    end
  end
  private_constant :State
end

class ThingArray < Array
  def each(*_args, &block)
    to_a.each do |element|
      element.instance_eval(&block)
    end
  end
end

jane = Thing.new('Jane')

#jane.has(2).arms.each { having(1).hand.having(5).fingers }
#p jane.arms

#jane.has(2).legs

jane.can.speak('spoke') do |phrase|
  p "#{name} says: #{phrase}"
end

jane.speak("hello") # => "Jane says: hello"

# if past tense was provided then method calls are tracked
p jane.spoke # => ["Jane says: hello"]