DOCUMENT_TYPES = YAML.load( File.open( Rails.root.join( 'config/document_types.yml' ) ) ).freeze if File.exist?(Rails.root.join( 'config/document_types.yml'))
