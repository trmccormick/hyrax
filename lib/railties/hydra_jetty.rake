require 'jettywrapper'

namespace :jetty do
  desc "Apply all configs to Testing Server (relies on hydra:jetty:config tasks unless you override it)"
  task :config do
    Rake::Task["hydra:jetty:config"].invoke
  end
end

namespace :hydra do
  namespace :jetty do
    desc "Copies the default Solr & Fedora configs into the bundled Hydra Testing Server"
    task :config do
      Rake::Task["hydra:jetty:config_fedora"].invoke
      Rake::Task["hydra:jetty:config_solr"].invoke
    end
    
    desc "Copies the contents of solr_conf into the Solr development-core and test-core of Testing Server"
    task :config_solr do
      FileList['solr_conf/*'].each do |f|  
        cp("#{f}", 'jetty/solr/development-core/', :verbose => true)
        cp("#{f}", 'jetty/solr/test-core/', :verbose => true)
      end
    end

    desc "Copies a custom fedora config for the bundled Hydra Testing Server"
    task :config_fedora do
      # load a custom fedora.fcfg - 
      if defined?(Rails.root)
        app_root = Rails.root
      else
        app_root = File.join(File.dirname(__FILE__),"..")
      end
       
      fcfg = File.join(app_root,"fedora_conf","conf","fedora.fcfg")
      puts "PWD:: #{FileUtils.pwd}"
      if File.exists?(fcfg)
        puts "copying over fedora.fcfg"
        cp("#{fcfg}", 'jetty/fedora/default/server/config/', :verbose => true)
      else
        puts "#{fcfg} file not found -- skipping fedora config"
      end
    end

    desc "Copies the default SOLR config files and starts up the fedora instance."
    task :load => [:config, :start]

  end
end
