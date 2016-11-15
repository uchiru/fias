require 'progressbar'
require 'geo_linker/fias/parser/tools/nokogiri_document'
require 'savon'

module GeoLinker::Fias::Parser::Tools
  def retrive_xml_link(options = {})
    client = Savon.client(wsdl: "http://fias.nalog.ru/WebServices/Public/DownloadService.asmx?WSDL")
    responce = client.call(:get_last_download_file_info).body[:get_last_download_file_info_response][:get_last_download_file_info_result]
    return responce[:fias_complete_xml_url] if options[:type] == :import
    return responce[:fias_delta_xml_url] if options[:type] == :update
  end

  def take_from_directory(dir, selectors, &block)
    dir_files = []
    result = {}
    file_path = "#{dir}/fias.rar"
    as_addrobj_filename = `unrar l #{file_path}`.split("\n").select {|row| row =~ /AS_ADDROBJ/}.first.split(' ').last
    unrar_output = `unrar e #{file_path} #{as_addrobj_filename} #{dir}`
    print unrar_output

    Dir.foreach(dir) do |item|
      next if item == '.' or item == '..'
      selectors.each do |index, val|
        result[index] = File.open(File.join(dir, item)) if item =~ val
      end
      dir_files.push(item)
    end
    result[:total] = dir_files
    yield(result)
  end

  def download_and_extract(link, selectors, &block)
    Dir.mktmpdir("fias_xml_#{Time.now.strftime('%d_%m_%y')}") do |dir|
      uri_obj = URI.parse(link)

      file = open(File.join(dir, 'fias.rar'), 'wb')
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

      # get filename to extract only one file.
      as_addrobj_filename = `unrar l #{file.path}`.split("\n").select {|row| row =~ /AS_ADDROBJ/}.first.split(' ').last
      unrar_output = `unrar e #{file.path} #{as_addrobj_filename} #{dir}`
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
      yield(result)
    end
  end

  def handle_model_parsing(parameters, model_handler)
    (p("Cannot find xml file for addrobjs, dir files list: #{parameters[:total].join("\n")}"); exit) if parameters[:fias_addrobj].nil?
    NokogiriDocument.new(parameters[:fias_addrobj], model_handler.new(), 'Object')
    p "Parsed all addrobjs, see log/ directory for log file"
  end
end
