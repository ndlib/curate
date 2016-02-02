Curate.configure do |config|
  # Injected via `rails g curate:work Spam`
  config.register_curation_concern :spam
        config.application_root_url = 'http://localhost'
        config.default_antivirus_instance = lambda {|file_path|
          AntiVirusScanner::NO_VIRUS_FOUND_RETURN_VALUE
        }
        config.characterization_runner = lambda {|file_path|
          Curate::Engine.root.join('spec/support/files/default_fits_output.xml').read
        }
  config.register_curation_concern :generic_work
  config.register_curation_concern :dataset
  config.register_curation_concern :article
  config.register_curation_concern :etd
  config.register_curation_concern :image
  config.register_curation_concern :document
  # # You can override curate's antivirus runner by configuring a lambda (or
  # # object that responds to call)
  # config.default_antivirus_instance = lambda {|filename| … }

  # # Used for constructing permanent URLs
  # config.application_root_url = 'https://repository.higher.edu/'

  # # Used to load values for constructing SOLR searches
  search_config_file = File.join(Rails.root, 'config', 'search_config.yml')
  config.search_config = YAML::load(File.open(search_config_file))[Rails.env].with_indifferent_access

  # # Override the file characterization runner that is used
  # config.characterization_runner = lambda {|filename| … }
end
