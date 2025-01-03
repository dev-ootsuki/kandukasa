FactoryBot.define do
  factory :mysql_sakila, class:DbConnection do
    name {"sakila DB"}
    host {"test-mysql"}
    port {3306}
    default_database_name {"sakila"}
    db_type {"MySQL"}
    login_name {"root"}
    password {"test"}
    timeout {5000}
    use_ssl {false}
  end
  
  factory :mysql_world, class:DbConnection do
    name {"world DB"}
    host {"test-mysql"}
    port {3306}
    default_database_name {"world"}
    db_type {"MySQL"}
    login_name {"root"}
    password {"test"}
    timeout {5000}
    use_ssl {false}
  end

  factory :mysql_world_new, class:DbConnection do
    name {"world DB 2"}
    host {"test-mysql"}
    port {3306}
    default_database_name {"world"}
    db_type {"MySQL"}
    login_name {"root"}
    password {"test"}
    timeout {5000}
    use_ssl {false}
  end
end