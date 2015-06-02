DEGREE = YAML.load( File.open( Rails.root.join( 'config/etd_degree_map.yml' ) ) ).freeze if File.exist?(Rails.root.join( 'config/etd_degree_map.yml'))
