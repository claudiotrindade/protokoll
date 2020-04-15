module Protokoll
  extend ActiveSupport::Concern

  module ClassMethods

    # Class method available in models
    #
    # == Example
    #   class Order < ActiveRecord::Base
    #      protokoll :number
    #   end
    #
    def protokoll(column, _options = {})
      options = { :pattern       => "%Y%m#####",
                  :number_symbol => "#",
                  :column        => column,
                  :start         => 0,
                  :scope_by      => nil,
                  :counter_model_name => nil }

      options.merge!(_options)
      raise ArgumentError.new("pattern can't be nil!") if options[:pattern].nil?
      # raise ArgumentError.new("pattern requires at least one counter symbol #{options[:number_symbol]}") unless pattern_includes_symbols?(options)

      # Defining custom method
      send :define_method, "reserve_#{options[:column]}!".to_sym do
        options = self.build_protokoll_options(options)
        self[column] = Counter.next(self, options)
        self[column]
      end

      send :define_method, "build_protokoll_options".to_sym do |options|
        if options[:pattern_generator]
          options[:pattern] = options[:pattern_generator].respond_to?(:call) ? options[:pattern_generator].call(self) : (self.methods && self.methods.include?(options[:pattern_generator]) ? self.send(options[:pattern_generator]) : options[:pattern])
        end
        options
      end

      # Signing before_create
      before_create do |record|
        unless record[column].present?
          options = record.build_protokoll_options(options)
          record[column] = Counter.next(self, options)
        end
      end
    end

    private

    # def pattern_includes_symbols?(options)
    #   if !options[:pattern].respond_to?(:call)
    #     options[:pattern].count(options[:number_symbol]) > 0
    #   else
    #     true
    #   end
    # end
  end

end
