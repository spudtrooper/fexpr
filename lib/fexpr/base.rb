module FExpr

  class Evaluator
    
    def initialize(argv)
      @argv = argv
      @node_stack = []
      @opt_trace = false
    end
    
    # Void -> String
    def eval
      @toks = Array.new @argv
      @tok  = nil
      next_token
      expr
      evaluate.to_s
    end

    private

    # Classes
    
    class Node
      def to_s
        to_string 0
      end
      def to_string(depth)
        raise 'Implement to_string, stupid!'
      end
      def eval
        raise 'Implement eval, stupid!'
      end
      def x(n)
        Array.new(n) { |x| '.' }.join(' ') + ' '
      end
    end

    class OpNode < Node
      attr_reader :op , :a, :b
      def initialize(op,a,b)
        @op = op
        @a  = a
        @b  = b
      end
      def eval
        a = @a.eval
        b = @b.eval
        case @op
        when  '|' then a and a != 0 ? a : b
        when  '&' then (a and a!=0 and b and b!=0) ? a : 0
        when  '=' then a == b
        when  '>' then a > b
        when '>=' then a >= b
        when  '<' then a < b
        when '<=' then a <= b
        when '!=' then a != b
        when  '+' then a + b
        when  '-' then a - b
        when  '*' then a * b
        when  'x' then a * b
        when  '/' then a / b
        when  '%' then a.to_i % b.to_i
        else error 'Invalid operator \'' + @op + '\''
        end
      end
      def to_string(n)
        str  = x(n) + @op + "\n"
        str += a.to_string(n+1) + "\n"
        str += b.to_string(n+1)
        return str
      end
    end

    class NumNode < Node
      attr_reader :val
      def initialize(val)
        @val = val
      end
      def eval
        @val
      end
      def to_string(n)
        x(n) + @val.to_s
      end
    end

    # Misc

    def trace(s)
      STDERR.puts s if @opt_trace
    end

    def shift(t)
      shift_one_of [t]
    end

    def shift_one_of(ts)
      found = false
      ts.each do |t|
        if @tok == t
          next_token
          return t
        end
      end
      return nil
    end

    def next_token
      if not @toks.empty?
        @tok = @toks.shift.gsub /[,_\$]/,''
      end
      @tok
    end

    def error(msg)
      STDERR.puts msg
      STDERR.flush
      exit 1
    end

    def push(n)
      @node_stack << NumNode.new(n)
    end

    def push_binop(op)
      b = pop
      a = pop
      @node_stack << OpNode.new(op,a,b)
    end

    def pop
      @node_stack.pop
    end

    # Void -> String
    def evaluate
      trace @node_stack
      pop.eval
    end

    # Parsing

    # -------------------------------------------------------------------------------------------
    # Grammar:
    #
    #  expr      ::= or_expr
    #  or_expr   ::= or_expr  '|' and_expr
    #  and_expr  ::= and_expr '&' rel_expr
    #  rel_expr  ::= rel_expr  ( '=' | '>' | '>=' | '<' | '<=' | '!=' )add_expr
    #  add_expr  ::= add_expr ( '+' | '_' ) mul_expr
    #  mul_expr  ::= mul_expr ( 'x' | '*' | '/' | '%' ) sim_expr
    #  sim_expr  ::= <number>
    #
    # The Re-factored Grammar:
    #     -----------
    #
    #  expr           ::= or_expr
    #  or_expr        ::=     and_expr  or_expr_tail
    #  or_expr_tail   ::= '|' and_expr  or_expr_tail
    #  and_expr       ::=     rel_expr and_expr_tail
    #  and_expr_tail  ::= '&' rel_expr and_expr_tail
    #  rel_expr       ::=                                           add_expr rel_expr_tail
    #  rel_expr_tail  ::= ( '=' | '>' | '>=' | '<' | '<=' | '!=' )  add_expr rel_expr_tail
    #  add_expr       ::=               mul_expr and_expr_tail
    #  add_expr_tail  ::= ( '+' | '-' ) mul_expr add_expr_tail
    #  mul_expr       ::=                     sim_expr mul_expr_tail
    #  mul_expr_tail  ::= ( 'x' | '*' | '/' | '%' ) sim_expr mul_expr_tail
    #  sim_expr       ::= <number>
    # -------------------------------------------------------------------------------------------

    def expr
      or_expr
    end
    
    def or_expr
      and_expr
      or_expr_tail
    end

    def or_expr_tail
      op = shift '|'
      return if not op
      and_expr
      or_expr_tail
      push_binop op
    end

    def and_expr
      rel_expr
      and_expr_tail
    end
    
    def and_expr_tail
      op = shift '&'
      return if not op
      rel_expr
      and_expr_tail
      push_binop op
    end

    def rel_expr
      add_expr
      rel_expr_tail
    end

    def rel_expr_tail
      op = shift_one_of ['=','>','>=','<','<=','!=']
      return if not op
      add_expr
      rel_expr_tail
      push_binop op
    end

    def add_expr
      mul_expr
      add_expr_tail
    end

    def add_expr_tail
      op = shift_one_of ['+','-']
      return if not op
      mul_expr
      add_expr_tail
      push_binop op
    end

    def mul_expr
      sim_expr
      mul_expr_tail
    end

    def mul_expr_tail
      op = shift_one_of ['x','*','/','%']
      return if not op
      sim_expr
      mul_expr_tail
      push_binop op
    end

    def sim_expr
      n = @tok.to_f
      push n
      next_token
    end
  end  
end
