module Databases
  module Auto
    class Tables
      FORMATTER = {
        :normal => ->(base, col, op, val){
          # TODO 型変換が必要
          base.sanitize_sql_array ["#{col} #{op} ?", val[0]]
        },
        :null => ->(base, col, op, val){
          base.sanitize_sql_array ["#{col} #{op}"]
        },
        :in => ->(base, col, op, val){
          base.sanitize_sql_array ["#{col} #{op} (#{val[0].split(',').map{|e| '?'}.join(',')})", *val[0].split(",").map(&:strip)]
        },
        :between => ->(base, col, op, val){
          base.sanitize_sql_array ["#{col} #{op} ? AND ?", val[0], val[1]]
        },
        :like => ->(base, col, op, val){
          "#{col} #{op} '%#{val[0]}%'"
        }
      }
      OPERATORS = {
        :eq => { :id => 0, :op => "=", :fomatter => FORMATTER[:normal]},
        :not_eq => { :id => 1, :op => "!=", :fomatter => FORMATTER[:normal]},
        :gte => { :id => 2, :op => ">=", :fomatter => FORMATTER[:normal]},
        :gt => { :id => 3, :op => ">", :fomatter => FORMATTER[:normal]},
        :lte => { :id => 4, :op => "<=", :fomatter => FORMATTER[:normal]},
        :lt => { :id => 5, :op => "<", :fomatter => FORMATTER[:normal]},
        :is => { :id => 6, :op => "IS", :fomatter => FORMATTER[:normal]},
        :is_not => { :id => 7, :op => "IS NOT", :fomatter => FORMATTER[:null]},
        :is_null => {:id => 8, :op => "IS NULL", :fomatter => FORMATTER[:null]},
        :is_not_null => {:id => 9, :op => "IS NOT NULL", :fomatter => FORMATTER[:normal]},
        :in => {:id => 10, :op => "IN", :fomatter => FORMATTER[:in]},
        :not_in => {:id => 11, :op => "NOT IN", :fomatter => FORMATTER[:in]},
        :between => {:id => 12, :op => "BETWEEN", :fomatter => FORMATTER[:between]},
        :not_between => {:id => 13, :op => "NOT BETWEEN", :fomatter => FORMATTER[:between]},
        :like => {:id => 14, :op => "LIKE", :fomatter => FORMATTER[:like]},
        :not_like => {:id => 15, :op => "NOT LIKE", :fomatter => FORMATTER[:like]},
      }
      OPERATOR_IDS = OPERATORS.map{|k,v| v[:id]}

      def validate_data_search_params base, conditions
        # カラムで条件指定がある場合はカラムが正しいかは確認する
        condition_columns = conditions.map{|e| e["column"]}.uniq
        def_columns = find_columns base, condition_columns
        raise Databases::Errors::adParameterError.new condition_columns if condition_columns.length != def_columns.length

        # operator idが居るかは判定するが、column <> operatorが相応しいかは細かくチェックまでしない
        raise Databases::Errors::BadParameterError.new conditions.map{|e| e["operator"]}.join(",") unless conditions.find{|e| !OPERATOR_IDS.include?(e["operator"])}.nil?
      end

      def to_where_query base, column_name, operator_id, value
        op = OPERATORS.find{|k,v| v[:id] == operator_id}
        op = OPERATORS[op[0]]
        op[:fomatter].call(base, column_name, op[:op], value)
      end
    end
  end
end