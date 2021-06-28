class Tree
    attr_accessor :ancestors, :children, :value
  
    def initialize(v)
      @ancestors = []
      @value = v
      @children = []
    end
end