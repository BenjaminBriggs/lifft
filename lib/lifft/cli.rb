#!/usr/bin/env ruby

require 'zip'
require 'thread'
require 'io/console'
require 'tmpdir'

require 'thor'
require 'httmultiparty'
require 'countries'

require 'lifft'

Thread.abort_on_exception = true

module Lifft
  class CLI < Thor
    class_option :verbose, :type => :boolean, :aliases => "-v"

    method_option :user, :required => true, :aliases => "-u"
    method_option :project, :required => true, :type => :string
    method_option :password, :aliases => "-p"
    method_option :timeout, :type => :numeric, :default => 600, :aliases => "-t"
    desc "fetch [PROJECT]", "Used to fetch the latest localisations"
    def fetch(project)

      projectName = options[:project]
      username = options[:user]

      # Check if we need to ask for a password
      if options[:password]
        password = options[:password]
      else
        print "Password:"
        password = STDIN.noecho(&:gets).chomp
        puts ""
      end

      if !options[:verbose] then
        Thread.new do
          #set up spinner
          glyphs = ['|', '/', '-', "\\"]
          while true
            glyphs.each do |g|
              print "\r#{g}"
              sleep 0.15
            end
          end
        end
      end

      auth = {:username => username, :password => password}
      warningSuppressor = options[:verbose]? "" : " > /dev/null 2>&1"

      Dir.glob("**/*.lproj/") do |langFolder|

      lang = File.basename(langFolder).chomp(".lproj")
      country = Country.new(lang)

      puts "Fetching translations for #{country.name}." if options[:verbose]
      puts "https://api.getlocalization.com/#{project}/api/translations/file/en.xliff/#{lang}/" if options[:verbose]
      puts "This may take a while!" if options[:verbose]

      if options[:verbose] then
        spinner = Thread.new do
          #set up spinner
          glyphs = ['|', '/', '-', "\\"]
          while true
            glyphs.each do |g|
              print "\r#{g}"
              sleep 0.15
            end
          end
        end
      end

      tempfile = Tempfile.new("file")

      begin
        response = HTTParty.get("https://api.getlocalization.com/#{project}/api/translations/file/en.xliff/#{lang}/", :basic_auth => auth, :timeout => options[:timeout])
      rescue
        puts "Oh no, somthing fucked up."
        return
      else
        spinner.exit if options[:verbose]
        puts "" if options[:verbose]
        if response.code == 200
          puts "File downloaded" if options[:verbose]
          tempfile.binmode # This might not be necessary depending on the zip file
          tempfile.write(response.body)
          puts "Importing the file" if options[:verbose]
          system("xcodebuild -importLocalizations -localizationPath #{tempfile.path.chomp} -project #{projectName.chomp}"+warningSuppressor)
        elsif response.code == 401
          puts "The username or password are invailed"
          return
        else
          puts "Bad response. Close but no cigar."
          puts "Couldn't fetch translations for #{country.name}"
        end
      ensure
        tempfile.close
      end
    end

    end

    method_option :user, :required => true, :aliases => "-u"
    method_option :project, :required => true, :type => :string
    method_option :password, :aliases => "-p"
    method_option :new, :type => :boolean, :aliases => "-n"
    desc "update [PROJECT]", "Used to send the latest localisations to get localization"
    def update(project)
      username = options[:user]

      # Check if we need to ask for a password
      if options[:password]
        password = options[:password]
      else
        print "Password:"
        password = STDIN.noecho(&:gets).chomp
        puts ""
      end

      warningSuppressor = options[:verbose]? "" : " > /dev/null 2>&1"

      if !options[:verbose] then
        Thread.new do
          # Set up spinner
          glyphs = ['|', '/', '-', "\\"]
          while true
            glyphs.each do |g|
              print "\r#{g}"
              sleep 0.15
            end
          end
        end
      end

      auth = {:username => username, :password => password}

      projectName = options[:project]

      dir = Dir.mktmpdir

      system("xcodebuild -exportLocalizations -localizationPath #{dir.chomp} -project #{projectName.chomp}"+warningSuppressor)

      body = {"file" => File.new(dir+"/en.xliff")}

      if !options[:new]
        # Update master
        puts "Updateing " + "en.xliff" if options[:verbose]
        response = HTTMultiParty.post("https://api.getlocalization.com/#{project}/api/update-master/", :basic_auth => auth, :query => body)
        else
        # Upload new master
        puts "Creating " + "en.xliff" if options[:verbose]
        response = HTTMultiParty.post("https://api.getlocalization.com/#{project}/api/create-master/ios/en/", :basic_auth => auth, :query => body)
      end

      puts "Upload complete with responce code #{response.code}" if options[:verbose]
      puts "" if options[:verbose]

    end

  end
end
