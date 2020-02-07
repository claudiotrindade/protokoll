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
                  :scope_by      => nil }

      options.merge!(_options)
      raise ArgumentError.new("pattern can't be nil!") if options[:pattern].nil?
      # raise ArgumentError.new("pattern requires at least one counter symbol #{options[:number_symbol]}") unless pattern_includes_symbols?(options)

      # Defining custom method
      send :define_method, "reserve_#{options[:column]}!".to_sym do
        pattern = options[:pattern].respond_to?(:call) ? self.instance_eval(&options[:pattern]) : (self.methods && self.methods.include?(options[:pattern]) ? self.send(options[:pattern]) : options[:pattern])
        self[column] = Counter.next(self, options.merge({pattern: pattern}))
      end

      # Signing before_create
      before_create do |record|
        unless record[column].present?
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
