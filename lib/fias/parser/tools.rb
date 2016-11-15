require 'fias/fias/parser/tools/nokogiri_document'
require 'savon'
require 'progressbar'

module Fias::Parser::Tools
  extend self

  # Get URL of FIAS database
  #
  def retrive_xml_link(options = {})
    client = Savon.client(wsdl: "http://fias.nalog.ru/WebServices/Public/DownloadService.asmx?WSDL")
    responce = client.call(:get_last_download_file_info).body[:get_last_download_file_info_response][:get_last_download_file_info_result]
    return responce[:fias_complete_xml_url] if options[:type] == :import
    return responce[:fias_delta_xml_url] if options[:type] == :update
  end

  # Download FIAS database to destination
  #
  def download(path = nil)
    path ||= Dir.mktmpdir nil, '/tmp'
    unless File.directory?(path)
      FileUtils.mkdir_p(path)
    end

    file_name = File.join(path, "fias-#{ Time.now.strftime('%Y-%m-%d') }.rar")
    puts "downloading to #{ file_name }"

    link = retrive_xml_link(type: :import)

    uri_obj = URI.parse(link)

    file = open(file_name, 'wb')
    Net::HTTP.start(uri_obj.host) do |http|
      begin
        http.request_get(uri_obj.request_uri) do |response|
          progress = ProgressBar.new("Downloading", response['content-length'].to_i)
          done = 0
          response.read_body do |segment|
            done += segment.length
            progress.set(done)
            file.write(segment)
          end
          progress.finish
        end
      ensure
        file.rewind
        file.close
      end
    end
    file.path
  end

  # Extract FIAS database from archive
  #
  def extract(path)
    dir = File.dirname(path)
    selectors = {fias_addrobj: /AS_ADDROBJ_/}

    # get filename to extract only one file.
    as_addrobj_filename = `unrar l #{path}`.split("\n").select {|row| row =~ /AS_ADDROBJ/}.first.split(' ').last
    unrar_output = `unrar e #{path} #{as_addrobj_filename} #{dir}`
    print unrar_output

    temp_dir_files = []
    result = {}

    Dir.foreach(dir) do |item|
      next if item == '.' or item == '..'
      selectors.each do |index, val|
        result[index] = File.open(File.join(dir, item)) if item =~ val
      end
      temp_dir_files.push(item)
    end
    result[:total] = temp_dir_files
    result
  end

  # Parse extracted FIAS database and import it into project
  #
  def import(result)
    handle_model_parsing(result, Fias::Parser::ModelWriter)
  end

  def handle_model_parsing(parameters, model_handler)
    (p("Cannot find xml file for addrobjs, dir files list: #{parameters[:total].join("\n")}"); exit) if parameters[:fias_addrobj].nil?
    NokogiriDocument.new(parameters[:fias_addrobj], model_handler.new(), 'Object')
    p "Parsed all addrobjs, see log/ directory for log file"
  end
end
