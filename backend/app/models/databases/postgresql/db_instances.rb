module Databases
  module Postgresql
    class DbInstances < Databases::Auto::DbInstances
      def find_character_sets base
        query = <<-"EOS"
          SELECT DISTINCT
            pg_encoding_to_char(pgcv.conforencoding) AS character_set_name,
            STRING_AGG(pgcl.collname, ',') AS default_collation_name,
            #{Databases::Auto::QueryGenerator::UNSUPPORTED} AS description,
            #{Databases::Auto::QueryGenerator::UNSUPPORTED} AS maxlen
          FROM 
            pg_catalog.pg_conversion pgcv
          INNER JOIN
            pg_catalog.pg_collation pgcl ON pg_encoding_to_char(pgcv.contoencoding) = pg_encoding_to_char(pgcl.collencoding)
          GROUP BY
            pgcv.conforencoding, pgcv.contoencoding, pgcl.collencoding
          ORDER BY 
            character_set_name
        EOS
        [{ 
          "character_set_name" => "UTF8", 
          "default_collation_name" => "ucs_basic,pg_c_utf8,C.utf8,en_US.utf8,en_US", 
          "description" => Databases::Auto::QueryGenerator::UNSUPPORTED.gsub(/'/, ''),
          "maxlen" => Databases::Auto::QueryGenerator::UNSUPPORTED.gsub(/'/,'')
        }].concat(base.connection.execute(query).to_a.map{|record| record.transform_keys(&:downcase) })
      end

      def find_users_privileges base
        # select * from pg_catalog.pg_user でユーザー一覧
        # select usename AS grantee, (usecreatedb == true || userepl == true || usesuper == true) AS table_schema from pg_catalog.pg_user
        # select usename AS grantee, case usecreatedb when true then '*' else 'NG' end end from pg_catalog.pg_user
        
        # 最初にスキーマとDB作成権限全部を持つユーザーを抜き出して全部権限ありで詰める
        
        query = <<-'EOS'
          SELECT DISTINCT 
            privilege_type 
          FROM 
            information_schema.role_table_grants;
        EOS
        all_privileges = base.connection.execute(query).to_a.map{|record| 
          record.transform_keys(&:downcase) 
          record["privilege_type"]
        }.join(", ")

        query = <<-"EOS"
          SELECT 
            usename AS grantee, 
            CASE usecreatedb 
              WHEN true THEN 'ALL' 
              WHEN false THEN
                CASE usesuper
                  WHEN true THEN 'ALL'
                  WHEN false THEN
                    CASE userepl
                      WHEN true THEN 'ALL'
                      ELSE 'NO'
                    END
                END
            END AS table_schema,
            'ALL' AS table_name
          FROM
            pg_catalog.pg_user pgu
        EOS
        all_granted_user = base.connection.execute(query).to_a.map{|record| 
          record.transform_keys(&:downcase) 
          record[:privileges] = all_privileges
          record
        }

        # これ動いてなi
        query = <<-"EOS"
          SELECT
            pgu.usename AS grantee,
            srtg.table_schema AS table_schema,
            srtg.table_name AS table_name,
            STRING_AGG("privilege_type", ',') AS privileges
          FROM
            pg_catalog.pg_user pgu
          LEFT JOIN
            information_schema.role_table_grants srtg
          ON
            srtg.grantee = pgu.usename
          WHERE
            srtg.table_schema != 'pg_catalog' AND srtg.table_schema != 'information_schema'
          GROUP BY
            srtg.grantee, pgu.usename, srtg.table_name, srtg.table_schema;
        EOS
        
        base.connection.execute(query).to_a.map{|record| record.transform_keys(&:downcase) }.concat(all_granted_user)
      end

      def find_available_engines base
        []
        # can't not select engine
      end
    end
  end
end