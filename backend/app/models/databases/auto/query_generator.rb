module Databases
  module Auto
    class QueryGenerator
      UNSUPPORTED = "'---'"
      def self.generate index, mapping, *conditions
        columns = mapping[:columns].map{|each|
          unless each[:mapping][index][:belong].nil?
            "#{each[:mapping][index][:belong]}.#{each[:mapping][index][:column]} AS #{each[:label]}"
          else
            "#{each[:mapping][index][:column]} AS #{each[:label]}"
          end
        }.join(", ") + " "
        table = "#{mapping[:table][:mapping][index][:name]}"

        joins = mapping[:joins]&.map{|join|
          each = join[:mapping][index]
          if each[:name].nil?
            nil
          else
            "LEFT JOIN #{each[:name]} #{join[:shortcut]} ON #{each[:on]} "
          end
        }&.compact&.join("")

        query = "SELECT DISTINCT #{columns} FROM #{table} #{joins} "
        order = !mapping[:orders].empty? ? "ORDER BY #{mapping[:orders]&.join(", ")}" : ""
        return query + order if conditions.nil? || conditions.compact.empty?

        target = mapping[:columns].find{|each|
          each[:label] == mapping[:where][:target]
        }
        if mapping[:where][:operator] == "IN" || mapping[:where][:operator] == "NOT IN"
          cond = "#{target[:mapping][index][:belong]}.#{target[:mapping][index][:column]} #{mapping[:where][:operator]} ( " + conditions.map{|each|
            "#{mapping[:where][:converter][index].call(each)}"
          }.join(", ") + " ) "
        else
          cond = conditions.map{|each|
            "#{target[:mapping][index][:belong]}.#{target[:mapping][index][:column]} #{mapping[:where][:operator]} #{mapping[:where][:converter][index].call(each)}"
          }.join(" AND ")
        end
        where = "WHERE #{cond} " 
        query + where + order
      end
    end
  end
end