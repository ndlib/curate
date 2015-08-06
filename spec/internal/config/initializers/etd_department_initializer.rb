DEPARTMENT = YAML.load( File.open( Rails.root.join( 'config/etd_department_map.yml' ) ) ).freeze if File.exist?(Rails.root.join( 'config/etd_department_map.yml'))
