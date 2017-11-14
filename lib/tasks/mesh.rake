require 'zip'

desc 'Deactivates inactive users'
namespace :mesh do
  task :import_subjects => :environment do
    puts 'Starting MESH subjects import. This will take a while...'
    @first = true
    zip_file = Zip::File.open('db/seeds/mesh_subs.zip')
    entry = zip_file.glob('*.bin').first

    ActiveRecord::Base.transaction do
      Category.delete_all
      entry.get_input_stream.each_line do |l|
        if l =~ /^MH /
          @name = l.gsub(/^MH = /, '').strip
          raise if @name.blank?
        end

        if l =~ /^MS /
          @description = l.gsub(/^MS = /, '').strip
          raise if @description.blank?
        end

        if l =~ /^UI /
          @uniq_id = l.gsub(/^UI = /, '').strip
          raise if @uniq_id.blank?
        end

        if l =~ /^CX /
          @matchers = l.gsub(
            /^CX = consider also terms at /, ''
          ).gsub(
            /, and /, ', '
          ).gsub(
            / and /, ', '
          ).split(', ').compact.reject {|o| o.blank? }.map(&:strip)
          raise if @matchers.blank?
        end

        if l =~ /^*NEWRECORD$/ && !@first
          Category.create!(
            name: @name,
            uniq_id: @uniq_id,
            description: @description,
            matchers: @matchers
          )

          @name = nil
          @uniq_id = nil
          @description = nil
          @matchers = []
        end

        @first = false if l =~ /^*NEWRECORD$/ && @first
      end

      Category.create!(
        name: @name,
        uniq_id: @uniq_id,
        description: @description,
        matchers: @matchers
      )
    end

    puts "Done, imported #{ Category.count } subjects"
  end
end
