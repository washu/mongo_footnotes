require 'rails'
require 'mongo_footnotes'
module MongoFootnotes
  class Railtie< Rails::Railtie
    def instrument(clazz, methods)
      clazz.module_eval do
        methods.each do |m|
          class_eval <<-CODE, __FILE__, __LINE__ + 1
            def #{m}_with_instrumentation(*args, &block)
              payload = {
                :name => args[0],
              }
              payload.merge!(args[1])
              ActiveSupport::Notifications.instrumenter.instrument("mongo.mongo", payload) do
                #{m}_without_instrumentation(*args, &block)
                args
              end
            end
          CODE
          alias_method_chain m, :instrumentation
        end
      end
    end
    MongoFootnotes.load!
    instrument Mongo::Logging, [
        :log_operation
    ]
    ActiveSupport.on_load(:action_controller) do
      include RuntimeHook
    end
    ActiveSupport::LogSubscriber.attach_to :mongo, Footnotes::Notes::MongoSubscriber.instance
    Footnotes::Filter.notes += [:mongo]
  end
end