require 'pry'

class Transducer
  def self.compose(*collections)
    collections
  end

  def self.call(funcs, meth, container, values)
    funcs.map! { |func| func.to_meth }
    values.each do |val|
      n = 0
      result = nil

      while n < funcs.length
        func = funcs[n]
        result = func.call(val)
        if result
          n += 1
        else
          n = funcs.length
        end
      end

      container.send(meth, result) if result
    end

    return container
  end
end

class MethodMaker
  def initialize(klass, meth, *args)
    @klass = klass
    @meth  = meth
    @block = args.shift
    @args  = args
  end

  def to_proc
    # the block is a block that is treated as &@block
    # @block = @block.is_a?(Symbol) ? ->(x) { x.send(@block) } : @block
    if @block.is_a?(Symbol)
      ->(x) { x.send(@block) }
    ->(val) {
      if @block.is_a?(Proc)
        @block.call(val)
      # @args.length > 0 ? object.send(@meth, *@args) : object.send(@block)
    }
  end
end


funcs = Transducer.compose(
  MethodMaker.new([], :select, :even?),
  MethodMaker.new([], :map, :*, 2),
  MethodMaker.new([], :take, 5)
)

binding.pry

# Transducer.call(funcs, :<<, [], 0..9)
