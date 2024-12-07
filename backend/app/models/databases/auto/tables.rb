module Databases
  module Auto
    class Tables
      FORMATTER = {
        :normal => ->(base, col, op, val){
          base.sanitize_sql_array ["#{col} #{op} ?", val[0]]
        },
        :bool => ->(base, col, op, val){
          "#{col} #{op} #{val == 1 ? 'TRUE' : 'FALSE'}"
        },
        :null => ->(base, col, op, val){
          base.sanitize_sql_array ["#{col} #{op} ?", val[0]]
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
        :is => { :id => 6, :op => "IS", :fomatter => FORMATTER[:bool]},
        :is_not => { :id => 7, :op => "IS NOT", :fomatter => FORMATTER[:bool]},
        :is_null => {:id => 8, :op => "IS NULL", :fomatter => FORMATTER[:null]},
        :is_not_null => {:id => 9, :op => "IS NOT NULL", :fomatter => FORMATTER[:null]},
        :in => {:id => 10, :op => "IN", :fomatter => FORMATTER[:in]},
        :not_in => {:id => 11, :op => "NOT IN", :fomatter => FORMATTER[:in]},
        :between => {:id => 12, :op => "BETWEEN", :fomatter => FORMATTER[:between]},
        :not_between => {:id => 13, :op => "NOT BETWEEN", :fomatter => FORMATTER[:between]},
        :like => {:id => 14, :op => "LIKE", :fomatter => FORMATTER[:like]},
        :not_like => {:id => 15, :op => "NOT LIKE", :fomatter => FORMATTER[:like]},
      }
      OPERATOR_IDS = OPERATORS.map{|k,v| v[:id]}

      # TODO 最初にcontrollerでvalidateしてraise errorはやめる
      def validate_data_search_params base, conditions
        # カラムで条件指定がある場合はカラムが正しいかは確認する
        condition_columns = conditions.map{|e| e["column"]}.uniq
        def_columns = find_columns base, condition_columns
        raise Databases::Errors::BadParameterError.new condition_columns if condition_columns.length != def_columns.length

        # operator idが居るかは判定するが、column <> operatorが相応しいかは細かくチェックまでしない
        raise Databases::Errors::BadParameterError.new conditions.map{|e| e["operator"]}.join(",") unless conditions.find{|e| !OPERATOR_IDS.include?(e["operator"])}.nil?
      end

      def conditions_empty? conditions
        return true if conditions.nil?
        return true if conditions.length == 0
        target = conditions.first
        return true if target.nil?
        target[:column].nil? && target[:operator].nil? && (target[:input].nil? || target[:input].length == 0 || target[:input].length == 1 && !target[:input].find{|e| !e.nil? }.nil?)
      end

      def to_where_query base, column_name, operator_id, value, col_def
        op = OPERATORS.find{|k,v| v[:id] == operator_id}
        return '' if op.nil?
        op = OPERATORS[op[0]]
        convert_val = value.map{|e| string_to_type_value col_def, e}
        op[:fomatter].call base, column_name, op[:op], convert_val
      end

      def find_info base
        {
          :columns => find_columns(base),
          :primaries => find_primary_keys(base)
        }
      end

      def to_unique_identifer_query base, primaries, columns, ids
        ids.map.with_index{|id, idx|
          ret = id.split(DbStrategy::MULTI_PRIMARY_KEY_SEPARATOR).map.with_index{|pkeys, pidx|
            col_def = columns[pidx]
            to_query_eq_string base, col_def, id
          }.compact.join(" AND ")
          "( #{ret} )"
        }.join(" OR ")
      end

      def to_query_eq_string base, col_def, val
        v = string_to_type_value col_def, val
        return nil if v.nil?
        base.sanitize_sql_array ["#{col_def["column_name"]} = ?", v]
      end

      def string_to_type_value col_def, val
        if type_string? col_def
          val
        elsif type_number? col_def
          val.to_i
        elsif type_float? col_def
          val.to_f
        elsif type_geometry? col_def
          "ST_GeomFromText('#{val}')"
        elsif type_blob? col_def
          nil
        elsif type_bool? col_def
          val.to_i
        else
          val
        end
      end
    end
  end
end